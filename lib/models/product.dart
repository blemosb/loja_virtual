import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/models/item_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class Product extends ChangeNotifier { //model do produto

  String id;
  String name;
  String description;
  List<String> images;
  List<ItemSize> sizes;
  List<dynamic> newImages; //para saber se novas imagens foram adicionadas para o produto durante uma edição.
                            //é dinamico porque pode ter url de string das imagens (vem do firebase) ou file para fotos adicionadas na edição
  bool deleted;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  DocumentReference get firestoreRef => firestore.doc('products/$id');
  StorageReference get storageRef => storage.ref().child('products').child(id); //cria uma pasta products e uma subpasta com nome id para
                                                                                //um produto específico

  bool _loading = false;
  bool get loading => _loading;

  set loading(bool value){
    _loading = value;
    notifyListeners();
  }



  Product({this.id, this.name, this.description, this.images, this.sizes,
    this.deleted = false}){ //se não passar valor de deleted é false por default
    images = images ?? []; //se n receber um valor de imagens no parametro cria uma lista vazia
    sizes = sizes ?? [];
  }

  Product clone(){
    return Product(
      id: id,
      name: name,
      description: description,
      images: List.from(images),
      sizes: sizes.map((size) => size.clone()).toList(), //pega cada item da lista de sizes, clonando e transformando em uma nova lista
      deleted: deleted,
    );
  }

  Product.fromDocument(DocumentSnapshot document){  //le um produto do firebase
    id = document.id;
    name = document.data()['name'] as String;
    description = document.data()['description'] as String;
    images = List<String>.from(document.data()['images'] as List<dynamic>);
    sizes = (document.data()['sizes'] as List<dynamic> ?? []).map( //se nao tiver tamanho no firebase, atribui uma lista vazia
            (s) => ItemSize.fromMap(s as Map<String, dynamic>)).toList();
    deleted = (document.data()['deleted'] ?? false) as bool; //se essa opção n vier do firebase seta como false
  }

  ItemSize _selectedSize; //se o tamanho está selecionado ou nao

  ItemSize get selectedSize => _selectedSize;

  set selectedSize(ItemSize value){
    _selectedSize = value;
    notifyListeners();/**/
  }

  int get totalStock {
    int stock = 0;
    for(final size in sizes){
      stock += size.stock;
    }
    return stock;
  }

  bool get hasStock {
    return totalStock > 0 && !deleted;
  }

  ItemSize findSize(String name){
    try {
      return sizes.firstWhere((s) => s.name == name);
    } catch (e){
      return null;
    }
  }

  num get basePrice { //pega o menor preço dentre todos os tamnahos q tem no estoque
    num lowest = double.infinity;
    for(final size in sizes){
      if(size.price < lowest)
        lowest = size.price;
    }
    return lowest;
  }
//pega todos os tamanhos e transforma em uma lista de mapas
  List<Map<String, dynamic>> exportSizeList(){
    return sizes.map((size) => size.toMap()).toList(); //pega cada size e transforma em um mapa. o conjunto destes mapas serão uma lista
                                                        //esse toMap é uma funcção do item_size que transforma cada item size um um mapa
  }
//criado um campo para avisar se o produto foi deletado ou não. se apagasse do firebase iria dar erro em pedidos que tenha esse produto
  void delete(){
    firestoreRef.update({'deleted': true});
  }

  Future<void> save() async { //salva um produto no firebase
    loading = true;
    final Map<String, dynamic> data = { //esse mapa é o padrão para salvar no firebase
      'name': name,
      'description': description,
      'sizes': exportSizeList(),
      'deleted': deleted
    };

//atualiza name, descricao e tamanho**********************************************8
    if(id == null){ //é um novo produto
      final doc = await firestore.collection('products').add(data);
      id = doc.id;
    } else { //se produto ja existe faz um update
      await firestoreRef.update(data); //set(data) substitui o produto
    }
//fim do primeiro updtate do produto *****************************************

    final List<String> updateImages = [];//pega as imagens que deverão continuar para o produto no firebase


    //UPLOAD DAS IMAGENS***********************************8
//compara se cada nova imagem está presente na imagem original, ou seja, está procurando se novas imagens foram adicionadas
    for(final newImage in newImages){
      if(images.contains(newImage)){
        updateImages.add(newImage as String); //se a imagem original ainda está em new image então faz update
      } else {
        final StorageUploadTask task = storageRef.child(Uuid().v1()).putFile(newImage as File);//UUID cria um nome único para a imagem
        final StorageTaskSnapshot snapshot = await task.onComplete; //sobre a imagem para o firebase
        final String url = await snapshot.ref.getDownloadURL() as String; //pega a url do arquivo que foi feito o upload
        updateImages.add(url);
      }
    }
//SE UMA IMAGEM ORIGINAL NÃO ESTÁ EM NOVAS IMAGENS ENTÃO APAGA ESTA IMAGEM DO STORAGE
    for(final image in images){
      if(!newImages.contains(image) && image.contains('firebase')){ //tem q verificar se tem firebase no nome senõ gera exceção...
        try {
          final ref = await storage.getReferenceFromUrl(image);
          await ref.delete();
        } catch (e){
          debugPrint('Falha ao deletar $image');
        }
      }
    }

    await firestoreRef.update({'images': updateImages});//ATUALIZA AS IMAGENS PARA O PRODUTO

    images = updateImages; //para a variável images que é local ficar com o mesmo valor da que está no firebase

    loading = false;

  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, description: $description, images: $images, sizes: $sizes, newImages: $newImages}';
  }

}
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/models/section_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class Section extends ChangeNotifier { //modelo que pega uma seçao da home

  String name;
  String type;
  List<SectionItem> items;
  String _error;
  String get error => _error;
  String id;
  List<SectionItem> originalItems;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;//instancia para o bd
  final FirebaseStorage storage = FirebaseStorage.instance; //instancia para o sorage >> guardar as fotos

  DocumentReference get firestoreRef => firestore.doc('home/$id');
  StorageReference get storageRef => storage.ref().child('home/$id'); //cria uma pasta home no storage com subpasta igual o id da imagem

  Section({this.id, this.name, this.type, this.items}){
    items = items ?? []; //se items for nulo então recebe vazio para n ter erro... items é conteudo depois das modificaçoes
    originalItems = List.from(items);// original é conteudo antes da mdificação
  }

  Section.fromDocument(DocumentSnapshot document){
    id = document.id;
    name = document.data()['name'] as String;
    type = document.data()['type'] as String;
    items = (document.data()['items'] as List).map(
            (i) => SectionItem.fromMap(i as Map<String, dynamic>)).toList();
  }

  Future<void> delete() async {
    await firestoreRef.delete(); //deleta no bd primeiro
    for(final item in items){ //deleta as imagens depois
      if((item.image as String).contains('firebase')) {  //tem q verificar se tem firebase no nome senõ gera exceção...
        try { //se for imagem do google
          final ref = await storage.getReferenceFromUrl(
              item.image as String
          );
          await ref.delete();
          // ignore: empty_catches
        } catch (e) {}
      }
    }
  }



  Future<void> save(int pos) async {
    final Map<String, dynamic> data = {
      'name': name,
      'type': type,
      'pos': pos,
    };

    if(id == null){ //se o id for nulo e pq e uma seção criada agora, ainda sem salvar no firebase. vai entao salvar no fiebase para pegar um id
      final doc = await firestore.collection('home').add(data);
      id = doc.id;
    } else {
      await firestoreRef.update(data);
    }

    for(final item in items){
      if(item.image is File){ //se for file é pq foi inserido agora, entao tem q salvar no firebase
        final StorageUploadTask task = storageRef.child(Uuid().v1()) //uid cria um nome aleatorio para a imagem
            .putFile(item.image as File);
        final StorageTaskSnapshot snapshot = await task.onComplete;
        final String url = await snapshot.ref.getDownloadURL() as String; //pega a url reem inserida para salvar no bd depois
        item.image = url;
      }
    }
//verificar se algum item foi excluido em tempod e execução depois de vir do firebase. se sim, exclui a imagem do firebase
    for(final original in originalItems){
      if(!items.contains(original)
          && (original.image as String).contains('firebase')){ //se não contêm é pq foi editado
        try { //tem imagem da internet, para não dar erro na deleção...
          final ref = await storage.getReferenceFromUrl(
              original.image as String
          );
          await ref.delete();
          // ignore: empty_catches
        } catch (e){}
      }
    }

    final Map<String, dynamic> itemsData = {
      'items': items.map((e) => e.toMap()).toList()
    };

    await firestoreRef.update(itemsData);

  }

  bool valid(){
    if(name == null || name.isEmpty){
      error = 'Título inválido';
    } else if(items.isEmpty){
      error = 'Insira ao menos uma imagem';
    } else {
      error = null;
    }
    return error == null;
  }

  set error(String value){
    _error = value;
    notifyListeners();
  }

  void removeItem(SectionItem item){
    items.remove(item);
    notifyListeners();
  }

  void addItem(SectionItem item){
    items.add(item);
    notifyListeners();
  }

  Section clone(){
    return Section(
      id: id,
      name: name,
      type: type,
      items: items.map((e) => e.clone()).toList(), //se passar items=items direto ele passa a referência, não os valores
    );
  }

  @override
  String toString() {
    return 'Section{name: $name, type: $type, items: $items}';
  }

}
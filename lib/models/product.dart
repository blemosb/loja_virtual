import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/models/item_size.dart';
import 'package:flutter/cupertino.dart';

class Product extends ChangeNotifier { //model do produto

  String id;
  String name;
  String description;
  List<String> images;
  List<ItemSize> sizes;

  Product({this.id, this.name, this.description, this.images, this.sizes}){
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
    );
  }

  Product.fromDocument(DocumentSnapshot document){  //le um produto do firebase
    id = document.id;
    name = document.data()['name'] as String;
    description = document.data()['description'] as String;
    images = List<String>.from(document.data()['images'] as List<dynamic>);
    sizes = (document.data()['sizes'] as List<dynamic> ?? []).map( //se nao tiver tamanho no firebase, atribui uma lista vazia
            (s) => ItemSize.fromMap(s as Map<String, dynamic>)).toList();

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
    return totalStock > 0;
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
      if(size.price < lowest && size.hasStock)
        lowest = size.price;
    }
    return lowest;
  }

}
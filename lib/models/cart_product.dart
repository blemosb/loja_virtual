import 'package:flutter/cupertino.dart';
import "package:loja_virtual/models/product.dart";
import 'package:loja_virtual/models/item_size.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartProduct extends ChangeNotifier { //model do item do carrinho

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String productId;
  int quantity;
  String size;
  String id; //id do item do carrinho

  num fixedPrice;

  Product _product;
  Product get product => _product;
  set product(Product value){
    _product = value;
    notifyListeners();
  }

  Map<String, dynamic> toOrderItemMap(){
    return {
      'pid': productId,
      'quantity': quantity,
      'size': size,
      'fixedPrice': fixedPrice ?? unitPrice, //se nao tiver preço setado usa o unitPrice
    };
  }

  CartProduct.fromMap(Map<String, dynamic> map){
    productId = map['pid'] as String;
    quantity = map['quantity'] as int;
    size = map['size'] as String;
    fixedPrice = map['fixedPrice'] as num;

    firestore.document('products/$productId').get().then(
            (doc) {
          product = Product.fromDocument(doc);
        }
    );
  }

  CartProduct.fromProduct(this._product){
    productId = product.id;
    quantity = 1;
    size = product.selectedSize.name;
  }


  CartProduct.fromDocument(DocumentSnapshot document){ //pega um item do carrinho no firebase
    id = document.id; //id do item do carrinho
    productId = document.data()['pid'] as String;
    quantity = document.data()['quantity'] as int;
    size = document.data()['size'] as String;

    firestore.doc('products/$productId').get().then(
            (doc) {
          product = Product.fromDocument(doc);
        } //pega as informaçoes do produto que está inserido no item do carrinho para o preç sempre vir atualizado. por isso o preço n é armazenado no carrinho
    );
  }

  num get totalPrice => unitPrice * quantity;

  ItemSize get itemSize {
    if(product == null) return null;
    return product.findSize(size);
  }

  num get unitPrice {
    if(product == null) return 0;
    return itemSize?.price ?? 0;
  }

  Map<String, dynamic> toCartItemMap(){ //funçao que transforma um cartproduct em um map para poder escrever no firebase
    return {
      'pid': productId,
      'quantity': quantity,
      'size': size,
    };
  }

  bool get hasStock {
    final size = itemSize;
    if(size == null) return false;
    return size.stock >= quantity;
  }

  bool stackable(Product product){
    return product.id == productId && product.selectedSize.name == size;
  }

  void increment(){
    quantity++;
    notifyListeners();
  }

  void decrement(){
    quantity--;
    notifyListeners();
  }

}




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

  Product product;

  CartProduct.fromProduct(this.product){
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
          notifyListeners(); //para qdo entrar pela primeira vez no carrinho já vir cm os precos
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




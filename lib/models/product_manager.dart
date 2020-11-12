import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:loja_virtual/screens/edit_product/edit_product_screen.dart';

class ProductManager extends ChangeNotifier{

  String _search = "";
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Product> allProducts = [];

  ProductManager(){
    _loadAllProducts();
  }

  String get search => _search;

  set search(String value){
    _search = value;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    final List<Product> filteredProducts = [];

    if(_search.isEmpty){
      filteredProducts.addAll(allProducts);
    } else {
      filteredProducts.addAll(
          allProducts.where(
                  (p) => p.name.toLowerCase().contains(search.toLowerCase())
          )
      );
    }

    return filteredProducts;
  }

  Future<void> _loadAllProducts() async{
    final QuerySnapshot snapProducts = await firestore.collection("products").get();
    allProducts = snapProducts.docs.map(
        (d) => Product.fromDocument(d)).toList();
    notifyListeners();
  }

  Product findProductById(String id){
    try {
      return allProducts.firstWhere((p) => p.id == id);
    } catch (e){
      return null;
    }
  }

}

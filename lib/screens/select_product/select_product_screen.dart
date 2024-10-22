import 'package:flutter/material.dart';
import 'package:loja_virtual/models/product_manager.dart';
import 'package:provider/provider.dart';

class SelectProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vincular Produto'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Consumer<ProductManager>( //para pegar todos os produtos disponiveis
        builder: (_, productManager, __){
          return ListView.builder(
            itemCount: productManager.allProducts.length,
            itemBuilder: (_, index){
              final product = productManager.allProducts[index]; //allproducts é uma variavel de productmanager
              return ListTile(
                leading: Image.network(product.images.first),
                title: Text(product.name),
                subtitle: Text('R\$ ${product.basePrice.toStringAsFixed(2)}'),
                onTap: (){
                  Navigator.of(context).pop(product); //fecha a tela e passa o produto como parâmetro para a tela original...
                },
              );
            },
          );
        },
      ),
    );
  }
}
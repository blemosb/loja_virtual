import 'package:flutter/material.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:loja_virtual/models/product_manager.dart';

class DeleteProductDialog extends StatelessWidget {

  DeleteProductDialog(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    ProductManager pManager = new ProductManager(product: this.product);
    return AlertDialog(
      title: Text('Apagar ${product.name}?'),
      content: const Text('Esta ação não poderá ser defeita!'),
      actions: <Widget>[
        FlatButton(
          onPressed: (){
            pManager.delete(product);
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/products');
          },
          textColor: Colors.red,
          child: const Text('Excluir Produto'),
        ),
      ],
    );
  }
}
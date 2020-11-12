import 'package:flutter/material.dart';
import 'package:loja_virtual/models/product.dart';

class ProductListTile extends StatelessWidget {

  final Product product;

  const ProductListTile(this.product);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/product', arguments: product); //se clicar no card abre o detalhe do produto
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4)
        ),
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(8),
          child: Row( //row é horizontal
            children: <Widget> [
                AspectRatio( //aspect rtio de 1 deixa uma imagem quadrada
                    aspectRatio: 1,
                    child: Image.network(product.images.first),
                ),
              const SizedBox(width: 16,),
              Expanded( //pega o espaco q sobrou na row
                child: Column( //column é vertical
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, //espalaha para usar o espaço vertical
                  children: <Widget> [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'A partir de',
                        style: TextStyle(
                          color:  Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      'R\$ 19,90',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

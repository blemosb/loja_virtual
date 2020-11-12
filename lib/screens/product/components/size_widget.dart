import 'package:flutter/material.dart';
import 'package:loja_virtual/models/items_size.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:provider/provider.dart';

class SizeWidget extends StatelessWidget { //mostrar opçoes de tamanho embaixo da tela

  const SizeWidget({this.size});

  final ItemSize size;

  @override
  Widget build(BuildContext context) {

    final product = context.watch<Product>(); //nao utilizou o consumer pq ele e utilizado qdo quer dar um rebuilder em patte da tela...
    final selected = size == product.selectedSize; //size é passado por parametro pela tela de detalhe do produto. no inicio nao tem selecao
                                                    //durante o rebuilder selected pega o tamanho clicado em onTape do gesture

    Color color;
    if(!size.hasStock) //se nao tem estoque
      color = Colors.red.withAlpha(50);
    else if(selected) //se tem estoque e esta selecionado
      color = Theme.of(context).primaryColor;
    else // se tem estoque e nao esta selecionado
      color = Colors.black;

    return GestureDetector(
      onTap: (){
        if (product.selectedSize!= null){ //caso esteja selecionado, se clicar no mesmo tira a seleçao
          product.selectedSize = null;
        }
        else {
          if(size.hasStock){ //se nao estiver selecionado e tiver estoque, seleciona
            product.selectedSize = size;  //qdo clicar selectsize gera um rebuilder na tela
          }
        }

      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: !size.hasStock ? Colors.red.withAlpha(50) : Colors.black45
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, //ocupa a minima largura possivel
          children: <Widget>[
            Container(
              color: color, //cor de fundo do P M ou G
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text( //nome
                size.name,
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text( //preço
                'R\$ ${size.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
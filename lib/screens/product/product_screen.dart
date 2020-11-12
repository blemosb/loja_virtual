import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:loja_virtual/models/cart_manager.dart';

import 'components/size_widget.dart';

class ProductScreen extends StatelessWidget { //tela de detalhamento do produto

  const ProductScreen(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return ChangeNotifierProvider.value( //criou o provider aqui para o produto ficar disponível apenas nesta tela
      value: product, //usou .value porque o produto já está definido na classe
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.name),
          centerTitle: true,
          actions: <Widget>[
            Consumer<UserManager>(
              builder: (_, userManager, __){
                if(userManager.adminEnabled){
                  return IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: (){
                      Navigator.of(context)
                          .pushReplacementNamed('/edit_product');
                    },
                  );
                } else {
                  return Container();
                }
              },
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: ListView(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.3, //deixa a imagem quadrada. poderia ser trocado por um sizedBox de altura fixa ou poderia colocar o seguinte código
              child: Carousel(  //images: product.images.map((url) {return Image.network(url, fit: BoxFit.contain);}).toList(), e alterar o aspectrario
                images: product.images.map((url){
                  return Image.network(url, fit: BoxFit.contain);  //NetworkImage(url);
                }).toList(),
                dotSize: 4, // tamanho do ponto do carrosel que serve para arrastar as imagens
                dotSpacing: 15, //espaço entre os pontos
                dotBgColor: Colors.transparent, //tira uma barra marrom q fica na base da imagem
                dotColor: primaryColor,
                autoplay: false, //nao troca a imagem sozinha
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    product.name,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'A partir de',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    'R\$ 19.99',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      'Descrição',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  Text(
                    product.description,
                    style: const TextStyle(
                        fontSize: 16
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      'Tamanho',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  Wrap( //vai preenchendo horizontalmente até chegar ao final da tela. se chegar vai para baixo
                    spacing: 8,  //espaçamento lateral entre os items
                    runSpacing: 8, // espaçamento vertical
                    children: product.sizes.map((s){
                      return SizeWidget(size: s);
                    }).toList(),
                  ),
                  SizedBox(height: 20,),
                  if(product.hasStock)
                      Consumer2 <UserManager,Product>(  //rastreia duas classes ao mesmo tempo
                        builder: (_,userManager, product, __){
                          return SizedBox(
                            height: 44,
                            child: RaisedButton(
                              onPressed: product.selectedSize != null ? () {
                                if (userManager.isLoggedIn){
                                  context.read<CartManager>().addToCart(product);
                                  Navigator.of(context).pushNamed('/cart');
                                }
                                else {
                                  Navigator.of(context).pushNamed('/login');
                                }
                              } : null, //se nao tiver nenhum tam selecionado desabilita o botao
                              color:  primaryColor,
                              textColor:  Colors.white,
                              child: Text(
                                userManager.isLoggedIn
                                    ? 'Adicionar ao Carrinho'
                                    : 'Entre para Comprar',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          );
                        },
                      )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
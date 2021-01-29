import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:loja_virtual/models/cart_manager.dart';

import 'components/size_widget.dart';

class ProductScreen extends StatelessWidget { //tela de detalhamento do produto

  const ProductScreen(this.product); //argumento passado no flutter é declarado no construtor

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
          actions: <Widget>[ //as actions são os botoes que aparecem na appbar
            Consumer<UserManager>( //monitora userManager. so vai aparecer opcao se for admin
              builder: (_, userManager, __){
                if(userManager.adminEnabled && !product.deleted){
                  return IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: (){
                      Navigator.of(context).pushReplacementNamed(
                          '/edit_product',
                          arguments: product
                      );
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
                    'R\$ ${product.basePrice.toStringAsFixed(2)}',
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
                  if(product.deleted)
          Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        'Este produto não está mais disponível',
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.red
        ),
      ),
          )
                  else
                    ...[ //expansão para mais de uma instrução no else, no caso padding e wrap
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          'Tamanhos',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.sizes.map((s){
                          return SizeWidget(size: s);
                        }).toList(),
                      ),
                    ],
                  const SizedBox(height: 20,),
                  if(product.hasStock)
                    Consumer2<UserManager, Product>(
                      builder: (_, userManager, product, __){
                        return SizedBox(
                          height: 44,
                          child: RaisedButton(
                            onPressed: product.selectedSize != null ? (){
                              if(userManager.isLoggedIn){
                                context.read<CartManager>().addToCart(product);
                                Navigator.of(context).pushNamed('/cart');
                              } else {
                                Navigator.of(context).pushNamed('/login');
                              }
                            } : null,
                            color: primaryColor,
                            textColor: Colors.white,
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
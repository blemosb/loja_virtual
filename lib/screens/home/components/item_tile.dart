import 'package:flutter/material.dart';
import 'package:loja_virtual/models/product_manager.dart';
import 'package:loja_virtual/models/section_item.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:io';
import 'package:loja_virtual/models/home_manager.dart';
import 'package:loja_virtual/models/section.dart';
import 'package:loja_virtual/models/product.dart';

class ItemTile extends StatelessWidget { //foto dos produtos na tela inicial

  const ItemTile(this.item);

  final SectionItem item;

  @override
  Widget build(BuildContext context) {
    final homeManager = context.watch<HomeManager>();
    return GestureDetector(
      onTap: (){
        if(item.product != null){
          final product = context.read<ProductManager>()
              .findProductById(item.product); //productmanager sempre tem todos os produtos carregados na memória
          if(product != null){
            Navigator.of(context).pushNamed('/product', arguments: product);
          }
        }
      },
      onLongPress: homeManager.editing ? (){
        showDialog(
            context: context,
            builder: (_){
              final product = context.read<ProductManager>().findProductById(item.product); //pega o produto selecionado no momento
              return AlertDialog(
                title: const Text('Editar Item'),
                content: product != null //se o produto existir exibe na tela(se a imagem estiver vinculado a um produto)...
                                        // caso contrario retorna nulo
                    ? ListTile(
                  contentPadding: EdgeInsets.zero, //tira os espaços laterais, superior e inferior
                  leading: Image.network(product.images.first), //item que fica do lardo esquerdo de um listtile
                  title: Text(product.name),
                  subtitle: Text('R\$ ${product.basePrice.toStringAsFixed(2)}'),
                )
                    : null,
                actions: <Widget>[
                  FlatButton(
                    onPressed: (){
                      context.read<Section>().removeItem(item); //read usa dentro de fç...fora usa watch
                      Navigator.of(context).pop();
                    },
                    textColor: Colors.red,
                    child: const Text('Excluir'),
                  ),
                  FlatButton(
                    onPressed: () async {
                      if(product != null){ //se clicar  no botao e tiver produto então desnvicula
                        item.product = null;
                      } else { //senão abre uma tela com produtos para serem vinculados...
                        final Product product = await Navigator.of(context) //recebe um product de volta qdo fechar a outra tela
                                                                            // await senão a tela abre e já fecha logo abaixo no pop
                            .pushNamed('/select_product') as Product;
                        item.product = product?.id; //se o produto nao for nulo pega o valor de product.id, senão ja passa o nulo
                      }
                      Navigator.of(context).pop(); //fecha a tela de alerta
                    },
                    child: Text( //se já existe produto mostra botão para desvincular se não para vincular...
                        product != null
                            ? 'Desvincular'
                            : 'Vincular'
                    ),
                  ),
                ],
              );
            }
        );
      } : null,
      child: AspectRatio(
        aspectRatio: 1,
        child: item.image is String //e a imagem vier do firebase é string
            ? FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: item.image as String,
          fit: BoxFit.cover,
        )
            : Image.file(item.image as File, fit: BoxFit.cover,), //senão foi escolhido em tempo de execuçao e é um file
      ),
    );
  }
}
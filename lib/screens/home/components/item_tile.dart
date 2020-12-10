import 'package:flutter/material.dart';
import 'package:loja_virtual/models/product_manager.dart';
import 'package:loja_virtual/models/section_item.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:io';
import 'package:loja_virtual/models/home_manager.dart';
import 'package:loja_virtual/models/section.dart';

class ItemTile extends StatelessWidget {

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
              return AlertDialog(
                title: const Text('Editar Item'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: (){
                      context.read<Section>().removeItem(item); //read usa dentro de fç...fora usa watch
                      Navigator.of(context).pop();
                    },
                    textColor: Colors.red,
                    child: const Text('Excluir'),
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
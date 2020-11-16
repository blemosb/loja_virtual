import 'package:flutter/material.dart';
import 'package:loja_virtual/models/product.dart';
import 'dart:io';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:loja_virtual/screens/edit_product/components/image_source_sheet.dart';
import 'package:flutter/cupertino.dart';

class ImagesForm extends StatelessWidget {
  const ImagesForm(this.product);
  final Product product;
  @override
  Widget build(BuildContext context) {
    return FormField<List<dynamic>>(
      initialValue: List.from(product.images), //faz um copia da lista de imagens inicial para qdo houver mudanças nao alterar a original
      builder: (state){ //state pega o valor de images. images é o valor de entrada. depois pode ser modificada em state abaixo
        void onImageSelected(File file){
          state.value.add(file);
          state.didChange(state.value);
          Navigator.of(context).pop();
        }
        return AspectRatio(
          aspectRatio: 1.3,
          child: Carousel(
            images: state.value.map<Widget>((image){ //image receberá cada item da lista de state
              return Stack( //para um widget ficar sobrepondo o outro. se nao precisasse disso, retornaria direto image
                fit: StackFit.expand, //expande todos os widgets para ocupar toda ára do stack
                children: <Widget>[
                  if(image is String) //se ela for string e pq veio do firebase
                    Image.network(image, fit: BoxFit.cover,) //imagem ocupar o widget inteiro
                  else
                    Image.file(image as File, fit: BoxFit.cover,), //import dart.io
                  Align( //cria um botão alinhado superior a direita para remover a imagem atual
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.remove),
                      color: Colors.red,
                      onPressed: (){
                        state.value.remove(image);
                        state.didChange(state.value); //avisa que teve uma mudança no estado para que a tela seja redesenhada sem a imagem
                      },
                    ),
                  )
                ],
              );
            }).toList()..add( //adiciona uma imagem à lista já existente
                Material( //para dar efeito no botão qdo clicar
                  color: Colors.grey[100],
                  child: IconButton(
                    icon: Icon(Icons.add_a_photo),
                    color: Theme.of(context).primaryColor,
                    iconSize: 50,
                    onPressed: (){
                      if(Platform.isAndroid)
                        showModalBottomSheet(
                            context: context,
                            builder: (_) => ImageSourceSheet(
                        onImageSelected: onImageSelected,
                      )
                      );
                      else
                      showCupertinoModalPopup(
                      context: context,
                      builder: (_) => ImageSourceSheet( //passa como parâmetro uma função
                      onImageSelected: onImageSelected, //essa segunda é a do void
                      )
                      );

                    },
                  ),
                )
            )
            ,
            dotSize: 4,
            dotSpacing: 15,
            dotBgColor: Colors.transparent,
            dotColor: Theme.of(context).primaryColor,
            autoplay: false,
          ),
        );
      },
    );
  }
}
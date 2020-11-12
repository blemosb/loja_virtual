import 'package:flutter/material.dart';
import 'package:loja_virtual/common/custom_drawer/custom_drawer.dart';
import 'package:loja_virtual/models/home_manager.dart';
import 'package:loja_virtual/screens/home/components/section_list.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/screens/home/components/section_staggered.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: Stack(
        children: <Widget>[
          Container( //muda a caro de bg da tela
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: const [
                      Color.fromARGB(255, 211, 118, 130),
                      Color.fromARGB(255, 253, 181, 168)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter
                )
            ),
          ),
          CustomScrollView( //efeito na scrollview
            slivers: <Widget>[
              SliverAppBar( //cria uma appbar flutuante, ou seja, ela desaparece e aparece a cada vez que a tela é rolada
                snap: true, //se subir a barra só um pouco a appbar reaparece
                floating: true,
                elevation: 0, //tira a sombra da appbar para a cor nao ficar diferente do contaner
                backgroundColor: Colors.transparent, //appbar transparente para ficar da mesma cor do container
                flexibleSpace: const FlexibleSpaceBar( //espaco que appbar ocupará
                  title: Text('Loja do Bruno'),
                  centerTitle: true,
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).pushNamed('/cart'),
                  ),
                ],
              ),
                Consumer<HomeManager>(
                  builder: (_, homeManager, __){
                   final List<Widget> children = homeManager.sections.map<Widget>( //tranforma uma lista de seçoes em widget. pode sr staggled ou list
                     (section) {
                        switch(section.type){
                         case 'List':
                          return SectionList(section);
                          case 'Staggered':
                            return SectionStaggered(section);
                        default:
                           return Container();
                       }
                     }
                 ).toList();

                return SliverList(
                  delegate: SliverChildListDelegate(children),
                );
                },
             ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:loja_virtual/common/custom_drawer/custom_drawer.dart';
import 'package:loja_virtual/models/home_manager.dart';
import 'package:loja_virtual/screens/home/components/section_list.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/screens/home/components/section_staggered.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:loja_virtual/screens/home/components/add_section_widget.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: Stack(
        children: <Widget>[
          Container( //muda a cor de bg da tela
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: const [
                      Color.fromARGB(255, 54, 0, 51),
                      Color.fromARGB(255, 11, 135, 147
                      )
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
                  Consumer2<UserManager, HomeManager>(
                    builder: (_, userManager, homeManager, __){
                      if(userManager.adminEnabled && !homeManager.loading) { //se estiver salvando esconde o botão de editar
                        if(homeManager.editing){
                          return PopupMenuButton(
                            onSelected: (e){
                              if(e == 'Salvar'){
                                homeManager.saveEditing();
                              } else {
                                homeManager.discardEditing();
                              }
                            },
                            itemBuilder: (_){
                              return ['Salvar', 'Descartar'].map((e){
                                return PopupMenuItem(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList();
                            },
                          );
                        } else {
                          return IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: homeManager.enterEditing, //o metodo editar chamada notifylistener que faz o builder ser reconstruuido
                                                                 //assim entra na edição acima
                          );
                        }
                      } else return Container();
                    },
                  ),
                ],
              ),
                Consumer<HomeManager>( //começa o desenho de toda tela
                  builder: (_, homeManager, __){
                    if(homeManager.loading){ //mostra o circulo de carregamento
                      return SliverToBoxAdapter(
                        child: LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          backgroundColor: Colors.transparent,
                        ),
                      );
                    }

                    final List<Widget> children = homeManager.sections.map<Widget>( //transforma uma lista de seçoes em widget.
                                                                                   // pode ser staggled ou list
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

                if(homeManager.editing) //se estiver editando cria um novo widget na tela
                  children.add(AddSectionWidget(homeManager));

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
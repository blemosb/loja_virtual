  import 'package:flutter/material.dart';
  import 'package:loja_virtual/common/custom_drawer/custom_drawer_header.dart';
  import 'package:loja_virtual/common/custom_drawer/drawer_title.dart';
  import 'package:loja_virtual/models/user_manager.dart';
  import 'package:provider/provider.dart';
  class CustomDrawer extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Drawer(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color.fromARGB(255, 203, 236, 241),
                  Colors.white,],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                )
              ),
            ),
            ListView(
                children: <Widget>[
                  CustomDrawerHeader(), //chama o cabecalho do menu
                  const Divider(), //divide o cabecalho das opcoes
                  DrawerTitle(iconData: Icons.home, title: "Início", page: 0), //faz o link para a página criada em base screen
                  DrawerTitle(iconData: Icons.list, title: "Produtos", page: 1),
                  DrawerTitle(iconData: Icons.playlist_add_check, title: "Meus Pedidos", page: 2),
                  DrawerTitle(iconData: Icons.shopping_cart, title: "Meu Carrinho", page: 3),
                  DrawerTitle(iconData: Icons.location_on, title: "Lojas", page: 4),
                  Consumer<UserManager>( //somente para usuarios admin
                      builder: (_,userManager,__){
                        if(userManager.adminEnabled){
                          return Column(
                            children: [
                              const Divider(),
                              DrawerTitle(iconData: Icons.settings, title: "Usuarios", page: 5),
                              DrawerTitle(iconData: Icons.settings, title: "Pedidos", page: 6),
                            ],
                          );
                        }
                        else {
                          return Container(); //se nao for admin retorna um container vazio
                        }
                      }
                  ),
                  const Divider(), //divide o cabecalho para os créditos
                  DrawerTitle(iconData: Icons.contact_mail_outlined, title: "Contato", page: 7),
                ]
            ),
          ],
        ),
      );
    }
  }
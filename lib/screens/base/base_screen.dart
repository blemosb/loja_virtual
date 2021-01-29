import 'package:flutter/material.dart';
import 'package:loja_virtual/common/custom_drawer/custom_drawer.dart';
import 'package:loja_virtual/models/page_manager.dart';
import 'package:loja_virtual/screens/products/products_screen.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/screens/home/home_screen.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:loja_virtual/screens/admin_users/admin_users_screen.dart';
import 'package:loja_virtual/screens/orders/orders_screen.dart';
import 'package:loja_virtual/screens/admin_orders/admin_orders_screen.dart';
import 'package:flutter/services.dart';

class BaseScreen extends StatefulWidget { //controla página a ser exibida

  @override
  _BaseScreenState createState() => _BaseScreenState();
}


class _BaseScreenState extends State<BaseScreen> {
  final PageController pageController  = PageController();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => PageManager(pageController),
      builder: (context, snapshot) {
        return Consumer<UserManager>( //rastreia usuario para saber as opçoes que aparecem na tela
          builder: (_, userManager, __){
            return PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                HomeScreen(),
                ProductsScreen(),
               OrdersScreen(),
                Scaffold(
                  drawer: CustomDrawer(),
                  appBar: AppBar(
                    title: const Text('Home4'),
                  ),
                ),
                if(userManager.adminEnabled)
                  ...[ //esses 3 pontos cria uma list dentro da principal. no caso só cria se o usuário for admin
                    AdminUsersScreen(),
                   AdminOrdersScreen(),
                  ]
              ],
            );
          },
        );
      }
    );
  }
}
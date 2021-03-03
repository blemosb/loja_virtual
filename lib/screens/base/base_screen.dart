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
import 'package:loja_virtual/screens/stores/stores_screen.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';

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

    configFCM();
  }

  void configFCM(){
    final fcm = FirebaseMessaging();

    if(Platform.isIOS){
      fcm.requestNotificationPermissions(
          const IosNotificationSettings(provisional: true)
      );
    }

    fcm.configure(
      //aqui são as instruções que serão executadas depois que o usuário clicar na notificação e o app estiver fechado
        onLaunch: (Map<String, dynamic> message) async {
          print('onLaunch $message');
        },
        //executado qdo o aplicativo está em segundo plano e a notificação é clicada
        onResume: (Map<String, dynamic> message) async {
          print('onResume $message');
        },
        //executado qdo o aplicativo está aberto e a notificação é clicada
        onMessage: (Map<String, dynamic> message) async {
          showNotification(
            message['notification']['title'] as String,
            message['notification']['body'] as String,
          );
        }
    );
  }

  void showNotification(String title, String message){
    Flushbar(
      title: title,
      message: message,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.GROUNDED,
      isDismissible: true,
      backgroundColor: Theme.of(context).primaryColor,
      duration: const Duration(seconds: 5),
      icon: Icon(Icons.shopping_cart, color: Colors.white,),
    ).show(context);

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
                StoresScreen(),
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
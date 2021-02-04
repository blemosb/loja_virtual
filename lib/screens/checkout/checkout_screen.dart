import 'package:flutter/material.dart';
import 'package:loja_virtual/common/price_card.dart';
import 'package:loja_virtual/models/cart_manager.dart';
import 'package:loja_virtual/models/checkout_manager.dart';
import 'package:loja_virtual/screens/orders/orders_screen.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/screens/checkout/components/credit_card_widget.dart';

class CheckoutScreen extends StatelessWidget {
  //para criar uma snackbar
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<CartManager, CheckoutManager>(
      //sempre q tiver um update no cartManager da outro no checkotmanager
      create: (_) => CheckoutManager(), //no início cria um checkoutmanager
      //sempre q tiver update no cartManager ele passa o cartManager para o método updateCart no checkoutManager
      update: (_, cartManager, checkoutManager) =>
          checkoutManager..updateCart(cartManager),
      lazy: false,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text('Pagamento'),
          centerTitle: true,
        ),
        body: GestureDetector(
          child: Consumer<CheckoutManager>(
            builder: (_, checkoutManager, __) {
              if (checkoutManager.loading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        'Processando seu pagamento...',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16),
                      )
                    ],
                  ),
                );
              }

              return Form(
                key: formKey,
                child: ListView(
                  children: <Widget>[
                    CreditCardWidget(),
                    PriceCard(
                      buttonText: 'Finalizar Pedido',
                      onPressed: () {
                        if (formKey.currentState.validate()) {
                          print('enviar');
                          /*checkoutManager.checkout(
                              onStockFail: (e){
                                Navigator.of(context).popUntil(
                                        (route) => route.settings.name == '/cart');
                              },
                              onSuccess: (order){
                                Navigator.of(context).popUntil(
                                        (route) => route.settings.name == '/');
                                Navigator.of(context).pushNamed(
                                    '/confirmation',
                                    arguments: order
                                );
                              }
                          );*/
                        }
                      },
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

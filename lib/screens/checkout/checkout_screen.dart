import 'package:flutter/material.dart';
import 'package:loja_virtual/common/price_card.dart';
import 'package:loja_virtual/models/cart_manager.dart';
import 'package:loja_virtual/models/checkout_manager.dart';
import 'package:loja_virtual/screens/orders/orders_screen.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatelessWidget {
  //para criar uma snackbar
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<CartManager, CheckoutManager>( //sempre q tiver um update no cartManager da outro no checkotmanager
      create: (_) => CheckoutManager(), //no início cria um checkoutmanager
      //sempre q tiver update no cartManager ele passa o cartManager para o método updateCart no checkoutManager
      update: (_, cartManager, checkoutManager) => checkoutManager..updateCart(cartManager),
      lazy: false,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text('Pagamento'),
          centerTitle: true,
        ),
        body: Consumer<CheckoutManager>(
          builder: (_, checkoutManager, __){
            if(checkoutManager.loading){
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                    const SizedBox(height: 16,),
                    Text(
                      'Processando seu pagamento...',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16
                      ),
                    )
                  ],
                ),
              );
            }

            return ListView(
              children: <Widget>[
                PriceCard( //botão da tela final de pagamento
                  buttonText: 'Finalizar Pedido',
                  onPressed: (){
                    checkoutManager.checkout(
                        onStockFail: (e){ //vai dando pop nas telas até achar a /cart. para funcionar tem q declarar settings no main
                          Navigator.of(context).popUntil(
                                  (route) => route.settings.name == '/cart');
                        },
                        onSuccess: (order){ //depois de processar o pgto vai para a tela de pedidos e limpa a pilha de telas para não voltar para outra
                          //o modal embaixo é para qdo clicar no botão de voltar ir para a tela principal
                         /* Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => OrdersScreen(),
                            ),
                              ModalRoute.withName("/base")
                          );*/
                          Navigator.of(context).popUntil(
                                  (route) => route.settings.name == '/');
                          Navigator.of(context).pushNamed(
                              '/confirmation',
                              arguments: order
                          );
                        }
                    );
                  },
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
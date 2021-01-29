import 'package:flutter/material.dart';
import 'package:loja_virtual/models/cart_manager.dart';
import 'package:loja_virtual/screens/cart/components/cart_tile.dart';
import 'package:loja_virtual/screens/products/products_screen.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/common/price_card.dart';
import 'package:loja_virtual/common/empty_card.dart';
import 'package:loja_virtual/common/login_card.dart';

class CartScreen extends StatelessWidget { //tela para exibir o carrinho
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        centerTitle: true,
      ),
      body: Consumer<CartManager>(
        builder: (_, cartManager, __){
          //se não tiver logado, exibe uma tela de login
          if(cartManager.user == null){
            return LoginCard();
          }
//se não tiver item no carrinho exibe uma tela informando disso
          if(cartManager.items.isEmpty){
            return EmptyCard(
              iconData: Icons.remove_shopping_cart,
              title: 'Nenhum produto no carrinho!',
            );
          }

          return ListView(
            children: <Widget>[
              Column(
                children: cartManager.items.map(
                        (cartProduct) => CartTile(cartProduct)
                ).toList(),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (BuildContext context) => ProductsScreen()
                    ));
                  },
                  child: new Text(
                    'Adicionar mais itens ao carrinho',
                    style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  ),
                ],
              ),
              PriceCard( //widget criado para ser um card com o resumo do carrinho
                buttonText: 'Continuar para Entrega',
                onPressed: cartManager.isCartValid ? (){ //se o carrinho for válido executa a funçao senao passa null
                  Navigator.of(context).pushNamed('/address');
                } : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
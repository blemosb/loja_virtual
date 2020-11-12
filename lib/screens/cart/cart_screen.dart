import 'package:flutter/material.dart';
import 'package:loja_virtual/models/cart_manager.dart';
import 'package:loja_virtual/screens/cart/components/cart_tile.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/common/price_card.dart';

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
          return ListView(
            children: <Widget>[
              Column(
                children: cartManager.items.map(
                        (cartProduct) => CartTile(cartProduct)
                ).toList(),
              ),
              PriceCard( //widget criado para ser um card com o resumo do carrinho
                buttonText: 'Continuar para Entrega',
                onPressed: cartManager.isCartValid ? (){ //se o carrinho for válido executa a funçao senao passa null

                } : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
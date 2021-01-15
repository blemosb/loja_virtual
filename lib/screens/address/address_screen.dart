import 'package:flutter/material.dart';
import 'package:loja_virtual/common/price_card.dart';
import 'package:loja_virtual/models/cart_manager.dart';
import 'package:loja_virtual/screens/address/components/address_card.dart';
import 'package:provider/provider.dart';

class AddressScreen extends StatelessWidget { //tela da entrega onde são definidos os endereços, calculados a entrega e mostrado o resumo do pedido
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrega'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          AddressCard(), //mostra tela para definição do endereço e calcular a taxa de entrega
          Consumer<CartManager>( //
            builder: (_, cartManager, __){
              //tela para mostrar resumo do pedido e botão para direcionar para pgto
              return PriceCard(
                buttonText: 'Continuar para o Pagamento',
                //se tiver endereço e delivery mostrará o botão (está sendo passado por parâmetro agora), senão retorna nulo e o botão desabilita
                onPressed: cartManager.isAddressValid ? (){ //clica e vai para tela de checkout
                  Navigator.of(context).pushNamed('/checkout');
                } : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
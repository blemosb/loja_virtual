import 'package:flutter/material.dart';
import 'package:loja_virtual/screens/address/components/cep_input_field.dart';
import 'package:loja_virtual/models/cart_manager.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/models/address.dart';
import 'package:loja_virtual/screens/address/components/address_input_field.dart';

class AddressCard extends StatelessWidget {//primeira opção na tela do cep. label endereço de entrega e capo para digitar cep
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Consumer<CartManager>(
          builder: (_, cartManager, __){
            final address = cartManager.address ?? Address(); //quando entra address pode ser nulo, então instancia um novo para nao dar erro

            return Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Endereço de Entrega',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  CepInputField(address), //campo com label de cep e edit para cep com botão
                  AddressInputField(address),//tela com endereço retornado da api
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
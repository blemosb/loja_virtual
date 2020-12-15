import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:loja_virtual/models/cart_manager.dart';
import 'package:provider/provider.dart';

class CepInputField extends StatelessWidget { //tela para usuário digitar um cep. contem um ampo editave e um botão

  final TextEditingController cepController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField( //campo editavel para digitar cep
          controller: cepController,
          decoration: const InputDecoration(
              isDense: true, //diminui a altura do campo
              labelText: 'CEP',
              hintText: '12.345-678'
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, //apesar de abrir numeros, tb tem outros caracteres tipo hífen...aí filtra prá entrar numeros
            CepInputFormatter(), //passa o cep para o padrão brasileiro
          ],
          keyboardType: TextInputType.number,
          validator: (cep){
            if(cep.isEmpty)
              return 'Campo obrigatório';
            else if(cep.length != 10)
              return 'CEP Inválido';
            return null;
          },
        ),
        RaisedButton( //botão para buscar o cep
          onPressed: (){
            if(Form.of(context).validate()){
              context.read<CartManager>().getAddress(cepController.text); //função que buscará o cep da API
            }
          },
          textColor: Colors.white,
          color: primaryColor,
          disabledColor: primaryColor.withAlpha(100),
          child: const Text('Buscar CEP'),
        ),
      ],
    );
  }
}
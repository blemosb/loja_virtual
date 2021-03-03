import 'package:flutter/material.dart';
import 'package:loja_virtual/screens/checkout/components/card_text_field.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:loja_virtual/models/credit_card.dart';

class CardFront extends StatelessWidget {

  CardFront({this.numberFocus, this.dateFocus, this.nameFocus, this.finished, this.creditCard});

  final MaskTextInputFormatter dateFormatter = MaskTextInputFormatter(
      mask: '!#/####', filter: {'#': RegExp('[0-9]'), '!': RegExp('[0-1]')}
  );

  final VoidCallback finished; //qdo digitar o último campo da fremte do cartão para virar o mesmo

  final FocusNode numberFocus;
  final FocusNode dateFocus;
  final FocusNode nameFocus;
  final CreditCard creditCard;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 16,
      child: Container(
        height: 200,
        color: const Color(0xFF1B4B52),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  CardTextField(
                    initialValue: creditCard.number,
                    title: 'Número',
                    hint: '0000 0000 0000 0000',
                    textInputType: TextInputType.number,
                    bold: true,
                    inputFormatters: [
                      // ignore: deprecated_member_use
                      FilteringTextInputFormatter.digitsOnly,
                      CartaoBancarioInputFormatter() //vem do package brasil_fields
                    ],
                    validator: (number){
                      if(number.length != 19) return 'Inválido';
                      else if(detectCCType(number) == CreditCardType.unknown)
                        return 'Inválido';
                      return null;
                    },
                    onSubmitted: (_){ //botão clicado no teclado. qdo termina vai para o focus da data
                      dateFocus.requestFocus();
                    },
                    focusNode: numberFocus,
                    onSaved: creditCard.setNumber,
                  ),
                  CardTextField(
                    initialValue: creditCard.expirationDate,
                    title: 'Validade',
                    hint: '11/2020',
                    textInputType: TextInputType.number,
                    inputFormatters: [dateFormatter],
                    validator: (date){
                      if(date.length != 7) return 'Inválido';
                      return null;
                    },
                    onSubmitted: (_){
                      nameFocus.requestFocus();
                    },
                    focusNode: dateFocus,
                    onSaved: creditCard.setExpirationDate,
                  ),
                  CardTextField(
                    initialValue: creditCard.holder,
                    title: 'Títular',
                    hint: 'João da Silva',
                    textInputType: TextInputType.text,
                    bold: true,
                    validator: (name){
                      if(name.isEmpty) return 'Inválido';
                      return null;
                    },
                    onSubmitted: (_){
                      finished(); //chama fç para virar o cartão
                    },
                    focusNode: nameFocus,
                    onSaved: creditCard.setHolder,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
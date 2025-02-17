import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/screens/checkout/components/card_back.dart';
import 'package:loja_virtual/screens/checkout/components/card_front.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:loja_virtual/models/credit_card.dart';

class CreditCardWidget extends StatefulWidget { //FULL PARA OS FOCUS ABAIXO NÃO SEREM PERDIDOS E criados novamente

  const CreditCardWidget(this.creditCard);

  final CreditCard creditCard;

  @override
  _CreditCardWidgetState createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget> {
  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  final FocusNode numberFocus = FocusNode();
  final FocusNode dateFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();
  final FocusNode cvvFocus = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context){ //fç para customizar um teclado para o ios
    return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.IOS, //só mostra ios. poderia mostrar android mas queremos usar o padrão do android
        keyboardBarColor: Colors.grey[200],
        actions: [
          KeyboardActionsItem(focusNode: numberFocus, displayDoneButton: false),
          KeyboardActionsItem(focusNode: dateFocus, displayDoneButton: false),
          KeyboardActionsItem(
              focusNode: nameFocus,
              toolbarButtons: [ //adiciona botão de continuar no final
                    (_){
                  return GestureDetector(
                    onTap: (){
                      cardKey.currentState.toggleCard();
                      cvvFocus.requestFocus();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text('CONTINUAR'),
                    ),
                  );
                }
              ]
          ),
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardActions(
      config: _buildConfig(context),
      autoScroll: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            FlipCard(
              key: cardKey,
              direction: FlipDirection.HORIZONTAL,
              speed: 700,
              flipOnTouch: false, //desabilita clicar no cartão e virar
              front: CardFront(
                creditCard: widget.creditCard,
                numberFocus: numberFocus,
                dateFocus: dateFocus,
                nameFocus: nameFocus,
                finished: (){
                  cardKey.currentState.toggleCard();
                  cvvFocus.requestFocus();
                },
              ),
              back: CardBack(
                creditCard: widget.creditCard,
                cvvFocus: cvvFocus,
              ),
            ),
            FlatButton(
              onPressed: (){
                cardKey.currentState.toggleCard();
              },
              textColor: Colors.white,
              padding: EdgeInsets.zero,
              child: const Text('Virar cartão'),
            )
          ],
        ),
      ),
    );
  }
}
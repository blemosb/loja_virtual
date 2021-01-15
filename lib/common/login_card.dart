import 'package:flutter/material.dart';

class LoginCard extends StatelessWidget { //tela exibida solicitado login do usuário
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon( //icone com avatar de usuário
                Icons.account_circle,
                color: Theme.of(context).primaryColor,
                size: 100,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text( //msg solicitando o login do usuário
                  'Faça login para acessar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              RaisedButton( //botão para tela do login
                onPressed: (){
                  Navigator.of(context).pushNamed('/login');
                },
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: const Text(
                    'LOGIN'
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
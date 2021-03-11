import 'package:flutter/material.dart';
import 'package:loja_virtual/helpers/validator.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:loja_virtual/models/usuario.dart';
import 'package:provider/provider.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'dart:io';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Entrar'),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/signup');
            },
            textColor: Colors.white,
            child: const Text(
              'CRIAR CONTA',
              style: TextStyle(fontSize: 14),
            ),
          )
        ],
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: formKey,
            child: Consumer<UserManager>(
              builder: (_, userManager, child) {
                if(userManager.loadingGoogle){
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  children: <Widget>[
                    TextFormField(
                      controller: emailController,
                      enabled: !userManager.loading,
                      decoration: const InputDecoration(hintText: 'E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: (email) {
                        if (!emailValid(email)) return 'E-mail inválido';
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: passController,
                      enabled: !userManager.loading,
                      decoration: const InputDecoration(hintText: 'Senha'),
                      autocorrect: false,
                      obscureText: true,
                      validator: (pass) {
                        if (pass.isEmpty || pass.length < 6)
                          return 'Senha inválida';
                        return null;
                      },
                    ),
                    child,
                    Container(
                      height: 40.0,
                      child: RaisedButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, //diminui o espaçamento vertical entre os botões
                        onPressed: userManager.loading
                            ? null
                            : () {
                                if (formKey.currentState.validate()) {
                                  userManager.signIn(
                                      user: Usuario(
                                          email: emailController.text,
                                          senha: passController.text),
                                      onFail: (e) {
                                        scaffoldKey.currentState
                                            .showSnackBar(SnackBar(
                                          content: Text('Falha ao entrar: $e'),
                                          backgroundColor: Colors.red,
                                        ));
                                      },
                                      onSuccess: () {
                                        Navigator.of(context).pop();
                                      });
                                }
                              },
                        color: Theme.of(context).primaryColor,
                        disabledColor:
                            Theme.of(context).primaryColor.withAlpha(100),
                        textColor: Colors.white,
                        child: userManager.loading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(fontSize: 15),
                              ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 40.0,
                      child: SignInButton( //LOGIN GOOGLE
                        Buttons.GoogleDark,
                        text: 'Entrar com Google',
                        onPressed: () {
                          userManager.googleLogin(
                              onFail: (e){
                                scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      content: Text('Falha ao entrar: $e'),
                                      backgroundColor: Colors.red,
                                    )
                                );
                              },
                              onSuccess: (){
                                userManager.loadCurrentUser();
                                Navigator.of(context).pop();
                              }
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 40.0,
                      child: FutureBuilder(
                        future: userManager.appleSignInAvailable,
                        builder: (context, snapshot) {
                          if (snapshot.data == true) {
                            return SignInButton( //LOGIN APPLE
                              Buttons.AppleDark,
                              text: 'Entrar com Apple',
                              onPressed: () {
                                userManager.googleLogin(
                                    onFail: (e){
                                      scaffoldKey.currentState.showSnackBar(
                                          SnackBar(
                                            content: Text('Falha ao entrar: $e'),
                                            backgroundColor: Colors.red,
                                          )
                                      );
                                    },
                                    onSuccess: (){
                                      userManager.loadCurrentUser();
                                      Navigator.of(context).pop();
                                    }
                                );
                              },
                            );
                          } else {
                            return SignInButton( //LOGIN FACEBOOK
                              Buttons.AppleDark,
                              text: 'Entrar com Apple',
                              onPressed: () {
                                userManager.googleLogin(
                                    onFail: (e){
                                      scaffoldKey.currentState.showSnackBar(
                                          SnackBar(
                                            content: Text('Falha ao entrar: $e'),
                                            backgroundColor: Colors.red,
                                          )
                                      );
                                    },
                                    onSuccess: (){
                                      userManager.loadCurrentUser();
                                      Navigator.of(context).pop();
                                    }
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),

                  ],
                );
              },
              child:     Align(
                alignment: Alignment.centerRight,
                child: Consumer<UserManager>(
                  builder: (_, userManager, __) {
                    return FlatButton(
                      onPressed: () { //se digitar um email vazio ou com formato inválido
                        if ((emailController.text.isEmpty) || (!emailValid(emailController.text))) {
                          scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: const Text(
                                'Digite um e-mail válido',
                                textAlign: TextAlign.center,
                            ),
                            backgroundColor: Colors.redAccent,
                            duration: Duration(seconds: 4),
                          ));
                        } else
                          //se digitou um email com formato válido
                            if (!emailController.text.isEmpty){
                              //tenta logar com o email e uma senha fake. Assim ele válida primeiro o email se existe ou não.
                              //dando erro nem tenta ver a senha. se deixar a senha em branco ele retorna erro de senha nula
                              userManager.signIn(
                              user: Usuario(
                              email: emailController.text,
                              senha: "123"),
                              //irá sempre gerar exceção. Seja por um usuário q n exista ou caso ele exista está criticando a senha fake
                              onFail: (e) {
                                //se a conta não existir avisa o usuário
                                if (e =="Não há usuário com este e-mail."){
                                  scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text('Erro: $e', textAlign: TextAlign.center,),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                                //se retornar outra msg na exceção é pq a conta existe, aí faz o recovery
                                else{
                                  userManager.recoverPass(emailController.text);
                                  scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content: const Text(
                                      'Link para uma nova senha enviado para seu e-mail.',
                                      textAlign: TextAlign.center,
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 4),
                                  ));
                                }

                              },
                                  //se não gerou exceção é pq o usuário existe, então pode enviar email para alteração
                              onSuccess: () {

                              });
                            }
                      },
                      padding: EdgeInsets.zero,
                      child: const Text(
                        'Esqueci minha senha',
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

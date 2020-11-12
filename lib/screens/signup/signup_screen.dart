import 'package:flutter/material.dart';
import 'package:loja_virtual/helpers/validator.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:loja_virtual/models/usuario.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Usuario user = Usuario();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Criar conta"),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: formKey,
            child: Consumer <UserManager>(
                builder: (_,userManager,__) {
                  return ListView(
                    shrinkWrap: true, //ocupa o menor espaço possível
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(hintText: "Nome Completo"),
                        enabled: !userManager.loading,
                        validator: (name){
                          if (name.isEmpty){
                            return "Campo obrigtório!";
                          }
                          else if (name.trim().split(" ").length <=1){ //se o nome nao tiver pelo menos 1 espaço é porque nao tem sobrenome
                            return "Nome inválido!";
                          }
                          else {
                            return null;
                          }
                        },
                        onSaved: (name){
                          user.nome = name;
                        },
                      ),
                      SizedBox(height: 16,),
                      TextFormField(
                        decoration: const InputDecoration(hintText: "Email"),
                        enabled: !userManager.loading,
                        keyboardType: TextInputType.emailAddress,
                        validator: (email){
                          if (email.isEmpty){
                            return "Campo obrigatório!";
                          }
                          else if (!emailValid(email)){
                            return "Email inválido!";
                          }
                          else {
                            return null;
                          }
                        },
                        onSaved: (email){
                          user.email = email;
                        },
                      ),
                      SizedBox(height: 16,),
                      TextFormField(
                        decoration: const InputDecoration(hintText: "Senha"),
                        enabled: !userManager.loading,
                        obscureText: true,
                        validator: (pass){
                          if (pass.isEmpty){
                            return "Campo obrigatório!";
                          }
                          else if (pass.length <6){
                            return "Senha muito curta!";
                          }
                          else {
                            return null;
                          }
                        },
                        onSaved: (pass){
                          user.senha = pass;
                        },
                      ),
                      SizedBox(height: 16,),
                      TextFormField(
                        decoration: const InputDecoration(hintText: "Repita a senha"),
                        enabled: !userManager.loading,
                        obscureText: true,
                        validator: (pass){
                          if (pass.isEmpty){
                            return "Campo obrigatório!";
                          }
                          else if (pass.length <6){
                            return "Senha muito curta!";
                          }
                          else {
                            return null;
                          }
                        },
                        onSaved: (pass){
                          user.confirmarSenha = pass;
                        },
                      ),
                      SizedBox(height: 16,),
                      SizedBox(
                        height: 44,
                        child: RaisedButton(
                          onPressed: userManager.loading ? null : (){
                            if (formKey.currentState.validate()){
                              formKey.currentState.save();
                              if (user.senha != user.confirmarSenha){
                                scaffoldKey.currentState.showSnackBar(SnackBar(content: const Text("Senhas não coincidem!"), backgroundColor: Colors.red));
                                return;
                              }
                              userManager.signUp(
                                  user: user,
                                  onSuccess: (){
                                    Navigator.of(context).pop(); //fechaa tela atual
                                  },
                                  onFail: (e){
                                    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Falha ao cadastrar: $e"), backgroundColor: Colors.red));
                                  }
                              );
                            }
                          },
                          color: Theme.of(context).primaryColor,
                          disabledColor: Theme.of(context).primaryColor.withAlpha(100),
                          textColor: Colors.white,
                          child: userManager.loading ? //se estiver logando aparece um circulo de progressao
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                          : const Text("Criar Conta",style: TextStyle(fontSize: 18),),
                        ),
                      ),
                    ],

                  );
                } ,
            )
          ),
        ),
      ),
    );
  }
}

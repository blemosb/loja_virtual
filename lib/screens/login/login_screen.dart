import 'package:flutter/material.dart';
import 'package:loja_virtual/helpers/validator.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:loja_virtual/models/usuario.dart';
import 'package:provider/provider.dart';
class LoginScreen extends StatelessWidget {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Entrar"),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(onPressed: (){
            Navigator.of(context).pushReplacementNamed("/signup");
          },
          child: const Text("CRIAR CONTA", style: TextStyle(fontSize: 14),),
          textColor: Colors.white,
          ),
        ],
      ),
      body: Center(
        child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: formKey,
              child: Consumer<UserManager>( //esse consumer é um método de utilizar provider, ele fica rastreando mudanças no usermanager
                  builder: (_,userManager,__){
                    return ListView(
                        shrinkWrap: true, //ocupa a menor altura possível
                        padding: const EdgeInsets.all(16),
                        children: <Widget>[
                          TextFormField(
                            controller: emailController,
                            enabled: !userManager.loading,
                            decoration: const InputDecoration(hintText: "Email"),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            validator: (email){
                              if (!emailValid(email)) {
                                return "Email inválido";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16,), //espaço vertical entre 2 widgets
                          TextFormField(
                            controller: passController,
                            enabled: !userManager.loading,
                            decoration: const InputDecoration(hintText: "Senha"),
                            autocorrect: false,
                            obscureText: true, //senha com asteristicos
                            validator: (pass){
                              if (pass.isEmpty || pass.length<6){
                                return "Senha inválida";
                              }
                              return null;
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FlatButton(
                              onPressed: (){

                              },
                              padding: EdgeInsets.zero,
                              child: const Text(
                                  "Esqueci minha senha"
                              ),
                            ),
                          ),
                          const SizedBox(height: 16,),
                          SizedBox(
                            height: 44,
                            child: RaisedButton(
                              child: userManager.loading ? CircularProgressIndicator(         //se estiver carregando exibe um indicado de espera...
                                valueColor: AlwaysStoppedAnimation(Colors.white),)
                                  : const Text(      //senao exibe o texto e botao
                                "Entrar",
                                style: TextStyle(fontSize: 18),
                              ),
                              onPressed: userManager.loading ? null : (){ //se estiver carregando, o nulo deixa o botão desabilitado
                                if (formKey.currentState.validate()){
                                  userManager.signIn(
                                      user: Usuario(nome: " ", email: emailController.text, senha: passController.text),
                                      onFail: (e){
                                        scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Falha ao entrar: $e"), backgroundColor: Colors.red));
                                      },
                                      onSuccess: (){
                                        Navigator.of(context).pop(); //fechaa tela atual
                                      }
                                  );
                                }
                              },
                              color: Theme.of(context).primaryColor,
                              disabledColor: Theme.of(context).primaryColor.withAlpha(100),
                              textColor: Colors.white,
                            ),
                          ),
                        ]
                    );
                  },
              ),
            ),
        )
      ),
    );
  }
}
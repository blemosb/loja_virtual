import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/models/usuario.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersManager extends ChangeNotifier {

  List<Usuario> users = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription _subscription; //VARIAVEL PARA CONTROLAR O LISTEN DO FIREBASE

  void updateUser(UserManager userManager){
    _subscription?.cancel(); //toda vez que mudar o usuário cancela se existir um listerner ativo. se for adm cria de novo depois
                              // se for nulo não chama o cancel (o ? faz isso)
    if(userManager.adminEnabled){
      _listenToUsers();
    } else {
      users.clear();
      notifyListeners();
    }
  }

  void _listenToUsers(){
  /*  const faker = Faker();

    for(int i = 0; i < 1000; i++){
      users.add(Usuario(
          nome: faker.person.name(),
          email: faker.internet.email()
      ));
    }

    users.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase())); //ordena a lista por ordem alfabetica

    notifyListeners();
*/
    _subscription = firestore.collection('users').snapshots().listen((snapshot){ //MONITORA ENTRADA E SAIDA DE USUARIOS EM TEMPO REAL
      users = snapshot.docs.map((d) => Usuario.fromDocument(d)).toList(); //pega todos os objetos e transforma em uma
                                                                          // lista de objetos do tipo usuarios
      users.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase())); //ordena todos os usuparios em ordem alfBETICA
      notifyListeners();
    });
  }

  List<String> get names => users.map((e) => e.nome).toList(); //pega o nome de todos os usuarios e cria uma lista

  @override
  void dispose() { //cancela o listener qdo fecar o app
    _subscription?.cancel();
    super.dispose();
  }

}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/models/address.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

class Usuario { //modelo para usuário
  String email;
  String senha;
  String nome;
  String confirmarSenha;
  String id;
  String cpf;
  //o padrao é o usuario nao ser admin
  bool admin = false;
  Address address;

  Usuario.fromDocument(DocumentSnapshot document){ //pega um usuário do firebase e trandforma em um objeto
    id = document.id;
    nome = document.data()['name'] as String;
    email = document.data()['email'] as String;
    cpf = document.data()['cpf'] as String;
    //consulta se já existe endereço salvo para o usuário
    if(document.data().containsKey("address")){
      address = Address.fromMap(
          document.data()['address'] as Map<String, dynamic>);
    }
  }

  Usuario({String nome, String email, String senha, String id}){
    this.email = email;
    this.senha = senha;
    this.nome = nome;
    this.id = id;
  }

  //cria uma referencia para o usuário atual
  DocumentReference get firestoreRef {
    return FirebaseFirestore.instance.doc("users/$id");
  }

  CollectionReference get tokensReference =>
      firestoreRef.collection('tokens');

  CollectionReference get cartReference =>
      firestoreRef.collection('cart'); //pega a referencia para o carrinho do usuário, assim só pega a ref aqui ao invés de varios pontos do codigo
                                        //user/cart
  Future<void> saveData() async{
    await firestoreRef.set(toMap());
  }

  Map<String, dynamic> toMap(){
    return {
      "name": nome,
      "email": email,
      if(address != null)
        'address': address.toMap(),
      if(cpf != null)
        'cpf': cpf
    };
  }

  void setCpf(String cpf){
    this.cpf = cpf;
    saveData();
  }

  void setAddress(Address address){
    this.address = address;
    saveData(); //pede para salvar no firebase
  }

  Future<void> saveToken() async {
    final token = await FirebaseMessaging().getToken();
    await tokensReference.doc(token).set({
      'token': token,
      'updatedAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem,
    });
  }

}
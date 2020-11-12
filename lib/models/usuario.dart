import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario { //modelo para usuário
  String email;
  String senha;
  String nome;
  String confirmarSenha;
  String id;
  //o padrao é o usuario nao ser admin
  bool admin = false;


  Usuario.fromDocument(DocumentSnapshot document){ //pega um usuário do firebase e trandforma em um objeto
    id = document.id;
    nome = document.data()['name'] as String;
    email = document.data()['email'] as String;
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
    };
  }

}
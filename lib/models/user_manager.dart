import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:loja_virtual/helpers/firebase_errors.dart';
import 'package:loja_virtual/models/usuario.dart';
class UserManager extends ChangeNotifier{ //gerencia operaçoes sobre o usuário

  UserManager(){
    _loadCurrentUser();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //controla se está carregando login ou não
  bool _loading = false;
  Usuario user;

  bool get isLoggedIn {
    return user != null;
  }

  bool get loading {
    return _loading;
  }

  set loading(bool value){
    _loading = value;
    notifyListeners();
  }

  Future <void> signIn({Usuario user, Function onFail, Function onSuccess}) async{
    //esta logando
    _loading = true;
    try {
      final UserCredential result = await auth.signInWithEmailAndPassword(email: user.email, password: user.senha);
      await _loadCurrentUser(firebaseUser: result.user);

      onSuccess();
    } on FirebaseAuthException catch(e){
      print(e);
      onFail(getErrorString(e.code));
    }
    //acabou de logar
    _loading = false;
  }

  Future<void> signUp({Usuario user, Function onFail, Function onSuccess}) async {
    loading = true;
    try {
      final UserCredential result = await auth.createUserWithEmailAndPassword(
          email: user.email, password: user.senha);

      user.id = result.user.uid;
      this.user = user;
      await user.saveData();

      onSuccess();
    } on FirebaseAuthException catch (e){
      print(e);
      onFail(getErrorString(e.code));
    }
    loading = false;
  }

  void setLoading(bool value){
    loading = value;
    //para todos que utilizam user manager saber q tem valores alterados
    notifyListeners();
  }

  Future<void> _loadCurrentUser({User firebaseUser}) async {
    //se firebaseuser passado for nulo, pega o valor do firebase
    final User currentUser = firebaseUser ?? await auth.currentUser;

    if (currentUser!=null){
      final DocumentSnapshot docUser = await firestore.collection("users").doc(currentUser.uid).get();
      //passa para a classe usuario
      user = Usuario.fromDocument(docUser);

      //verifica se este usuário é admin
      final docAdmin = await firestore.collection('admins').doc(user.id).get();
      if(docAdmin.exists){
        user.admin = true;
      }
      //fim da verificacao

      notifyListeners();
    }

  }

  void signOut(){
    auth.signOut();
    user=null;
    notifyListeners();
  }
//fc para simplificar verificacao se usuario e admin ou nao
  bool get adminEnabled => user != null && user.admin;

}
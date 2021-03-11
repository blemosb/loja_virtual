import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:loja_virtual/helpers/firebase_errors.dart';
import 'package:loja_virtual/models/usuario.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserManager extends ChangeNotifier{ //gerencia operaçoes sobre o usuário

  UserManager(){
    loadCurrentUser();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //controla se está carregando login ou não
  bool _loading = false;
  Usuario user;

  set loading(bool value){
    _loading = value;
    notifyListeners();
  }

  bool _loadingGoogle = false;
  bool _loadingApple = false;
  bool _loadingFace = false;

  bool get loadingGoogle => _loadingGoogle;
  set loadingGoogle(bool value){
    _loadingGoogle = value;
    notifyListeners();
  }

  bool get loadingApple => _loadingApple;
  set loadingApple(bool value){
    _loadingApple = value;
    notifyListeners();
  }

  // Determine if Apple SignIn is available
  Future<bool> get appleSignInAvailable => AppleSignIn.isAvailable();

  bool get loadingFace => _loadingFace;
  set loadingFace(bool value){
    _loading = value;
    notifyListeners();
  }

  bool get isLoggedIn {
    return user != null;
  }

  bool get loading {
    return _loading;
  }


  Future<void> googleLogin({Function onFail, Function onSuccess}) async {
    _loadingGoogle = true;

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);

     Usuario usuario = Usuario(
          id: currentUser.uid,
          nome: currentUser.displayName,
          email: currentUser.email
      );

      await usuario.saveData();

      usuario.saveToken();

      onSuccess();
    //  notifyListeners();
    }
    else
      onFail();

    _loadingGoogle = false;

  }
//LOGIN APLLE
  Future<void> appleLogin({Function onFail, Function onSuccess}) async {
    _loadingApple = true;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {

      final AuthorizationResult result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      switch (result.status) {
        case AuthorizationStatus.authorized:
          try {
            print("successfull sign in");
            final AppleIdCredential appleIdCredential = result.credential;

            OAuthProvider oAuthProvider =
            new OAuthProvider("apple.com");
            final AuthCredential credential = oAuthProvider.credential(
              idToken:
              String.fromCharCodes(appleIdCredential.identityToken),
              accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
            );

            final UserCredential authResult = await FirebaseAuth.instance
                .signInWithCredential(credential);

            final User user = authResult.user;

            if (user != null) {
              assert(!user.isAnonymous);
              assert(await user.getIdToken() != null);

              final User currentUser = _auth.currentUser;
              assert(user.uid == currentUser.uid);

              Usuario usuario = Usuario(
                  id: currentUser.uid,
                  nome: result.credential.fullName.givenName + " " + result.credential.fullName.familyName,
                  email: currentUser.email
              );

              await usuario.saveData();

              usuario.saveToken();

              onSuccess();
              //  notifyListeners();
            }
            else
              onFail();

          } catch (e) {
            print("error");
          }
          break;
        case AuthorizationStatus.error:
          onFail();
          break;

        case AuthorizationStatus.cancelled:
          print('User cancelled');
          break;
      }
    } catch (error) {
      print("error with apple sign in");
      onFail();
    }

    _loadingApple = false;

  }


  /*Future<void> facebookLogin({Function onFail, Function onSuccess}) async {
    loadingFace = true;

    final result = await FacebookLogin().logIn(['email', 'public_profile']); //quais informações do usuário vc tera acesso

    switch(result.status){
      case FacebookLoginStatus.loggedIn:
        final credential = FacebookAuthProvider.credential(result.accessToken.token);
        final authResult = await auth.signInWithCredential(credential); //autentica no firebase com essa credential

        if(authResult.user != null){
          final firebaseUser = authResult.user;
//cria um usuário para guardar as informações no firebase
          user = Usuario(
              id: firebaseUser.uid,
              nome: firebaseUser.displayName,
              email: firebaseUser.email
          );

          await user.saveData();

          user.saveToken();

          onSuccess();
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        onFail(result.errorMessage);
        break;
    }
    loadingFace = false;

  }

*/
  Future <void> signIn({Usuario user, Function onFail, Function onSuccess}) async{
    //esta logando
    _loading = true;
    try {
      final UserCredential result = await auth.signInWithEmailAndPassword(email: user.email, password: user.senha);
      await loadCurrentUser(firebaseUser: result.user);

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

      user.saveToken();

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

  Future<void> loadCurrentUser({User firebaseUser}) async {
    //se firebaseuser passado for nulo, pega o valor do firebase
    final User currentUser = firebaseUser ?? await auth.currentUser;

    if (currentUser!=null){
      final DocumentSnapshot docUser = await firestore.collection("users").doc(currentUser.uid).get();
      //passa para a classe usuario
      user = Usuario.fromDocument(docUser);

      user.saveToken();

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
    GoogleSignIn _googleSignIn = GoogleSignIn();
    _googleSignIn.signOut();
    user=null;
    notifyListeners();
  }
//fc para simplificar verificacao se usuario e admin ou nao
  bool get adminEnabled => user != null && user.admin;

  //executado se o usuário esqueceu a senha do cadastro
  void recoverPass(String email) {
    auth.sendPasswordResetEmail(email: email);
    notifyListeners();
  }

}
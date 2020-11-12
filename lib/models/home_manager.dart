import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/models/section.dart';
import 'package:flutter/cupertino.dart';

class HomeManager extends ChangeNotifier {

  HomeManager(){ //carrega todas as secoes no momento que carregar a classe
    _loadSections();
  }

  List<Section> sections = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _loadSections() async {
    firestore.collection('home').snapshots().listen((snapshot) { //monitora mudanças na colection home no firebase
      sections.clear(); //limpa as secoes para quando houver uma mudanca nao juntar com as secoes antigas
      for(final DocumentSnapshot document in snapshot.docs){
        sections.add(Section.fromDocument(document));
      }
      notifyListeners(); //para fazer rebuil sempre que uma seçao for atualizada
    });
  }
}
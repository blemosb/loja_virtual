import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/models/section.dart';
import 'package:flutter/cupertino.dart';

class HomeManager extends ChangeNotifier {

  HomeManager(){ //carrega todas as secoes no momento que carregar a classe
    _loadSections();
  }

  List<Section> _sections = [];

  List<Section> _editingSections = [];
  bool editing = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _loadSections() async {
    firestore.collection('home').snapshots().listen((snapshot) { //monitora mudanças na colection home no firebase
      _sections.clear(); //limpa as secoes para quando houver uma mudanca nao juntar com as secoes antigas
      for(final DocumentSnapshot document in snapshot.docs){
        _sections.add(Section.fromDocument(document));
      }
      notifyListeners(); //para fazer rebuil sempre que uma seçao for atualizada
    });
  }

  List<Section> get sections {
    if(editing)
      return _editingSections;
    else
      return _sections;
  }

  void removeSection(Section section){
    _editingSections.remove(section);
    notifyListeners();
  }

  void addSection(Section section){
    _editingSections.add(section);
    notifyListeners();
  }

  void enterEditing(){
    editing = true;
    _editingSections = _sections.map((s) => s.clone()).toList(); //pega cada seção, faz um clone dela e transforma em uma lista
    notifyListeners();
  }

  void saveEditing(){
    editing = false;
    notifyListeners();
  }

  void discardEditing(){
    editing = false;
    notifyListeners();
  }

}
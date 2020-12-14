import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/models/section.dart';
import 'package:flutter/cupertino.dart';

class HomeManager extends ChangeNotifier {
  HomeManager() {
    //carrega todas as secoes no momento que carregar a classe
    _loadSections();
  }

  final List<Section> _sections = [];

  List<Section> _editingSections = [];
  bool editing = false;
  bool loading = false; //variavel que controla se tem alguma coisa sendo salva ou não, para exibir um circulo na tela

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _loadSections() async {
    firestore.collection('home').orderBy('pos').snapshots().listen((snapshot) {
      //monitora mudanças na colection home no firebase
      _sections
          .clear(); //limpa as secoes para quando houver uma mudanca nao juntar com as secoes antigas
      for (final DocumentSnapshot document in snapshot.docs) {
        _sections.add(Section.fromDocument(document));
      }
      notifyListeners(); //para fazer rebuil sempre que uma seçao for atualizada
    });
  }

  List<Section> get sections {
    if (editing)
      return _editingSections;
    else
      return _sections;
  }

  void removeSection(Section section) {
    _editingSections.remove(section);
    notifyListeners();
  }

  void addSection(Section section) {
    _editingSections.add(section);
    notifyListeners();
  }

  void enterEditing() {
    editing = true;
    _editingSections = _sections
        .map((s) => s.clone())
        .toList(); //pega cada seção, faz um clone dela e transforma em uma lista
    notifyListeners();
  }

  Future<void> saveEditing() async {
    bool valid = true;
    for (final section in _editingSections) {
      if (!section.valid()) valid = false;
    }
    if (!valid) return; //se algo não for valido pára o salvamento

    loading = true; //para mostra o circulo na tela
    notifyListeners();

    int pos = 0;

    for(final section in _editingSections){
      await section.save(pos);
      pos++;
    }

    //verifica se teve exclusão de seção. se tiver exclui as imagens associadas a ela do firestorage
    for(final section in List.from(_sections)){// faz uma copia da lista pq _sections recebe modificações no bd. como está dentro de um for,
                                                //seriam duas ooperações simultaneas e daria erro...
      if(!_editingSections.any((element) => element.id == section.id)){ //não verifica se contains pq sao objetos diferentes já q foi criado clone
        await section.delete();
      }
    }
    loading = false;
    editing = false;
    notifyListeners();
  }

  void discardEditing() {
    editing = false;
    notifyListeners();
  }
}

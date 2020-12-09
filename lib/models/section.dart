import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/models/section_item.dart';

class Section { //modelo que pega uma seçao da home

  String name;
  String type;
  List<SectionItem> items;

  Section({this.name, this.type, this.items}){
    items = items ?? []; //se items for nulo então recebe vazio para n ter erro...
  }

  Section.fromDocument(DocumentSnapshot document){
    name = document.data()['name'] as String;
    type = document.data()['type'] as String;
    items = (document.data()['items'] as List).map(
            (i) => SectionItem.fromMap(i as Map<String, dynamic>)).toList();
  }

  Section clone(){
    return Section(
      name: name,
      type: type,
      items: items.map((e) => e.clone()).toList(), //se passar items=items direto ele passa a referência, não os valores
    );
  }

  @override
  String toString() {
    return 'Section{name: $name, type: $type, items: $items}';
  }

}
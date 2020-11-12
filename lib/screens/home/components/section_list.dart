import 'package:flutter/material.dart';
import 'package:loja_virtual/models/section.dart';
import 'package:loja_virtual/screens/home/components/section_header.dart';
import 'package:loja_virtual/screens/home/components/item_tile.dart';

class SectionList extends StatelessWidget { //constroi a tela se o widget for uma lista

  const SectionList(this.section);

  final Section section;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionHeader(section),
          SizedBox(
            height: 150, //tamanho para listview
            child: ListView.separated( //deixar espaco entre itens do listview
              scrollDirection: Axis.horizontal, //scroll da list será na horizontal
              itemBuilder: (_, index){ //item que está sendo desenhado no momento
                return ItemTile(section.items[index]);
              },
              separatorBuilder: (_, __) => const SizedBox(width: 4,), //espaco de separacao entre os itens
              itemCount: section.items.length, //tamanho da listview
            ),
          )//criou um eader eparado pq terá muitas customizaçoes
        ],
      ),
    );
  }
}
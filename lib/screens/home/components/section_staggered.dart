import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:loja_virtual/models/section.dart';
import 'package:loja_virtual/screens/home/components/section_header.dart';
import 'package:loja_virtual/screens/home/components/item_tile.dart';

class SectionStaggered extends StatelessWidget {

  const SectionStaggered(this.section);

  final Section section;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionHeader(section),
          StaggeredGridView.countBuilder(
            padding: EdgeInsets.zero, //remove a borda interna do staggeredview
            shrinkWrap: true, //listview seja a menor possível
            crossAxisCount: 4, //como a lista é na vertical, o cross é a qtde de items na horizontal.
                              // cada quadrado ocupa duas units de largura, entao sao 2 registros por linha
            itemCount: section.items.length,
            itemBuilder: (_, index){
              return ItemTile(section.items[index]); //imagem com um gesturedetector para abrir um produto correspondente
            },
            staggeredTileBuilder: (index) =>
                StaggeredTile.count(2, index.isEven ? 2 : 1), //se o index for par é tam 2x2, e impar é 2x1
            mainAxisSpacing: 4, //espacamento no eixo vertical
            crossAxisSpacing: 4, //espacamento no eixo horizontal
          )
        ],
      ),
    );
  }
}
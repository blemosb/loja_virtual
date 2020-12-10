import 'package:flutter/material.dart';
import 'package:loja_virtual/models/section.dart';
import 'package:loja_virtual/screens/home/components/section_header.dart';
import 'package:loja_virtual/screens/home/components/item_tile.dart';
import 'package:loja_virtual/models/home_manager.dart';
import 'package:loja_virtual/screens/home/components/add_tile_widget.dart';
import 'package:provider/provider.dart';

class SectionList extends StatelessWidget {
  //constroi a tela se o widget for uma lista

  const SectionList(this.section);

  final Section section;

  @override
  Widget build(BuildContext context) {
    final homeManager = context.watch<HomeManager>();
    return ChangeNotifierProvider.value(
      value: section,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SectionHeader(),
            SizedBox(
              height: 150,
              child: Consumer<Section>(
                builder: (_, section, __) {
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) {
                      if (index < section.items.length) //pega o indice do novo index para criar uma nova seção
                        return ItemTile(section.items[index]);
                      else
                        return AddTileWidget();
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 4,),
                    itemCount: homeManager.editing //se estiver editando inclui um item a mais para a nova seção
                        ? section.items.length + 1
                        : section.items.length,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
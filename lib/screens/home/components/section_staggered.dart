import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:loja_virtual/models/section.dart';
import 'package:loja_virtual/screens/home/components/section_header.dart';
import 'package:loja_virtual/screens/home/components/item_tile.dart';
import 'package:loja_virtual/models/home_manager.dart';
import 'package:loja_virtual/screens/home/components/add_tile_widget.dart';
import 'package:provider/provider.dart';

class SectionStaggered extends StatelessWidget {

  const SectionStaggered(this.section);

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
            Consumer<Section>(
              builder: (_, section, __) {
                return StaggeredGridView.countBuilder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  physics: const NeverScrollableScrollPhysics(), //deixa rolar clicando em qq lugar da lista, senão só rola se clicar fora de
                                                                //item da lista
                  itemCount: homeManager.editing
                      ? section.items.length + 1
                      : section.items.length,
                  itemBuilder: (_, index) {
                    if (index < section.items.length)
                      return ItemTile(section.items[index]);
                    else
                      return AddTileWidget();
                  },
                  staggeredTileBuilder: (index) =>
                      StaggeredTile.count(2, index.isEven ? 2 : 1),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
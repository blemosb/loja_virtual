import 'package:flutter/material.dart';
import 'package:loja_virtual/common/custom_drawer/custom_drawer.dart';
import 'package:loja_virtual/models/product_manager.dart';
import 'package:provider/provider.dart';

import 'components/product_list_tile.dart';
import 'components/search_dialog.dart';

class ProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Consumer<ProductManager> (
          builder: (_, productManager, __){
            if (productManager.search.isEmpty){
              return const Text("Produtos");
            }
            else {
              return LayoutBuilder(
                builder: (_, constraints){
                  return GestureDetector(
                    onTap: () async {
                      final search = await showDialog<String>(context: context,
                          builder: (_)   => SearchDialog(productManager.search));
                      if(search != null){
                        productManager.search = search;
                      }
                    },
                    child: Container(
                        width: constraints.biggest.width, //ocupará a maior largura possivel da tela
                        child: Text(
                          productManager.search,
                          textAlign: TextAlign.center,
                        )
                    ),
                  );
                },
              );
            }
          }
        ),
        centerTitle: true,
        actions: <Widget> [
         Consumer<ProductManager>(
           builder: (_, productManager, __) {
             if (productManager.search.isEmpty){ //se a pesquisa estiver vazia o botão paarece para pesquisar
               return IconButton(
                 icon: Icon(Icons.search),
                 onPressed: () async {
                   final search = await showDialog<String>(context: context,builder: (_) => SearchDialog(productManager.search));
                   if (search != null){
                     productManager.search = search;
                   }
                 },
               );
             }
             else { //senao aparece botão de fechar e zera campo de pesquisa
               return IconButton(
                 icon: Icon(Icons.close),
                 onPressed: () async {
                     productManager.search = "";
                 },
               );
             }
           }
         ),
        ],
      ),
      body: Consumer<ProductManager>(
        builder: (_, productManager, __){
          final filteredProducts = productManager.filteredProducts; //para nao chamar toda hora o método em product manager
          return ListView.builder(
              padding: const EdgeInsets.all(4),
              itemCount: filteredProducts.length,
              itemBuilder: (_, index){
                return  ProductListTile(filteredProducts[index]);

              }
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        onPressed: (){
          Navigator.of(context).pushNamed('/cart');
        },
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}

import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/models/admin_users_manager.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/common/custom_drawer/custom_drawer.dart';

class AdminUsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text('Usuários'),
        centerTitle: true,
      ),
      body: Consumer<AdminUsersManager>( //sempre q houver mudança no usermanager rebuilda a tela
        builder: (_, adminUsersManager, __){
          return AlphabetListScrollView(
            itemBuilder: (_, index){
              return ListTile(
                title: Text(
                  adminUsersManager.users[index].nome,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white
                  ),
                ),
                subtitle: Text(
                  adminUsersManager.users[index].email,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            },
            highlightTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20
            ),
            indexedHeight: (index) => 80, //altura do index
            strList: adminUsersManager.names, //pega os nomes da lista para criar uma lista vertical de iniciais
            showPreview: true,
          );
        },
      ),
    );
  }
}
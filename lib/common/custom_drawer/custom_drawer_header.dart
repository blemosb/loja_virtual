import 'package:flutter/material.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/models/page_manager.dart';

class CustomDrawerHeader extends StatelessWidget { //cabeçalho do menu lateral
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 16, 8),
      height: 180,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [const Color.fromARGB(255, 65, 16, 165),
                Colors.white,],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
          )
      ),
      child: Consumer<UserManager>(
        builder: (_, userManager, __){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
             Expanded(child:  //como é uma coluna expanded faz ocupar todo o espaço disponível verticalmente
             Image(image: AssetImage('images/LB.png')),
             ),
              Text(
                'Olá, ${userManager.user?.nome ?? ''}',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: (){
                  if(userManager.isLoggedIn){
                    context.read<PageManager>().setPage(0);
                    userManager.signOut();
                  } else {
                    Navigator.of(context).pushNamed('/login');
                  }
                },
                child: Text(
                  userManager.isLoggedIn
                      ? 'Sair'
                      : 'Entre ou cadastre-se >',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
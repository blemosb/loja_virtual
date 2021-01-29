import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/models/order.dart';
import 'package:loja_virtual/models/usuario.dart';
import 'dart:async';

class OrdersManager extends ChangeNotifier {

  Usuario user;

  List<Order> orders = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription _subscription; //controla o listener

  void updateUser(Usuario user){
    this.user = user;
    orders.clear();

    _subscription?.cancel();//cancela toda vez q houver uma troca de usuário
    if(user != null){
      _listenToOrders();
    }
  }
//sempre q houvr uma mudança nos pedidos ele lê de novo toda a coleção order e transforma em uma lista de order
  void _listenToOrders(){
    _subscription = firestore.collection('orders').where('user', isEqualTo: user.id)
        .snapshots().listen(
            (event) {
              for(final change in event.docChanges){
                switch(change.type){
                  case DocumentChangeType.added:
                    orders.add(
                        Order.fromDocument(change.doc)
                    );
                    break;
                  case DocumentChangeType.modified:
                    final modOrder = orders.firstWhere(
                            (o) => o.orderId == change.doc.id);
                    modOrder.updateFromDocument(change.doc);
                    break;
                  case DocumentChangeType.removed:
                    debugPrint('Deu problema sério!!!');
                    break;
                }
          }

          notifyListeners();
        });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel(); //só cancela se não for nulo
  }

}
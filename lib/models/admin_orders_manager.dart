import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/models/order.dart';
import 'package:loja_virtual/models/usuario.dart';

class AdminOrdersManager extends ChangeNotifier {

  final List<Order> _orders = [];

  Usuario userFilter;
  //lista com todos os status possiveis de um pedido. inicia só com preparing
  List<Status> statusFilter = [Status.preparing];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription _subscription;

  void updateAdmin({bool adminEnabled}){
    _orders.clear();

    _subscription?.cancel();
    if(adminEnabled){
      _listenToOrders();
    }
  }

  List<Order> get filteredOrders {
    List<Order> output = _orders.reversed.toList();

    if(userFilter != null){ //filtra todos os pedidos onde o usuário é igual ao usuário selecionado
      output = output.where((o) => o.userId == userFilter.id).toList();
    }
//pega a lista já filtrada anteriormente e agora filtra por status. para cada pedido de output ele vê se o status está dentro
// da lista de status atual
    return output.where((o) => statusFilter.contains(o.status)).toList();
  }

  void _listenToOrders(){
    _subscription = firestore.collection('orders').snapshots().listen(
            (event) {
              for(final change in event.docChanges){ //listen para mudanças
                switch(change.type){ //ve qual tipo de mudança
                  case DocumentChangeType.added:
                    _orders.add(
                        Order.fromDocument(change.doc)
                    );
                    break;
                  case DocumentChangeType.modified:
                    final modOrder = _orders.firstWhere(
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

  void setUserFilter(Usuario user){
    userFilter = user;
    notifyListeners();
  }

  void setStatusFilter({Status status, bool enabled}){
    if(enabled){ //se habilitou inclui mais um status
      statusFilter.add(status);
    } else { //senão remove
      statusFilter.remove(status);
    }
    notifyListeners(); //pede para desenhar a tela novamente com a mudança de status
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

} 
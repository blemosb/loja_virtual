import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/models/address.dart';
import 'package:loja_virtual/models/cart_manager.dart';
import 'package:loja_virtual/models/cart_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/services/cielo_payment.dart';

enum Status { canceled, preparing, transporting, delivered }

class Order { //model para armazenar informações sobre um pedido

  Order.fromCartManager(CartManager cartManager){
    items = List.from(cartManager.items);
    price = cartManager.totalPrice;
    userId = cartManager.user.id;
    address = cartManager.address;
    status = Status.preparing;
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String orderId;

  List<CartProduct> items;
  num price;

  String userId;
  Status status;
  Address address;
  String payId;
  Timestamp date;


  //função só pode ser chamada se produto já estiver pelo menos em transporte (se tiver sido cancelada não dá prá voltar mais)
  Function() get back {
    return status.index >= Status.transporting.index ?
        (){
      status = Status.values[status.index - 1];
      firestoreRef.update({'status': status.index});
    } : null;
  }

  //função só pode ser chamada se ainda não tiver sido entregue (máx em transporting)
  Function() get advance {
    return status.index <= Status.transporting.index ?
        (){
      status = Status.values[status.index + 1];
      firestoreRef.update({'status': status.index});
    } : null;
  }

  Future<void> cancel() async {
    try {
      await CieloPayment().cancel(payId); //primeiro cancela update do pgto
//depois altera o status
      status = Status.canceled;
      firestoreRef.update({'status': status.index});
    } catch (e){
      debugPrint('Erro ao cancelar');
      return Future.error('Falha ao cancelar');
    }
  }

  Future<void> save() async {
    firestore.collection('orders').doc(orderId).set(
        {
          'items': items.map((e) => e.toOrderItemMap()).toList(), //pega cada 1 dos cartproducts e transforma em um mapa. depois retorna uma lista de mapas
          'price': price,
          'user': userId,
          'address': address.toMap(),
          'status': status.index,
          'date': Timestamp.now(),
          'payId': payId,
        }
    );
  }

  String get formattedId => '#${orderId.padLeft(6, '0')}'; //são 6 caracters e completa com 0 à esquerda para completar os 6

  Order.fromDocument(DocumentSnapshot doc){
    orderId = doc.id;

    items = (doc.data()['items'] as List<dynamic>).map((e){
      return CartProduct.fromMap(e as Map<String, dynamic>);
    }).toList();

    price = doc.data()['price'] as num;
    userId = doc.data()['user'] as String;
    address = Address.fromMap(doc.data()['address'] as Map<String, dynamic>);
    date = doc.data()['date'] as Timestamp;
    status = Status.values[doc.data()['status'] as int];
    payId = doc.data()['payId'] as String;
  }

  DocumentReference get firestoreRef =>
      firestore.collection('orders').doc(orderId);

  void updateFromDocument(DocumentSnapshot doc){
    status = Status.values[doc.data()['status'] as int];
  }

  String get statusText => getStatusText(status);

  static String getStatusText(Status status) {
    switch(status){
      case Status.canceled:
        return 'Cancelado';
      case Status.preparing:
        return 'Em preparação';
      case Status.transporting:
        return 'Em transporte';
      case Status.delivered:
        return 'Entregue';
      default:
        return '';
    }
  }

  @override
  String toString() {
    return 'Order{firestore: $firestore, orderId: $orderId, items: $items, price: $price, userId: $userId, address: $address, date: $date}';
  }

}
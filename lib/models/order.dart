import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/models/address.dart';
import 'package:loja_virtual/models/cart_manager.dart';
import 'package:loja_virtual/models/cart_product.dart';

class Order { //model para armazenar informações sobre um pedido

  Order.fromCartManager(CartManager cartManager){
    items = List.from(cartManager.items);
    price = cartManager.totalPrice;
    userId = cartManager.user.id;
    address = cartManager.address;
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> save() async {
    firestore.collection('orders').doc(orderId).set(
        {
          'items': items.map((e) => e.toOrderItemMap()).toList(), //pega cada 1 dos cartproducts e transforma em um mapa. depois retorna uma lista de mapas
          'price': price,
          'user': userId,
          'address': address.toMap(),
        }
    );
  }

  String orderId;

  List<CartProduct> items;
  num price;

  String userId;

  Address address;

  Timestamp date;

  String get formattedId => '#${orderId.padLeft(6, '0')}';

  Order.fromDocument(DocumentSnapshot doc){
    orderId = doc.id;

    items = (doc.data()['items'] as List<dynamic>).map((e){
      return CartProduct.fromMap(e as Map<String, dynamic>);
    }).toList();

    price = doc.data()['price'] as num;
    userId = doc.data()['user'] as String;
    address = Address.fromMap(doc.data()['address'] as Map<String, dynamic>);
    date = doc.data()['date'] as Timestamp;
  }

  @override
  String toString() {
    return 'Order{firestore: $firestore, orderId: $orderId, items: $items, price: $price, userId: $userId, address: $address, date: $date}';
  }

}
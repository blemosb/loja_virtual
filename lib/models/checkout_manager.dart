import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/models/cart_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:loja_virtual/models/order.dart';
import 'package:loja_virtual/models/credit_card.dart';
import 'package:loja_virtual/services/cielo_payment.dart';

class CheckoutManager extends ChangeNotifier {

CartManager cartManager;
final FirebaseFirestore firestore = FirebaseFirestore.instance;
final CieloPayment cieloPayment = CieloPayment();

   void updateCart(CartManager cartManager){
      this.cartManager = cartManager;
  }

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value){
    _loading = value;
    notifyListeners();
  }


//1.primeiro verifica se tem estoque disponível 2.depois processa o pgto 3.Gera um número de pedido 4. Cria um objeto pedido
  //5. Salva o pedido no firebase
  Future<void> checkout({CreditCard creditCard,
    Function onStockFail,
    Function onSuccess,
    Function onPayFail}) async {

    loading = true;
    final orderId = await _getOrderId();
    String payId;

    //AUTORIZAÇÃO DO PGTO
    try {
        payId = await cieloPayment.authorize(
        creditCard: creditCard,
       // price: cartManager.totalPrice,  TODO alterar preço para o real
        price: 1,
        orderId: orderId.toString(),
        user: cartManager.user,
      );
      debugPrint('success autorização $payId');
    } catch (e){
      onPayFail(e);
      loading = false;
      return;
    }

    //DECREMENTA O ESTOQUE
    try {
      await _decrementStock();
    } catch (e){
      //se der problema entre a autorização e o pgto, cancela a autorização, senão bloqueia o limite do cliente até cancelar depois de alguns dias
      cieloPayment.cancel(payId);
      onStockFail(e); //volta para tela do carrinho e mostra qual o produto não está disponivel
      loading = false;
      return;
    }

// CAPTURAR O PAGAMENTO
    try {
      await cieloPayment.capture(payId);
      debugPrint("success captura");
    } catch (e){
      onPayFail(e);
      loading = false;
      return;
    }

    final order = Order.fromCartManager(cartManager);
    order.orderId = orderId.toString();
    order.payId = payId;

    await order.save();
    cartManager.clear();


    onSuccess(order);
    loading = false;
  }
  Future<int> _getOrderId() async {
    final ref = firestore.doc('aux/ordercounter');
    try {
      final result = await firestore.runTransaction((tx) async {
        final doc = await tx.get(ref);
        final orderId = doc.data()['current'] as int;
        await tx.update(ref, {'current': orderId + 1});
        return {'orderId': orderId};
      });
      return result['orderId'] as int;
    } catch (e){
      debugPrint(e.toString());
      return Future.error('Falha ao gerar número do pedido');
    }
  }

  Future<void> _decrementStock(){
    // 1. Ler todos os estoques 3xM
    // 2. Decremento localmente os estoques 2xM
    // 3. Salvar os estoques no firebase 2xM

    return firestore.runTransaction((tx) async {
      final List<Product> productsToUpdate = [];
      final List<Product> productsWithoutStock = [];

      for(final cartProduct in cartManager.items){
        Product product;
//verifica se tem produto repetido dentro do carrinho
        //se existir pega da lista local
        if(productsToUpdate.any((p) => p.id == cartProduct.productId)){
          product = productsToUpdate.firstWhere(
                  (p) => p.id == cartProduct.productId);
        } else { //pega do firebase
          final doc = await tx.get(
              firestore.doc('products/${cartProduct.productId}')
          );
          product = Product.fromDocument(doc);
        }
//joga no carrinho o produto mais atualizado
        cartProduct.product = product;

        final size = product.findSize(cartProduct.size);
        if(size.stock - cartProduct.quantity < 0){
          productsWithoutStock.add(product);
        } else {
          size.stock -= cartProduct.quantity;
          productsToUpdate.add(product);
        }
      }

      if(productsWithoutStock.isNotEmpty){
        return Future.error(
            '${productsWithoutStock.length} produtos sem estoque');
      }

      for(final product in productsToUpdate){
        tx.update(firestore.document('products/${product.id}'),
            {'sizes': product.exportSizeList()});
      }
    });
  }

}
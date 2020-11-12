import 'package:loja_virtual/models/cart_product.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/models/usuario.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:flutter/cupertino.dart';

class CartManager extends ChangeNotifier {

  List<CartProduct> items = []; //lista de items da memoria
  num productsPrice = 0.0; //calcula o preco total do carrinho
  Usuario user;

  void updateUser(UserManager userManager){
    user = userManager.user;
    items.clear(); //sempre q atualizar o usuário limpa o carrinho

    if(user != null){
      _loadCartItems();
    }
  }

  Future<void> _loadCartItems() async {
    final QuerySnapshot cartSnap = await user.cartReference.get(); //cartReference foi criado na classe do usuário

    items = cartSnap.documents.map(
            (d) => CartProduct.fromDocument(d)..addListener(_onItemUpdated) //adiciona listener igual e add cart, para os casos em que o carrinho
                                                                                //vem do firebase
    ).toList();
  }

  void addToCart(Product product){
    try {
      final e = items.firstWhere((p) => p.stackable(product)); //ele procura se aquele produto já está no carrinho com aquele tamanho, ou seja,
                                                                //se é um item repetido
      e.increment(); //chama increment para acionar notifylistener na classe cart_product
    } catch (e){ //se não existir um produto gera essa exceçao, ou seja, é um produto novo
      final cartProduct = CartProduct.fromProduct(product);
      cartProduct.addListener(_onItemUpdated); //sempre que um item for adicionado no carrinho irá chamar a funcao onItemUpdated para atualizar no firebase
      items.add(cartProduct);
      user.cartReference.add(cartProduct.toCartItemMap())
          .then((doc) => cartProduct.id = doc.id); //ele cria e já pega a referencia do id para poder manipular mais tarde...
      _onItemUpdated();
    }
    notifyListeners(); //aciona a cart_screen para rebuildar
  }

  void removeOfCart(CartProduct cartProduct){
    items.removeWhere((p) => p.id == cartProduct.id); //remove da lista na memoria
    user.cartReference.document(cartProduct.id).delete(); //remove do firebase
    cartProduct.removeListener(_onItemUpdated);
    notifyListeners(); //aciona a cart_screen para rebuildar
  }

  void _onItemUpdated(){
    productsPrice = 0.0; //sempre que for dar updated zera o preco total para calcular novamente

    for(int i = 0; i<items.length; i++){
      final cartProduct = items[i];

      if(cartProduct.quantity == 0){
        removeOfCart(cartProduct);
        i--;
        continue;
      }

      productsPrice += cartProduct.totalPrice;

      _updateCartProduct(cartProduct);
    }

    notifyListeners(); //sempre que um item for alterado no carrinho, ele aciona o listener para quem estiver ouvindo saber q tem q dar um rebuild
  }

  void _updateCartProduct(CartProduct cartProduct){
    if(cartProduct.id != null)
      user.cartReference.doc(cartProduct.id)
          .update(cartProduct.toCartItemMap());
  }

  bool get isCartValid {
    for(final cartProduct in items){
      if(!cartProduct.hasStock) return false;
    }
    return true;
  }

}
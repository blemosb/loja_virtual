import 'package:loja_virtual/models/cart_product.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/models/usuario.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/services/cepaberto_service.dart';
import 'package:loja_virtual/models/address.dart';
import 'package:geolocator/geolocator.dart';

class CartManager extends ChangeNotifier {

  List<CartProduct> items = []; //lista de items da memoria
  num productsPrice = 0.0; //calcula o preco total do carrinho
  Usuario user;
  Address address;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  num deliveryPrice;
  num get totalPrice => productsPrice + (deliveryPrice ?? 0); //só soma se delivery for diferente de nulo
  bool _loading = false;
  bool get loading => _loading;

  set loading(bool value){
    _loading = value;
    notifyListeners();
  }

  //seta o endereço e chama metodo para calcular o delivery
  Future<void> setAddress(Address address) async {
    loading = true;
    this.address = address;

    if(await calculateDelivery(address.lat, address.long)){
      notifyListeners();
      user.setAddress(address); //salva o endereço do usuário somente se ele estiver no raio de entrega
      loading = false;
    } else {
      loading = false;
      return Future.error('Endereço fora do raio de entrega :(');
    }
  }

  void clear() {
    for(final cartProduct in items){
      user.cartReference.doc(cartProduct.id).delete();
    }
    items.clear();
    notifyListeners();
  }

  Future<bool> calculateDelivery(double lat, double long) async {
    final DocumentSnapshot doc = await firestore.doc('aux/delivery').get();

    final latStore = doc.data()['lat'] as double;
    final longStore = doc.data()['long'] as double;
    final base = doc.data()['base'] as num;
    final km = doc.data()['km'] as num;
    final maxkm = doc.data()['maxkm'] as num;

    double dis = await Geolocator.distanceBetween(latStore, longStore, lat, long);
//originalmente a distância vem em metros. transforma para kms
    dis /= 1000.0;
    debugPrint('Distance $dis');

    if(dis > maxkm){
      return false;
    }

    deliveryPrice = base + dis * km;
    return true;
  }

  void updateUser(UserManager userManager){
    user = userManager.user;
    productsPrice = 0.0;
    items.clear(); //sempre q atualizar o usuário limpa o carrinho
    removeAddress();
    if(user != null){
      _loadCartItems();
      _loadUserAddress(); //já verifica em tempo real se tem endereço cadastrado e calcula o delivery para qdo abrir o carrinho ganhar tempo
    }
  }

  Future<void> _loadUserAddress() async {
    if(user.address != null && await calculateDelivery(user.address.lat, user.address.long)){
      address = user.address;
      notifyListeners();
    }
  }

  //endereço será válido se address e preço não forem nulos
  bool get isAddressValid => address != null && deliveryPrice != null;

    // ADDRESS

    Future<void> getAddress(String cep) async {
      loading = true;
      final cepAbertoService = CepAbertoService();
      try {
        final cepAbertoAddress = await cepAbertoService.getAddressFromCep(cep);

        if(cepAbertoAddress != null){
          address = Address(
              street: cepAbertoAddress.logradouro,
              district: cepAbertoAddress.bairro,
              zipCode: cepAbertoAddress.cep,
              city: cepAbertoAddress.cidade.nome,
              state: cepAbertoAddress.estado.sigla,
              lat: cepAbertoAddress.latitude,
              long: cepAbertoAddress.longitude
          );
          notifyListeners();
        }
        loading = false;
      } catch (e){
        debugPrint(e.toString());
        loading = false;
        return Future.error('CEP Inválido');
      }
    }

//remove para limpar a tela do endereço no carrinho
  void removeAddress(){
    address = null;
    deliveryPrice = null;
    notifyListeners();
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
    user.cartReference.doc(cartProduct.id).delete(); //remove do firebase
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
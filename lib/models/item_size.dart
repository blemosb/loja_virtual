class ItemSize { //preço e estoque por tamanho do produto. um size tem varios item sizes com estes valores

  ItemSize({this.name, this.price, this.stock});

  String name;
  num price;
  int stock;

  ItemSize.fromMap(Map<String, dynamic> map){ //le itemsize do firebase
    name = map['name'] as String;
    price = map['price'] as num;
    stock = map['stock'] as int;
  }

  bool get hasStock => stock > 0;

  ItemSize clone(){
    return ItemSize(
      name: name,
      price: price,
      stock: stock,
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'name': name,
      'price': price,
      'stock': stock,
    };
  }

  @override
  String toString() {
    return 'ItemSize{name: $name, price: $price, stock: $stock}';
  }
}
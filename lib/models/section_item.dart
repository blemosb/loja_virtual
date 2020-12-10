class SectionItem { //model para imagens das seçoes promocoes e novidades

  dynamic image;
  String product;

  SectionItem({this.image, this.product});

  SectionItem.fromMap(Map<String, dynamic> map){
    image = map['image'] as String;
    product = map['product'] as String;
  }

  SectionItem clone(){
    return SectionItem(
      image: image,
      product: product,
    );
  }

  @override
  String toString() {
    return 'SectionItem{image: $image, product: $product}';
  }
}
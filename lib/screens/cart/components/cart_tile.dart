import 'package:flutter/material.dart';
import 'package:loja_virtual/models/cart_product.dart';
import 'package:loja_virtual/common/custom_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class CartTile extends StatelessWidget { ///desenha as informacoes no card do cart_screen

  const CartTile(this.cartProduct);

  final CartProduct cartProduct;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value( //para pegr o valor de cartProduct passado para tela
      value: cartProduct, //em qq parte do card tile tera acesso ao cartProduct
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).pushNamed(
              '/product',
              arguments: cartProduct.product);
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                SizedBox(
                  height: 80,
                  width: 80,
                  child: Image.network(cartProduct.product.images.first ?? kTransparentImage as String),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          cartProduct.product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Tamanho: ${cartProduct.size}',
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ),
                        Consumer<CartProduct>(
                          builder: (_, cartProduct, __){
                            if(cartProduct.hasStock)
                              return Text(
                                'R\$ ${cartProduct.unitPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold
                                ),
                              );
                            else
                              return const Text(
                                'Sem estoque. Pagamento estornado.',
                                maxLines: 2,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              );
                          },
                        )
                      ],
                    ),
                  ),
                ),
                Consumer <CartProduct>(
                  builder: (_,cartProduct,__){
                    return Column(
                      children: <Widget> [
                        CustomIconButton(
                          iconData: Icons.add,
                          color: Theme.of(context).primaryColor,
                          onTap: cartProduct.increment,
                        ),
                        Text(
                          '${cartProduct.quantity}',
                          style: const TextStyle(fontSize: 20),
                        ),
                        CustomIconButton(
                          iconData: Icons.remove,
                          color: cartProduct.quantity > 1 ? //se tiver mais de um produto retorna a cor primaria senao retorna cor vermelha
                                                            // para avisar que se clicar de novo o produto será tirado do carrinho
                          Theme.of(context).primaryColor : Colors.red,
                          onTap: cartProduct.decrement,
                        ),
                      ],
                    );
                  }
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:loja_virtual/models/order.dart';
import 'package:loja_virtual/common/order/order_product_tile.dart';
import 'package:loja_virtual/common/order/cancel_order_dialog.dart';
import 'package:loja_virtual/common/order/export_address_dialog.dart';

class OrderTile extends StatelessWidget { //items da lista de pedidos

  const OrderTile(this.order, {this.showControls = false}); //se não passar show controls por parâmetro ele recebe false

  final Order order;
  final bool showControls;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile( //cria um card expansíve. qdo clica na seta acima à direita ele mostra novas informações
        title: Row( //aqui mostra antes da expansão
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  order.formattedId,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                Text(
                  'R\$ ${order.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Text(
              order.statusText,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: order.status == Status.canceled ?
                  Colors.red : primaryColor,
                  fontSize: 14
              ),
            )
          ],
        ),
        children: <Widget>[ //aqui mostra depois da expansão
          Column(
            children: order.items.map((e){
              return OrderProductTile(e);
            }).toList(),
          ),
          //ests botões mudam o status do pedido
          if(showControls && order.status != Status.canceled) //só mostra os botões embaixo se for admin e o pedido n estiver cancelado
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  FlatButton(
                    onPressed: (){
                      showDialog(context: context,
                          builder: (_) => CancelOrderDialog(order) //alert dialog para confirmar o cancelamento
                      );
                    },
                    textColor: Colors.red,
                    child: const Text('Cancelar'),
                  ),
                  FlatButton(
                    onPressed: order.back,
                    child: const Text('Recuar'),
                  ),
                  FlatButton(
                    onPressed: order.advance,
                    child: const Text('Avançar'),
                  ),
                  FlatButton(
                    onPressed: (){
                      showDialog(context: context,
                          builder: (_) => ExportAddressDialog(order.address)
                      );
                    },
                    textColor: primaryColor,
                    child: const Text('Endereço'),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}
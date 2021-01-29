import 'package:flutter/material.dart';
import 'package:loja_virtual/common/custom_drawer/custom_drawer.dart';
import 'package:loja_virtual/common/empty_card.dart';
import 'package:loja_virtual/common/order/order_tile.dart';
import 'package:loja_virtual/models/admin_orders_manager.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/common/custom_icon_button.dart';
import 'package:loja_virtual/models/order.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AdminOrdersScreen extends StatefulWidget {
  @override
  _AdminOrdersScreenState createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final PanelController panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text('Todos os Pedidos'),
        centerTitle: true,
      ),
      body: Consumer<AdminOrdersManager>(
        builder: (_, ordersManager, __) {
          final filteredOrders = ordersManager.filteredOrders;

          return SlidingUpPanel(
            //permite apenas clicar no painel para abrir e fechar. se nao tiver tem q arrastar...
            controller: panelController,
            //cria um painel na tela. no caso cria um painel de filtrod embaixo do conteudo normal
            body: Column(
              children: <Widget>[
                if (ordersManager.userFilter !=
                    null) //se o usuário estiver filtrado aparece um texto em cima com o nome dele e um botão
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Pedidos de ${ordersManager.userFilter.nome}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        CustomIconButton(
                          //botão para desfazer o filtro
                          iconData: Icons.close,
                          color: Colors.white,
                          onTap: () {
                            ordersManager.setUserFilter(null);
                          },
                        )
                      ],
                    ),
                  ),
                if (filteredOrders
                    .isEmpty) //se não tiver produto filtrado aparece msg avisando
                  Expanded(
                    //tem q determinar o tamanho para ocupar a maior parte da tela (
                    child: EmptyCard(
                      title: 'Nenhuma venda realizada!',
                      iconData: Icons.border_clear,
                    ),
                  )
                else //se tiver item filtrado aparece os pedidos
                  Expanded(
                    child: ListView.builder(
                        itemCount: filteredOrders.length, //tem q determinar o tamanho da listview senão dá erro...
                        itemBuilder: (_, index) {
                          return OrderTile(
                            filteredOrders[index],
                            showControls: true,
                          );
                        }),
                  ),
                const SizedBox(height: 120,), //incluido para que o filtro não fique por cima do ultimo pedido da lista
              ],
            ),

            minHeight: 40,
            maxHeight: 250,
            panel: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if (panelController.isPanelClosed) {
                      panelController.open();
                    } else {
                      panelController.close();
                    }
                  },
                  child: Container(
                    height: 40,
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: Text(
                      'Filtros',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: Status.values.map((s) {
                      return CheckboxListTile(
                        title: Text(Order.getStatusText(s)),
                        dense: true,
                        activeColor: Theme.of(context).primaryColor,
                        value: ordersManager.statusFilter.contains(s), //verifica se o status está contido no filtro de status atual
                        onChanged: (v) { // se clicar chama a função statusfilter passando o status atual e se está clicado ou não
                          ordersManager.setStatusFilter(
                              status: s,
                              enabled: v
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

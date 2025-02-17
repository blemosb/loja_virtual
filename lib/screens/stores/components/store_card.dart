import 'package:flutter/material.dart';
import 'package:loja_virtual/common/custom_icon_button.dart';
import 'package:loja_virtual/models/store.dart';
import 'package:loja_virtual/helpers/extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';

class StoreCard extends StatelessWidget {

  const StoreCard(this.store);

  final Store store;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    Color colorForStatus(StoreStatus status){
      switch(status){
        case StoreStatus.closed:
          return Colors.red;
        case StoreStatus.open:
          return Colors.green;
        case StoreStatus.closing:
          return Colors.orange;
        default:
          return Colors.green;
      }
    }

    void showError(){
      Scaffold.of(context).showSnackBar(
            const SnackBar(
              content: Text('Esta função não está disponível neste dispositivo'),
              backgroundColor: Colors.red,
            )
      );
    }

    Future<void> openPhone() async {
      if(await canLaunch('tel:${store.cleanPhone}')){
        launch('tel:${store.cleanPhone}');
      } else {
        showError();
      }
    }

    Future<void > openMap() async {
      try {
        final availableMaps = await MapLauncher.installedMaps;

        showModalBottomSheet(
            context: context,
            builder: (_) {
              return SafeArea( //area de segurança para o ios
                child: Column(
                  mainAxisSize: MainAxisSize.min, //ocupa o menor espaço possivel na tela
                  children: <Widget>[
                    for(final map in availableMaps)
                      ListTile(
                        onTap: (){
                          map.showMarker(
                            coords: Coords(store.address.lat, store.address.long),
                            title: store.name,
                            description: store.addressText,
                          );
                          Navigator.of(context).pop(); //some com o dialogo dos apps ao voltar do mapa
                        },
                        title: Text(map.mapName),
                        leading: Image(
                          image: map.icon,
                          width: 30,
                          height: 30,
                        ),
                      )
                  ],
                ),
              );
            }
        );
      } catch (e){
        showError();
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias, //corta a imagem nas bordas do card para ficar arredondado
      child: Column( //imagem em cima e info abaixo
        children: <Widget>[
          Container( //Imagem da loja
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.network(
                  store.image,
                  fit: BoxFit.cover,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8)
                        )
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      store.statusText,
                      style: TextStyle(
                        color: colorForStatus(store.status),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(  //info
            height: 140,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded( //ocupa maior area possível da row
                  child: Column( //nome, endereço e horário da loja
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, //maior espaço possivel entre os itens da coluna
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        store.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        store.addressText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Text(
                        store.openingText,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column( //botoes ao lado
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, //maior espaço possivel entre os elementos. vai ficar um em cima e outro embaixo
                  children: <Widget>[
                    CustomIconButton(
                      iconData: Icons.map,
                      color: primaryColor,
                      onTap: openMap,
                    ),
                    CustomIconButton(
                      iconData: Icons.phone,
                      color: primaryColor,
                      onTap: openPhone,
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
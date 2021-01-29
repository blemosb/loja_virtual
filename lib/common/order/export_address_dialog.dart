import 'package:flutter/material.dart';
import 'package:loja_virtual/models/address.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:screenshot/screenshot.dart';

class ExportAddressDialog extends StatelessWidget {

  ExportAddressDialog(this.address);

  final Address address;

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Endereço de Entrega'),
      content: Screenshot(
        controller: screenshotController,
        child: Container( //engloba o texto em um container e coloca fundo branco senão a imagem salva transparente e não vê nada
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: Text(
            '${address.street}, ${address.number} ${address.complement}\n'
                '${address.district}\n'
                '${address.city}/${address.state}\n'
                '${address.zipCode}',
          ),
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      actions: <Widget>[
        FlatButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final file = await screenshotController.capture(); //salva internamente no app
            await GallerySaver.saveImage(file.path); //salva externamente na galeria
          },
          child: const Text('Exportar'),
        )
      ],
    );
  }
}
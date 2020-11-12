import 'package:flutter/material.dart';

class SearchDialog extends StatelessWidget {

  const SearchDialog(this.initialText);

  final String initialText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget> [
        Positioned(
          top: 2,
          left: 4,
          right: 4,
          child: Card(
            child: TextFormField(
              initialValue: initialText,
              textInputAction: TextInputAction.search,
              autofocus: true, //qdo abrir o dialog já abre o teclado
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15), //texto fica alinhado na vertical
                prefixIcon: IconButton( //cria a seta de voltar
                    icon: Icon(Icons.arrow_back),
                    color: Colors.grey[700],
                    onPressed: () {
                      Navigator.of(context).pop(); //fecha o dialog pop = tirar do topo
                    }
                    )
              ),
              onFieldSubmitted: (text) {
                Navigator.of(context).pop(text); //fecha o dialogo passando o texto digitado
              },
            ),
          ),
        )
      ],
    );
  }
}

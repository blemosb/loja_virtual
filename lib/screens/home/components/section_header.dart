import 'package:flutter/material.dart';
import 'package:loja_virtual/models/section.dart';
import 'package:loja_virtual/common/custom_icon_button.dart';
import 'package:loja_virtual/models/home_manager.dart';
import 'package:provider/provider.dart';

class SectionHeader extends StatelessWidget {
  //título e botoes da seção na tela inicial

  @override
  Widget build(BuildContext context) {
    final homeManager = context.watch<
        HomeManager>(); //outra forma de acessar ma classe sem passar por parâmetro
    final section = context.watch<Section>();

    if (homeManager.editing) {
      //se estiver editando aparece o título atual e um botão à diretira para excluir seção
      return Column( //section header e depois as imagens
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row( //titulo e botões
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  initialValue: section.name,
                  decoration: const InputDecoration(
                      hintText: 'Título',
                      isDense: true,
                      border: InputBorder.none),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                  onChanged: (text) => section.name = text,
                ),
              ),
              CustomIconButton(
                iconData: Icons.remove,
                color: Colors.white,
                onTap: () {
                  homeManager.removeSection(section);
                },
              ),
            ],
          ),
          if (section.error != null) //inclui uma msg de erro, abaixo de titulo, se o usuário tentar salvar uma seção que esteja sem titulo ou
                                    // imagem
            Padding( //insere um cabeçalho para a msg de erro colocando apenas uma margem para separar da imagem abaixo
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                section.error,
                style: const TextStyle(color: Colors.blue),
              ),
            )
        ],
      );
    } else {
      //se não estiver editando...
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          section.name ?? "Banana",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      );
    }
  }
}

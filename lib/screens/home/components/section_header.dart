import 'package:flutter/material.dart';
import 'package:loja_virtual/models/section.dart';
import 'package:loja_virtual/common/custom_icon_button.dart';
import 'package:loja_virtual/models/home_manager.dart';
import 'package:provider/provider.dart';

class SectionHeader extends StatelessWidget { //título da seção na tela inicial

  const SectionHeader(this.section); //é passado por parâmetro uma seção

  final Section section;

  @override
  Widget build(BuildContext context) {
    final homeManager = context.watch<HomeManager>(); //outra forma de acessar ma classe sem passar por parâmetro

    if(homeManager.editing){//se estiver editando aparee o título atual e um botão à diretira para excluir seção
      return Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              initialValue: section.name,
              decoration: const InputDecoration(
                  hintText: 'Título',
                  isDense: true,
                  border: InputBorder.none
              ),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
              onChanged: (text) => section.name = text, //sempre que houver edição desse campo vai salvando para a variavel section.name
            ),
          ),
          CustomIconButton(
            iconData: Icons.remove,
            color: Colors.white,
            onTap: (){
              homeManager.removeSection(section);
            },
          ),
        ],
      );
    } else { //se não estiver editando...
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
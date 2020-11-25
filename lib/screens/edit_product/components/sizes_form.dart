import 'package:flutter/material.dart';
import 'package:loja_virtual/models/item_size.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:loja_virtual/screens/edit_product/components/edit_item_size.dart';
import 'package:loja_virtual/common/custom_icon_button.dart';

class SizesForm extends StatelessWidget { //formulario para mostrar os tamnahos dentro da tela de editar produto

  const SizesForm(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return FormField<List<ItemSize>>(
      initialValue: product.sizes, //copia da lista inicial dos produtos
      validator: (sizes){ //valida se existe tam cadastrado para o produto. senão nao deixa o usuario salvar o produto
        if(sizes.isEmpty)
          return 'Insira um tamanho';
        return null;
      },
      builder: (state) { //estado é a lista de tamanhos...
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded( //cria possibilidade de adicionar um novo tamanho.
                  child: Text(
                    'Tamanhos',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                CustomIconButton(
                  iconData: Icons.add,
                  color: Colors.black,
                  onTap: () {
                    state.value.add(ItemSize());
                    state.didChange(state.value);
                  },
                )
              ],
            ),
            Column(
              children: state.value.map((size){
                return EditItemSize( //tela para adicionar tamanho
                  key: ObjectKey(size), //para trackear o objeto editsize qdo mudar a ordem dos tamanhos
                  size: size,
                  onRemove: (){
                    state.value.remove(size);
                    state.didChange(state.value);
                  },
                  onMoveUp: size != state.value.first ? (){ // se nao for o primeiro
                    final index = state.value.indexOf(size); //pega o indice atual do tamanho
                    state.value.remove(size); //remoe o size selecionado
                    state.value.insert(index-1, size); //insere no novo indice
                    state.didChange(state.value);
                  } : null, //senão é nulo para desabilitar o botao
                  onMoveDown: size != state.value.last ? (){ //se nao for o ultimo
                    final index = state.value.indexOf(size);
                    state.value.remove(size);
                    state.value.insert(index+1, size);
                    state.didChange(state.value);
                  } : null,
                );
              }).toList(),
            ),
            if(state.hasError) //se tiver erro no validate mostrara aqui (embaixo do ultimo widget da tela)
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  state.errorText,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}
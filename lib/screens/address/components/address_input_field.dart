import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loja_virtual/models/address.dart';
import 'package:loja_virtual/models/cart_manager.dart';
import 'package:provider/provider.dart';

class AddressInputField extends StatelessWidget {
  //tela com oa campos do endereço

  const AddressInputField(this.address);

  final Address address;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final cartManager = context.watch<CartManager>(); //monitora notyfy listener do cart manager para pegar mudança no calculo da entrega

    String emptyValidator(String text) =>
        text.isEmpty ? 'Campo obrigatório' : null;
//depois q buscou o cep redesenha para apareer a tela do else abaixo
    if (address.zipCode != null && cartManager.deliveryPrice == null) { //se tiver cep e ainda não tiver calculado entrega então mostra tela para
                                                                        //editar endereço
      print(address.zipCode);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, //para expandir o botao ocupando toda a largura da tela
        children: <Widget>[
          TextFormField(
            enabled: !cartManager.loading,
            //nome da rua
            initialValue: address.street,
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Rua/Avenida',
              hintText: 'Av. Brasil',
            ),
            validator: emptyValidator,
            onSaved: (t) => address.street = t,
          ),
          Row(
            //numero e complemento
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  enabled: !cartManager.loading,
                  initialValue: address.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Número',
                    hintText: '123',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                  validator: emptyValidator,
                  onSaved: (t) => address.number = t,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: TextFormField(
                  enabled: !cartManager.loading,
                  initialValue: address.complement,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Complemento',
                    hintText: 'Opcional',
                  ),
                  onSaved: (t) => address.complement = t,
                ),
              ),
            ],
          ),
          TextFormField(
            //bairro
            initialValue: address.district,
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Bairro',
              hintText: 'Guanabara',
            ),
            validator: emptyValidator,
            onSaved: (t) => address.district = t,
          ),
          Row(
            //cidade e estado
            children: <Widget>[
              Expanded(
                flex: 3,
                child: TextFormField(
                  enabled: false,
                  initialValue: address.city,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Cidade',
                    hintText: 'Campinas',
                  ),
                  validator: emptyValidator,
                  onSaved: (t) => address.city = t,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: TextFormField(
                  autocorrect: false,
                  enabled: false,
                  textCapitalization: TextCapitalization.characters,
                  initialValue: address.state,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'UF',
                    hintText: 'SP',
                    counterText:
                        '', //e não colocar isso, para campos om maxlength aparece qtde de caracteres a serem digitados
                  ),
                  maxLength: 2,
                  validator: (e) {
                    if (e.isEmpty) {
                      return 'Campo obrigatório';
                    } else if (e.length != 2) {
                      return 'Inválido';
                    }
                    return null;
                  },
                  onSaved: (t) => address.state = t,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8,),
          if(cartManager.loading)
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(primaryColor),
              backgroundColor: Colors.transparent,
            ),
          RaisedButton(
            //botão calcular frete
            color: primaryColor,
            disabledColor: primaryColor.withAlpha(100),
            textColor: Colors.white,
            onPressed: !cartManager.loading ? () async {
              if (Form.of(context).validate()) {
                //não usa a goblal key pq o form está em outro widget acima, na tela anterior
                Form.of(context)
                    .save(); //chama o onSave de cada campo do form e salva na variável indicada em cada campo
                try {
                  //metodo que seta o endereço e calcula frete. se tudo der ok ele redesenha a tela cep e address. a cep permanece a mesma
                  //porque o cep é não nulo a address muda porque o cep é não nulo e o delivery price tb não. deenha uma resumida com o address
                  await context.read<CartManager>().setAddress(address);
                } catch (e) {
                  //se estiver fora do raio de entrega exibe uma msg ao usuario
                  Scaffold.of(context).showSnackBar(
                      //o scaffold está em um widget filho, por isso nao precisa da key
                      SnackBar(
                    content: Text('$e'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            }: null,
            child: const Text('Calcular Frete'),
          ),
        ],
      );
    } else if (address.zipCode != null) //se tiver um endereço e delivery exibe apenas um texto com o endereço completo
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child:
            Text('${address.street}, ${address.number}\n${address.district}\n'
                '${address.city} - ${address.state}'),
      );
    else
      return Container();
  }
}

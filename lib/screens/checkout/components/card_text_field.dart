import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardTextField extends StatelessWidget {
  //mostra as informações no cartão
  const CardTextField({
    this.title,
    this.bold = false,
    this.hint,
    this.textInputType,
    this.inputFormatters,
    this.validator,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.onSubmitted,
  }) : textInputAction = onSubmitted == null //se for null aparece icone de pronto senão de proximo
      ? TextInputAction.done //parte de trás do cartão
      : TextInputAction.next; //parte da frente

  final String title;
  final bool bold;
  final String hint;
  final TextInputType textInputType;
  final List<TextInputFormatter> inputFormatters;
  final FormFieldValidator<String> validator;
  final int maxLength;
  final TextAlign textAlign;
  final FocusNode focusNode;
  final Function(String) onSubmitted;
  final TextInputAction textInputAction; //campo para customizar o icone do teclado de proximo ou done

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: '',
      validator: validator,
      builder: (state) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if(title != null) //se estiver desenhando a parte de trás do cartao não tem titulo
                Row(
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.white
                      ),
                    ),
                    if(state.hasError)
                      const Text(
                        '   Inválido',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 9,
                        ),
                      )
                ],
              ),
              TextFormField(
                style: TextStyle(
                  color: title == null && state.hasError
                      ? Colors.red : Colors.white,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                ),
                decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                        color: title == null && state.hasError
                            ? Colors.red.withAlpha(200)
                            : Colors.white.withAlpha(100)
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 2),
                  counterText: '', //senão aparece contador de caracters para preencher o total do campo
                ),
                keyboardType: textInputType,
                inputFormatters: inputFormatters,
                onChanged: (text) {
                  state.didChange(text);
                },
                maxLength: maxLength,
                textAlign: textAlign,
                focusNode: focusNode,
                onFieldSubmitted: onSubmitted,
                textInputAction: textInputAction,
              ),
            ],
          ),
        );
      },
    );
  }
}

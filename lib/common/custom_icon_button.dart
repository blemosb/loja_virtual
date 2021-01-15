import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget { //customização de botões para ficar menor q o tamanho original do flutter

  const CustomIconButton({this.iconData, this.color, this.onTap, this.size});

  final IconData iconData;
  final Color color;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect( //deixar o efeito circular
      borderRadius: BorderRadius.circular(50),
      child: Material(
        color: Colors.transparent,
        child: InkWell( //semelhante ao gesture detector mas com uma animaçao
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(
              iconData,
              color: onTap != null ? color : Colors.grey[400], //se ontap for null aparece cor de desabilitado
              size: size ?? 24, //se for passado nulo pega o tam 24 q é o padrao do flutter
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

extension Extra on TimeOfDay {

  String formatted(){
    return '${hour}h${minute.toString().padLeft(2, '0')}'; //min sempre com 2 digitos e se tiver um acrescenta um 0
  }

  int toMinutes() => hour*60 + minute;

}
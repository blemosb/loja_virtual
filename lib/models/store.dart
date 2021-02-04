import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/models/address.dart';
import 'package:loja_virtual/helpers/extensions.dart';

enum StoreStatus { closed, open, closing }

class Store {


  String name;
  String image;
  String phone;
  Address address;
  StoreStatus status;
  Map<String, Map<String, TimeOfDay>> opening;
//string > dias da semana
  //map > from to

  Store.fromDocument(DocumentSnapshot doc){
    name = doc.data()['name'] as String;
    image = doc.data()['image'] as String;
    phone = doc.data()['phone'] as String;
    address = Address.fromMap(doc.data()['address'] as Map<String, dynamic>);

    opening = (doc.data()['opening'] as Map<String, dynamic>).map((key, value) {
      final timesString = value as String;

      if(timesString != null && timesString.isNotEmpty){
        final splitted = timesString.split(RegExp(r"[:-]")); //divide a expressao em : - ex.: 8:00-12:00 divide em 8 00 12 00

        return MapEntry(
            key,
            {
              "from": TimeOfDay(
                  hour: int.parse(splitted[0]), //pega a hora de abertura
                  minute: int.parse(splitted[1]) //pega o minuto de abertura
              ),
              "to": TimeOfDay(
                  hour: int.parse(splitted[2]), //pega a hora de fechamento
                  minute: int.parse(splitted[3]) //pega o minuto de fechamento
              ),
            }
        );
      } else {
        return MapEntry(key, null);
      }
    });

    updateStatus();
  }

  String get cleanPhone => phone.replaceAll(RegExp(r"[^\d]"), ""); //o ^ignora todos os digitos e substitui po "". no caso fica so o digito

  String get statusText {
    switch(status){
      case StoreStatus.closed:
        return 'Fechada';
      case StoreStatus.open:
        return 'Aberta';
      case StoreStatus.closing:
        return 'Fechando';
      default:
        return '';
    }
  }

  String get openingText {
    return
      'Seg-Sex: ${formattedPeriod(opening['monfri'])}\n'
          'Sab: ${formattedPeriod(opening['saturday'])}\n'
          'Dom: ${formattedPeriod(opening['sunday'])}';
  }

  String formattedPeriod(Map<String, TimeOfDay> period){
    if(period == null) return "Fechada";
    return '${period['from'].formatted()} - ${period['to'].formatted()}';
  }

  String get addressText =>
      '${address.street}, ${address.number}${address.complement.isNotEmpty ? ' - ${address.complement}' : ''} - '
          '${address.district}, ${address.city}/${address.state}';

//calcula se loja esta aberta ou nao
  void updateStatus(){
    final weekDay = DateTime.now().weekday;

    Map<String, TimeOfDay> period;
    if(weekDay >= 1 && weekDay <= 5){
      period = opening['monfri'];
    } else if(weekDay == 6){
      period = opening['saturday'];
    } else {
      period = opening['sunday'];
    }

    final now = TimeOfDay.now();

    if(period == null){
      status = StoreStatus.closed;
    } else if(period['from'].toMinutes() < now.toMinutes()
        && period['to'].toMinutes() - 15 > now.toMinutes()){
      status = StoreStatus.open;
    } else if(period['from'].toMinutes() < now.toMinutes()
        && period['to'].toMinutes() > now.toMinutes()){
      status = StoreStatus.closing;
    } else {
      status = StoreStatus.closed;
    }
  }

}
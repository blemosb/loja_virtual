import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/models/store.dart';
import 'dart:async';

class StoresManager extends ChangeNotifier {

  Timer _timer;
  List<Store> stores = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StoresManager(){
    _loadStoreList();
    _startTimer();
  }
//função que inicia um monitoramento para atualizar status da loja. executa a cada 5min
  void _startTimer(){
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkOpening();
    });
  }

  void _checkOpening(){
    for(final store in stores)
      store.updateStatus();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  Future<void> _loadStoreList() async {
    final snapshot = await firestore.collection('stores').get();

    stores = snapshot.docs.map((e) => Store.fromDocument(e)).toList();

    notifyListeners();
  }

}
import 'package:flutter/cupertino.dart';

class PageManager extends ChangeNotifier {

  final PageController _pageController;
  int page=0;
  PageManager(this._pageController);

  void setPage(int value){
    //se tentar ir para  a mesma página nao faz nada
    if (page==value){
      return;
    }
    page = value;
    _pageController.jumpToPage(value);
  }

}
import 'package:flutter/material.dart';

class Questnoti extends ChangeNotifier {
  int totalReviews = 0;
  int totalLapses = 0;
  int totalCards = 0;

  void printHello() {
    debugPrint("helloworld");
  }

  Future<void> setToDB(int rep, int lapse, int cardno) async {
    totalReviews += rep;
    totalLapses += lapse;
    totalCards += cardno;
    notifyListeners();
  }
}



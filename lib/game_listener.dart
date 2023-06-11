import 'package:flutter/material.dart';

class GameListener with ChangeNotifier {
  void update() {
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

class GameListener with ChangeNotifier {
  void update() {
    notifyListeners();
  }
}

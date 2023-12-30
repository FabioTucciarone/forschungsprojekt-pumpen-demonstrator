import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RestartTimer extends ChangeNotifier {
  late Timer timer;

  RestartTimer() {
    timer = Timer(const Duration(seconds: 10), () {
      print("First Timeout");
      notifyListeners();
    });
  }

  void restartTimer() {
    timer.cancel();
    timer = Timer(const Duration(seconds: 10), () {
      print("Timeout");
      notifyListeners();
    });
  }
}

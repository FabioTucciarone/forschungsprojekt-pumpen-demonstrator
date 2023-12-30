import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RestartTimer extends ChangeNotifier {
  late Timer timer;

  RestartTimer() {
    restartTimer();
  }

  void restartTimer() {
    timer = Timer(const Duration(seconds: 10), () {
      print("Timeout");
      notifyListeners();
    });
  }
}

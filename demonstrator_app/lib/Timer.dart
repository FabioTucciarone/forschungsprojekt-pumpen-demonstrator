import 'dart:async';
import 'package:flutter/material.dart';

//Timer for Timeouts in Kinder Version
class RestartTimer extends ChangeNotifier {
  late Timer timer;

  RestartTimer() {
    timer = Timer(const Duration(seconds: 60), () {
      notifyListeners();
    });
  }

  void restartTimer() {
    timer.cancel();
    timer = Timer(const Duration(seconds: 60), () {
      notifyListeners();
    });
  }
}

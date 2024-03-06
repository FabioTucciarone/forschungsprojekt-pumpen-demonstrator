import 'dart:async';
import 'package:flutter/material.dart';
import 'Highscores.dart';
import 'MainScreen.dart';

//Timer for Timeouts in Kinder Version
class RestartTimer extends ChangeNotifier {
  late Timer timer;

  RestartTimer() {
    timer = Timer(const Duration(seconds: 180), () {
      resetValues();
      notifyListeners();
    });
  }

  void restartTimer() {
    timer.cancel();
    timer = Timer(const Duration(seconds: 180), () {
      resetValues();
      notifyListeners();
    });
  }

  void resetValues() {
    AverageError.publicError = 0;
    MainSlide.futureNotifier.setFuture(Future(() => "keinWert"));
    MainSlide.futureNotifierPhase2.setFuture(Future(() => "keinWert"));
  }
}

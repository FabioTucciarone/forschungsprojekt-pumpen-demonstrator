import 'dart:async';
import 'package:flutter/material.dart';
import 'Highscores.dart';
import 'MainScreen.dart';

/// Timer for Timeouts in Children Version.
class RestartTimer extends ChangeNotifier {
  late Timer timer;
  final int timeout = 180;

  RestartTimer() {
    timer = Timer(Duration(seconds: timeout), () {
      resetValues();
      notifyListeners();
    });
  }

  void restartTimer() {
    timer.cancel();
    timer = Timer(Duration(seconds: timeout), () {
      resetValues();
      notifyListeners();
    });
  }

  /// Resets values after a timeout.
  void resetValues() {
    AverageError.publicError = 0;
    MainSlide.futureNotifier.setFuture(Future(() => "keinWert"));
    MainSlide.futureNotifierPhase2.setFuture(Future(() => "keinWert"));
  }
}

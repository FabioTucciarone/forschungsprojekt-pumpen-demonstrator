import 'package:flutter/material.dart';
import 'dart:collection';

class InputData extends ChangeNotifier {
  /* 
   * TODO: Klassenstruktur für Eingabedaten
   * Aufruf von notifyListeners() bei änderung der Daten, um entsprechende Widgets zu benachrichtigen sich neu zu bauen.
   */

  // Beispiel:
  final List<int> datapoints = [];
  UnmodifiableListView<int> get view => UnmodifiableListView(datapoints);

  void add(int number) {
    datapoints.add(number);
    notifyListeners();
  }
}

class OutputData extends ChangeNotifier {
  /* 
   * TODO: Klassenstruktur für Ausgabe-/Anzeigedaten
   * Aufruf von notifyListeners() bei änderung der Daten, um entsprechende Widgets zu benachrichtigen sich neu zu bauen.
   */

  // Beispiel:
  List<int> datapoints = [];
  UnmodifiableListView<int> get view => UnmodifiableListView(datapoints);
  set list(List<int> datapoints) {
    this.datapoints = datapoints;
    notifyListeners();
  }
}
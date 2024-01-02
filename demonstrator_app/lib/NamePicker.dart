import 'dart:math';
import 'package:flutter/services.dart';

class NamePicker {
  static late List<String> names;

  static Future<void> loadNameFile() async {
    try {
      final String fileContents =
          await rootBundle.loadString('assets/names.txt');
      final List<String> lines = fileContents
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
      names = lines;
      print("Names Loaded");
    } catch (e) {
      print('Error reading file: $e');
      names = [];
    }
  }

  static String getRandomName() {
    if (names == null || names.isEmpty) {
      return 'No names loaded.';
    }
    final random = Random();
    final randomIndex = random.nextInt(names.length);
    return names[randomIndex];
  }
}

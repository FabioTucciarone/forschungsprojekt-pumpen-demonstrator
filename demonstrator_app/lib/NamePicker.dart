import 'dart:math';
import 'package:flutter/services.dart';

/// Class for the usernames which are used in the children version.
class NamePicker {
  static late List<String> names;

  /// Loads possible usernames from names.txt.
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

  /// Selects a random username.
  static String getRandomName() {
    if (names == null || names.isEmpty) {
      return 'Error: No names loaded.';
    }
    final random = Random();
    final randomIndex = random.nextInt(names.length);
    return names[randomIndex];
  }
}

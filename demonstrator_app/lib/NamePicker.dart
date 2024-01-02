import 'dart:io';
import 'dart:math';

class NamePicker {
  static late List<String> names;

  static Future<void> loadNameFile() async {
    try {
      final File file = File('assets/names.txt');
      final List<String> lines = await file.readAsLines();
      names = lines.where((line) => line.trim().isNotEmpty).toList();
      print("done");
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

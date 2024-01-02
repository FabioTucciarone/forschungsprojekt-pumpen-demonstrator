import 'package:demonstrator_app/Layout.dart';
import 'package:demonstrator_app/NamePicker.dart';
import 'package:flutter/material.dart';

void main() {
  NamePicker.loadNameFile();
  runApp(const Introduction());
}

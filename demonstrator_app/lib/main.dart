import 'package:demonstrator_app/Layout.dart';
import 'BackendConnection.dart';
import 'package:flutter/material.dart';

void main() {
  final BackendConnection backend = new BackendConnection();
  runApp(Introduction(
    backend: backend,
  ));
}

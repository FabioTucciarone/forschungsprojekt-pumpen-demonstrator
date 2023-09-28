import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'Data.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  /*
   * "Notifier"-Widgets sind für alle in der Baumhierarchie absteigenden Widgets sichtbar.
   * Da die Eingabe auch die Ausgabe beeinflusst: Verschachtelung
   */
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider(
          create: (context) => InputData(),
          child: ChangeNotifierProvider(
            create: (context) => OutputData(),
            child: const DataDisplay(),
          ),
        ),
      ),
    );
  }
}

class DataDisplay extends StatelessWidget {
  const DataDisplay({super.key});

  /*
   * Aktualisiere Ein- und Ausgabedaten durch Knopfdruck
   * Eingabedaten: direkt hier aktualisiert
   * Ausgabedaten: HTTP-Anfrage an Python Backend
   */
  void handleInputChange(BuildContext context) {
    var inputData = context.read<InputData>();
    if(inputData.view.isEmpty) {
      inputData.add(0);
    }
    else {
      inputData.add(inputData.view.last + 1);
    }
    updateOutputData(inputData, context.read<OutputData>());
  }

  /*
   * Stelle HTTP-Anfrage und aktualisiere Daten
   */
  void updateOutputData(InputData inputData, OutputData outputData) {
    http.post(
      Uri.parse('http://127.0.0.1:5000'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(inputData.view),
    ).then((response) {
      if (response.statusCode == 200) {
        dynamic responseList = jsonDecode(response.body);
        outputData.list = List<int>.from(responseList as List);
      } else {
        print('Uh oh, schlechti :(');
      }
    }).catchError((error) {
      print('Uh oh, schlechti :(');
    });   
  }

  /*
   * Darstellung der Daten und des Knopfs
   */
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () => handleInputChange(context), 
          child: const Text("Ändere Eingabe"),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,

          // Möglichst weit unten in der Hierarchie, um unnötiges Neubauen des Rests zu verhindern.  
          children: <Widget>[
            Consumer<InputData>(builder: (context, data, child) => Text('Data: ${data.view} (Aktualisiert von Flutter)')), // Akualisiert durch notifyListeners()
            Consumer<OutputData>(builder: (context, data, child) =>  Text('Data: ${data.view} (Aktualisiert von Python-Backend)')), // Akualisiert durch notifyListeners()
          ],
        ),
      ],
    );
  }
}

import 'package:demonstrator_app/Checkboxes.dart';
import 'package:demonstrator_app/Layout.dart';
import 'package:demonstrator_app/Outputbox.dart';
import 'Slider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class MainSlide extends StatelessWidget {
  MainSlide({super.key});

  final FutureNotifier futureNotifier = FutureNotifier();

  @override
  Widget build(BuildContext context) {
    PressureSlider pressure = PressureSlider(
        900, pow(10, -11).toDouble(), 5 * pow(10, -9).toDouble(), 'Druck');
    PressureSlider permeability = PressureSlider(
        900,
        -4 * pow(10, -3).toDouble(),
        -1 * pow(10, -3).toDouble(),
        'Durchlässigkeit');
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => CheckboxModel(),
          ),
          ChangeNotifierProvider<FutureNotifier>(
            create: ((context) => futureNotifier),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text("Demonstrator App"),
              backgroundColor: Color.fromARGB(255, 184, 44, 44),
              titleTextStyle:
                  const TextStyle(color: Colors.black, fontSize: 25),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.black,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Introduction()));
                  }),
            ),
            backgroundColor: Color.fromARGB(255, 221, 115, 115),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  pressure,
                  const SizedBox(
                    height: 10,
                  ),
                  permeability,
                  const SizedBox(
                    height: 10,
                  ),
                  CheckboxBox(),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Output:",
                    textScaleFactor: 2,
                  ),
                  OutputBox(
                    name: "AI Generated",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  OutputBox(
                    name: "Groundtruth",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  OutputBox(
                    name: "Difference Field",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 184, 44, 44),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          futureNotifier.setFuture(useOfBackend.backend
                              .sendInputData(permeability.getCurrent(),
                                  pressure.getCurrent(), ""));
                        },
                        child: const Text(
                          "Anwenden",
                          textScaleFactor: 1.8,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class FutureNotifier extends ChangeNotifier {
  Future<String> future = Future.value("keinWert");

  Future<String> get getFuture => future;

  void setFuture(Future<String> newFuture) {
    future = newFuture;
    notifyListeners();
  }
}

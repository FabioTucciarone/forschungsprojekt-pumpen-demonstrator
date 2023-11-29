import 'package:demonstrator_app/Checkboxes.dart';
import 'package:demonstrator_app/Layout.dart';
import 'package:demonstrator_app/Outputbox.dart';
import 'package:flutter/services.dart';
import 'Intro.dart';
import 'Slider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'BackendConnection.dart';

class MainSlideKids extends StatelessWidget {
  MainSlideKids({super.key});

  final FutureNotifier futureNotifier = FutureNotifier();

  @override
  Widget build(BuildContext context) {
    PressureSlider pressure = PressureSlider(800, 870000, 910000, 'Druck');
    PressureSlider permeability =
        PressureSlider(800, 870000, 910000, 'Durchlässigkeit');
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => CheckboxModel(),
          ),
          ChangeNotifierProvider<FutureNotifier>(
              create: ((context) => futureNotifier)),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text("Demonstrator App"),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => IntroScreen()));
                  }),
            ),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  OutputBox(
                    name: "erste Outputboxx",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  OutputBox(
                    name: "zweite Outputboxx",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
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
                  ElevatedButton(
                    onPressed: () {
                      futureNotifier.setFuture(useOfBackend.backend
                          .sendInputData(permeability.getCurrent(),
                              pressure.getCurrent()));
                    },
                    child: const Text(
                      "Anwenden",
                      textScaleFactor: 2,
                    ),
                  )
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

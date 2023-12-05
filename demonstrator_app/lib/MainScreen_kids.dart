import 'package:demonstrator_app/Checkboxes.dart';
import 'package:demonstrator_app/Layout.dart';
import 'package:demonstrator_app/Outputbox.dart';
import 'package:flutter/services.dart';
import 'Intro.dart';
import 'Slider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'MainScreen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class MainSlideKids extends StatelessWidget {
  MainSlideKids({super.key});

  final FutureNotifier futureNotifier = FutureNotifier();

  @override
  Widget build(BuildContext context) {
    PressureSlider pressure = PressureSlider(900, -4 * pow(10, -3).toDouble(),
        -1 * pow(10, -3).toDouble(), 'Druck', -4 * pow(10, -3).toDouble());
    PressureSlider permeability = PressureSlider(900, pow(10, -11).toDouble(),
        5 * pow(10, -9).toDouble(), 'Durchlässigkeit', pow(10, -11).toDouble());
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
              backgroundColor: OurColors.appBarColor,
              titleTextStyle:
                  const TextStyle(color: Colors.black, fontSize: 25),
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.black,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => IntroScreen()));
                  }),
            ),
            backgroundColor: OurColors.backgroundColor,
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
                  const CheckboxBox(),
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
                          backgroundColor: OurColors.appBarColor,
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
                          style: TextStyle(color: OurColors.textColor),
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

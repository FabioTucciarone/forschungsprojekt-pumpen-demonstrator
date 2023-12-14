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

class Phase1Kids extends StatelessWidget with MainScreenKidsElements {
  final FutureNotifier futureNotifier;
  Phase1Kids(this.futureNotifier, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Row(
            children: [
              Column(
                children: [...input()],
              ),
              const SizedBox(
                width: 100,
              ),
              RobotBox()
            ],
          ),
          ...output(),
          AnwendenButton(
              futureNotifier: futureNotifier,
              permeability: getPermeability(),
              pressure: getPressure()),
        ],
      ),
    );
  }
}

mixin MainScreenKidsElements {
  final PressureSlider pressure = PressureSlider(
      500,
      -4 * pow(10, -3).toDouble(),
      -1 * pow(10, -3).toDouble(),
      'Druck',
      -4 * pow(10, -3).toDouble());
  final PressureSlider permeability = PressureSlider(
      500,
      pow(10, -11).toDouble(),
      5 * pow(10, -9).toDouble(),
      'Durchlässigkeit',
      pow(10, -11).toDouble());

  PressureSlider getPressure() {
    return pressure;
  }

  PressureSlider getPermeability() {
    return permeability;
  }

  List<Widget> input() {
    return <Widget>[
      pressure,
      const SizedBox(
        height: 10,
      ),
      permeability,
    ];
  }

  List<Widget> output() {
    return <Widget>[
      const SizedBox(
        height: 10,
      ),
      const Text(
        "Ausgabe:",
        textScaleFactor: 2,
      ),
      OutputBox(
        name: ImageType.aIGenerated,
      ),
      const SizedBox(
        height: 10,
      ),
      OutputBox(
        name: ImageType.groundtruth,
      ),
      const SizedBox(
        height: 10,
      ),
      OutputBox(
        name: ImageType.differenceField,
      ),
      const SizedBox(
        height: 10,
      ),
    ];
  }
}

class RobotBox extends StatefulWidget {
  RobotBox({super.key});

  @override
  State<RobotBox> createState() => _RobotBoxState();
}

class _RobotBoxState extends State<RobotBox> {
  List<String> imagePaths = [
    'assets/happy.png',
    'assets/bored.jpeg',
    'assets/confused.jpeg',
    'assets/mad.jpeg',
  ];
  int imageValue = 0;
  final ResponseDecoder responseDecoder = ResponseDecoder();
  @override
  Widget build(BuildContext context) {
    final Future<String> future = context.watch<FutureNotifier>().future;
    return FutureBuilder<String>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        Widget child;
        if (snapshot.connectionState == ConnectionState.done) {
          imageValue = 1;
          if (snapshot.data != "keinWert") {
            responseDecoder.setResponse(snapshot.data);
            double averageError = responseDecoder.jsonDecoded["average_error"];
            print(averageError);
            if (averageError > 0.02) {
              imageValue = 2;
            }
            if (averageError > 0.1) {
              imageValue = 3;
            }
          }
        } else {
          imageValue = 0;
        }
        child = Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(50)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1000),
              child: Image.asset(imagePaths[imageValue], fit: BoxFit.cover),
            ));
        return child;
      },
    );
  }
}

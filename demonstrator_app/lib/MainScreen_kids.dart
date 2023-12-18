import 'package:chat_bubbles/chat_bubbles.dart';
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
  Phase1Kids({super.key});

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
              RobotBox()
            ],
          ),
          ...output(),
        ],
      ),
    );
  }
}

mixin MainScreenKidsElements {
  static PressureSlider pressureSlider = PressureSlider(
      500,
      const {
        "pressure_range": [0, 1],
        "permeability_range": [0, 1]
      },
      SliderType.pressure,
      0);
  final Widget pressureWidget = FutureBuilder(
      future: useOfBackend.backend.getValueRanges(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        Widget child;
        if (snapshot.connectionState == ConnectionState.done) {
          pressureSlider =
              PressureSlider(500, snapshot.data, SliderType.pressure, 0);
          child = pressureSlider;
        } else {
          child = const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: OurColors.accentColor,
            ),
          );
        }
        return child;
      });

  static PressureSlider permeabilitySlider = PressureSlider(
      500,
      const {
        "pressure_range": [0, 1],
        "permeability_range": [0, 1]
      },
      SliderType.pressure,
      0);
  final Widget permeabilityWidget = FutureBuilder(
      future: useOfBackend.backend.getValueRanges(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        Widget child;
        if (snapshot.connectionState == ConnectionState.done) {
          permeabilitySlider =
              PressureSlider(500, snapshot.data, SliderType.permeability, 0);
          child = permeabilitySlider;
        } else {
          child = const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: OurColors.accentColor,
            ),
          );
        }
        return child;
      });

  List<Widget> input() {
    return <Widget>[
      pressureWidget,
      const SizedBox(
        height: 10,
      ),
      permeabilityWidget,
    ];
  }

  List<Widget> output() {
    return <Widget>[
      const SizedBox(
        height: 10,
      ),
      ScoreBoard(),
      OutputBox(
        name: ImageType.aIGenerated,
      ),
      Container(
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
    'assets/happy.jpeg',
    'assets/bored.jpeg',
    'assets/confused.jpeg',
    'assets/mad.jpeg',
  ];
  List<String> loading = [
    "Hmmmmm",
    "Einen Moment",
    "Ich bin gespannt",
    "Mutig",
    "Gewagte Eingabe",
    "Das wird besimmt gut"
  ];
  List<String> lowScore = [
    "Das geht noch viel besser!!",
    "@#%&!@#%&!@#%&!",
    "Das hilft mir leider nicht"
  ];
  List<String> midScore = [
    "Nicht schlecht aber das geht besser!",
    "Ich glaub da geht noch was!",
    "Ganz okay..."
  ];
  List<String> highScore = [
    "WOWWWW",
    "YIPPIE jetzt kann ich mich verbessern",
    "DANKESCHÖN"
  ];

  Random random = Random();
  int imageValue = 0;
  String text = "DIESER TEXT SOLLTE MAN NICHT SEHEN";
  final ResponseDecoder responseDecoder = ResponseDecoder();
  @override
  Widget build(BuildContext context) {
    final Future<String> future = context.watch<FutureNotifier>().future;
    return FutureBuilder<String>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        Widget child;
        if (snapshot.connectionState == ConnectionState.done) {
          int randomScore = random.nextInt(lowScore.length);
          text = lowScore[randomScore];
          imageValue = 3;
          if (snapshot.data != "keinWert") {
            responseDecoder.setResponse(snapshot.data);
            double averageError = responseDecoder.jsonDecoded["average_error"];
            print(averageError);
            if (averageError > 0.15) {
              text = midScore[randomScore];
              imageValue = 1;
            }
            if (averageError > 0.4) {
              imageValue = 0;
              text = highScore[randomScore];
            }
          } else {
            text =
                "Hey los geht's! Bewege die Schieberegler und drücke auf den Knopf unten um loszulegen!";
            imageValue = 0;
          }
        } else {
          int randomLoading = random.nextInt(loading.length);
          imageValue = 2;
          text = loading[randomLoading];
        }
        child = Container(
          width: 450,
          height: 300,
          child: Stack(children: <Widget>[
            Positioned(
              left: 150,
              child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                      border: Border.all(width: 5),
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(200)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1000),
                    child:
                        Image.asset(imagePaths[imageValue], fit: BoxFit.cover),
                  )),
            ),
            Positioned(
                left: 0,
                child: BubbleSpecialThree(
                  text: text,
                  color: OurColors.accentColor,
                  tail: true,
                  constraints:
                      const BoxConstraints(maxHeight: 200, maxWidth: 200),
                  textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      decoration: TextDecoration.none),
                ))
          ]),
        );
        return child;
      },
    );
  }
}

class ScoreBoard extends StatelessWidget {
  ScoreBoard({super.key});
  ResponseDecoder responseDecoder = ResponseDecoder();
  @override
  Widget build(BuildContext context) {
    final Future<String> future = context.watch<FutureNotifier>().future;
    return Row(
      children: [
        FutureBuilder(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != "keinWert") {
                  responseDecoder.setResponse(snapshot.data);
                  double averageError =
                      responseDecoder.jsonDecoded["average_error"];
                  int roundedError = (averageError * 10000).round();
                  child = Container(
                    width: 200,
                    decoration: BoxDecoration(
                        color: OurColors.accentColor,
                        border: Border.all(
                            color: OurColors.appBarColor, width: 4.0),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "Score: $roundedError",
                      textScaleFactor: 2,
                    ),
                  );
                } else {
                  child = Container(
                    width: 200,
                    decoration: BoxDecoration(
                        color: OurColors.accentColor,
                        border: Border.all(
                            color: OurColors.appBarColor, width: 4.0),
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text(
                      "Score: -",
                      textScaleFactor: 2,
                    ),
                  );
                }
              } else {
                child = Container(
                  width: 200,
                  decoration: BoxDecoration(
                      color: OurColors.accentColor,
                      border:
                          Border.all(color: OurColors.appBarColor, width: 4.0),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Text(
                        "Score:",
                        textScaleFactor: 2,
                      ),
                      const SizedBox(
                        child: CircularProgressIndicator(
                          color: OurColors.accentColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return child;
            })
      ],
    );
  }
}

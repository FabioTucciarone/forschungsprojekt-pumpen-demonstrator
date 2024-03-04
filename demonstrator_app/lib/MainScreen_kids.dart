import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:demonstrator_app/Outputbox.dart';
import 'Highscores.dart';
import 'Intro.dart';
import 'MainScreen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class Phase1Kids extends StatelessWidget with MainScreenElements {
  Phase1Kids({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 1350,
        height: 730,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [...input(500, true, true)],
                  ),
                  RobotBox()
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ScoreBoard(true),
              ...output(true),
            ],
          ),
        ),
      ),
    );
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
    'assets/starry.jpeg'
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
    "Oh, hier muss ich mich noch verbessern, danke!",
    "Yay, jetzt lerne ich dazu!",
    "Upsi, hier war ich noch nicht so gut!",
    "Gut machst du das!",
    "Genau so! Jetzt weiß ich, wo ich falsch liege!"
  ];

  Random random = Random();
  int imageValue = 0;
  String text = "";
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
            if (averageError > 0.003) {
              text = midScore[randomScore];
              imageValue = 1;
            }
            if (averageError > 0.01) {
              imageValue = 0;
              text = highScore[randomScore];
            } else if (averageError > 0.08) {
              imageValue = 4;
              text = highScore[randomScore];
            }
          } else {
            text = "Hey los geht's! Bewege die Schieberegler um loszulegen!";
            imageValue = 0;
          }
        } else {
          int randomLoading = random.nextInt(loading.length);
          imageValue = 2;
          text = loading[randomLoading];
        }
        child = SizedBox(
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

class Phase2Kids extends StatefulWidget with MainScreenElements {
  Phase2Kids({super.key});

  @override
  State<Phase2Kids> createState() => _Phase2KidsState();
}

class _Phase2KidsState extends State<Phase2Kids> with MainScreenElements {
  int state = 0;

  @override
  Widget build(BuildContext context) {
    setState(() {
      state++;
    });

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 1350,
        height: 700,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Transform.translate(
                        offset: Offset(90, 0),
                        child: Container(
                          constraints: BoxConstraints(minHeight: 200),
                          width: 800,
                          child: const SpeechBubblePhase2(),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      ...input(500, true, false)
                    ],
                  ),
                  Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                          border: Border.all(width: 5),
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(200)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1000),
                        child:
                            Image.asset('assets/happy.jpeg', fit: BoxFit.cover),
                      )),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Position der zweiten Wärmepumpe:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: OurColors.textColor),
                textScaleFactor: 1.2,
              ),
              outputSecondPhase(true),
            ],
          ),
        ),
      ),
    );
  }
}

class SpeechBubblePhase2 extends StatefulWidget {
  const SpeechBubblePhase2({super.key});

  @override
  State<SpeechBubblePhase2> createState() => _SpeechBubblePhase2State();
}

class _SpeechBubblePhase2State extends State<SpeechBubblePhase2> {
  int state = 0;
  bool slider = FutureNotifierPhase2.slider;
  List<String> speeches = [
    "Hallo ich bin es wieder. Wir wollen uns jetzt 2 Wärmepumpen anschauen!\n"
        "Du kannst wie gewohnt zuerst die Schieberegler bewegen.\n"
        "Du kannst jetzt aber auch direkt in das Feld unten reinklicken um die Position einer zweiten Wärmepumpe zu bestimmen! Probier es aus!"
  ];
  String firstSlider =
      "Super, klicke jetzt unten irgendwo in das Feld rein und ändere die Position der zweiten Wärmepumpe!";
  String firstClick =
      "Super, fällt dir schon was auf? Die Wärmepumpen beeinflussen sich, oder?\n"
      "Du kannst jetzt wie vorhin auch die Schieberegler anpassen und experimentieren!";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: context.watch<FutureNotifierPhase2>().future,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          Widget child;
          if (snapshot.connectionState == ConnectionState.done) {
            state++;
            slider = FutureNotifierPhase2.slider;
          }
          String speech = speeches[0];
          if (state == 2) {
            if (slider) {
              speech = firstSlider;
            } else {
              speech = firstClick;
            }
          }

          child = BubbleSpecialThree(
            text: speech,
            color: OurColors.accentColor,
            tail: true,
            textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none),
          );
          return child;
        });
  }
}

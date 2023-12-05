import 'package:audioplayers/audioplayers.dart';
import 'package:demonstrator_app/MainScreen.dart';
import 'package:flutter/material.dart';
import 'MainScreen_kids.dart';
import 'Layout.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class IntroScience extends StatelessWidget {
  const IntroScience({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: OurColors.appBarColor,
              title: const Text("Demonstrator App"),
              titleTextStyle: const TextStyle(
                  color: OurColors.appBarTextColor, fontSize: 25),
            ),
            backgroundColor: OurColors.backgroundColor,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 700,
                    height: 300,
                    decoration: BoxDecoration(color: OurColors.accentColor),
                    child: const Center(
                      child: Text(
                        "TODO Wissenschaft Einführungstext",
                        textScaleFactor: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            OurColors.appBarColor,
                          )),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainSlide()));
                      },
                      child: const Text(
                        "Verstanden",
                        style: TextStyle(color: OurColors.textColor),
                      ))
                ],
              ),
            )));
  }
}

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RobotIntro(),
    );
  }
}

class RobotIntro extends StatefulWidget {
  const RobotIntro({super.key});

  @override
  State<RobotIntro> createState() => _RobotIntroState();
}

class _RobotIntroState extends State<RobotIntro> {
  bool speechBubble = false;
  double volume = 1;
  Player player = Player();
  int times = 0;
  List<String> imagePaths = [
    'assets/happy.png',
    'assets/bored.jpeg',
    'assets/confused.jpeg',
    'assets/happy.png',
  ];
  List<String> speeches = [
    "",
    "Hallo mein Name ist Kai",
    "Ich bin eine Künstliche Intelligenz",
    "Leider bin ich noch jung und tollpatschig, kannst du mir helfen ein Paar meiner Fehler zu finden?"
  ];

  void nextState() {
    setState(() {
      speechBubble = true;
      player.play(times);
      times++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demonstrator App"),
        backgroundColor: OurColors.appBarColor,
        titleTextStyle:
            const TextStyle(color: OurColors.appBarTextColor, fontSize: 25),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: OurColors.appBarTextColor,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Introduction()));
          },
        ),
      ),
      backgroundColor: OurColors.backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Center(
              child: SizedBox(
            width: 700,
            height: 500,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 20,
                  left: 350,
                  child: Container(
                    color: Colors.white,
                    height: 500,
                    width: 400,
                    child: Image.asset(
                      imagePaths[times],
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 95,
                  width: 300,
                  height: 500,
                  child: AnimatedOpacity(
                    opacity: speechBubble ? 1.0 : 0,
                    duration: const Duration(milliseconds: 500),
                    child: BubbleSpecialThree(
                      text: speeches[times],
                      color: const Color.fromARGB(255, 190, 190, 190),
                      tail: true,
                      textStyle:
                          const TextStyle(color: Colors.black, fontSize: 25),
                    ),
                  ),
                ),
                Positioned(
                    top: 450,
                    left: 200,
                    child: Slider(
                      value: volume,
                      thumbColor: OurColors.appBarColor,
                      activeColor: OurColors.accentColor,
                      inactiveColor: Color.fromARGB(174, 206, 135, 135),
                      onChanged: (value) => setState(() {
                        volume = value;
                        player.setVolume(volume);
                      }),
                    ))
              ],
            ),
          )),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: OurColors.appBarColor,
              ),
              onPressed: () {
                if (times == 3) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MainSlideKids()));
                } else {
                  nextState();
                }
              },
              child: const Text(
                "Weiter",
                style: TextStyle(color: OurColors.textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Player {
  final player = AudioPlayer();
  List<String> soundPaths = [
    "animalese0.wav",
    "animalese2.wav",
    "animalese1.wav"
  ];

  Player() {
    player.setSource(AssetSource("animalese0.wav"));
    player.setVolume(50);
  }

  void setVolume(double volume) {
    player.setVolume(volume);
  }

  void play(int state) async {
    if (state == 2) {
      await player.release();
    } else {
      await player.stop();
      await player.setSource(AssetSource(soundPaths[state]));
      await player.resume();
    }
  }
}

//Class to acces all of our Colors throughout the App
class OurColors {
  static const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);
  static const Color appBarColor = Color.fromARGB(255, 184, 44, 44);
  static const Color textColor = Color.fromARGB(255, 0, 0, 0);
  static const Color appBarTextColor = Color.fromARGB(255, 0, 0, 0);
  static const Color accentColor = Color.fromARGB(176, 215, 80, 80);

  //backup red Color i didn't want to just delete: Color.fromARGB(176, 215, 80, 80) AND Color.fromARGB(255, 221, 115, 115)
}

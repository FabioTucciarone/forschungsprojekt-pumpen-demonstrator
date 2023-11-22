import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'MainScreen_kids.dart';
import 'Layout.dart';
import 'BackendConnection.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key, required this.backend});

  final BackendConnection backend;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RobotIntro(backend: backend),
    );
  }
}

class RobotIntro extends StatefulWidget {
  final BackendConnection backend;
  const RobotIntro({super.key, required this.backend});

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Introduction(backend: widget.backend)));
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
              onPressed: () {
                if (times == 3) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MainSlide(backend: widget.backend)));
                } else {
                  nextState();
                }
              },
              child: const Text("Weiter"),
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

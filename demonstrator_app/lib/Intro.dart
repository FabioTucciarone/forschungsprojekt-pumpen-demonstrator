import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class IntroductionScience extends StatelessWidget {
  final TabController tabController;
  const IntroductionScience(this.tabController, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(color: OurColors.accentColor),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: RichText(
                    text: const TextSpan(
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        children: <TextSpan>[
                      TextSpan(
                          text:
                              "Open-loop groundwater heat pumps are a renewable approach for cooling and heating buildings.\n"),
                      TextSpan(
                          text:
                              "For planning it is important to learn about the environmental effect of these pumps in form of their heat plumes.\n"),
                      TextSpan(
                          text:
                              "Since fully resolved simulations would be too computationally expensive, Julia Pelzer (1) has developed an artificial intelligence using convolutional neural networks to help approximate those plumes.\n"),
                      TextSpan(text: "\nIt can: \n"),
                      TextSpan(
                          text:
                              "a) approximate the heat plume of one heat pump with input pressure and permeability \n"),
                      TextSpan(
                          text:
                              "b) approximate the heat plume of two heat pumps positioned relative to one another \n"),
                      TextSpan(
                          text:
                              "\nTo communicate the results to the scientific community we have built a demonstrator. \n"),
                      TextSpan(
                          text:
                              "We generate a groundtruth using ***TODO GROUNDTRUTH BESCHREIBEN*** and compare it to a) to realize an error field. \n"),
                      TextSpan(
                          text:
                              "Since generating a groundtruth for b) is not feasible we just provide its results. \n"),
                      TextSpan(
                          text:
                              "\nFeel free to play around with this app to get a feel for how far AI has come in terms of real life simulation. \n"),
                    ])),
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
                tabController.animateTo(1);
              },
              child: const Text(
                "Understood",
                style: TextStyle(color: OurColors.appBarTextColor),
              ))
        ],
      ),
    );
  }
}

class IntroKids extends StatelessWidget {
  final TabController tabController;
  const IntroKids(this.tabController, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RobotIntro(tabController),
    );
  }
}

class RobotIntro extends StatefulWidget {
  final TabController tabController;
  const RobotIntro(this.tabController, {super.key});

  @override
  State<RobotIntro> createState() => _RobotIntroState();
}

class _RobotIntroState extends State<RobotIntro> {
  bool speechBubble = false;
  double volume = 1;
  Player player = Player();
  int times = 0;
  List<String> imagePaths = [
    'assets/happy.jpeg',
    'assets/bored.jpeg',
    'assets/confused.jpeg',
    'assets/happy.jpeg',
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
    return ListView(
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
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                      border: Border.all(width: 5),
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(200)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: Image.asset(
                      imagePaths[times],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 0,
                width: 400,
                height: 700,
                child: AnimatedOpacity(
                  opacity: speechBubble ? 1.0 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: BubbleSpecialThree(
                    text: speeches[times],
                    color: OurColors.accentColor,
                    tail: true,
                    textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        decoration: TextDecoration.none),
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
                widget.tabController.animateTo(1);
              } else {
                nextState();
              }
            },
            child: const Text(
              "Weiter",
              style: TextStyle(color: OurColors.appBarTextColor),
            ),
          ),
        ),
      ],
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

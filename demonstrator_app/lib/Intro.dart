import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'MainScreen.dart';
import 'Slider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

/// Class for the introduction of the science version with an information text.
class IntroductionScience extends StatelessWidget {
  final TabController tabController;
  const IntroductionScience(this.tabController, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(30),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Center(
            child: IntroScienceText(
              tabController: tabController,
            ),
          ),
        ),
      ],
    );
  }
}

class IntroScienceText extends StatefulWidget {
  final TabController tabController;
  const IntroScienceText({super.key, required this.tabController});

  @override
  State<IntroScienceText> createState() => _IntroScienceTextState();
}

class _IntroScienceTextState extends State<IntroScienceText> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(
              textSelectionTheme: const TextSelectionThemeData(
                  selectionColor: OurColors.accentColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpansionTile(
                title: const Text(
                  "General information",
                  style: TextStyle(
                      fontSize: 18, color: OurColors.textColor, height: 2),
                ),
                subtitle: const Text(""),
                controlAffinity: ListTileControlAffinity.leading,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 650,
                        child: Wrap(
                          children: [
                            SelectableText.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: 18,
                                  color: OurColors.textColor,
                                  height: 2,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        "Open-loop groundwater heat pumps represent a ",
                                  ),
                                  TextSpan(
                                    text:
                                        "renewable method for cooling and heating ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "buildings.\n"
                                        "They extract groundwater of which the temperature is constant and pass it through a heat exchanger. "
                                        "Afterwards the now cooler water (or warmer if the system is used for cooling) is reinjected into "
                                        "the groundwater. Figure 1 illustrates this process.\n"
                                        "Understanding the environmental impact of these systems, particularly their heat contribution to "
                                        "the groundwater, is crucial for ",
                                  ),
                                  TextSpan(
                                    text: "effective city planning",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text:
                                        " since heat pumps can exceed the maximal allowed groundwater temperature or can influence the heating or cooling process "
                                        "of other pumps if they are installed too close.\n"
                                        "Since fully resolved simulations would be too computationally expensive, we have developed a convolutional neural network ",
                                  ),
                                  TextSpan(
                                    text:
                                        "(CNN) to approximate the heat plumes of heat pumps.\n",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/HeatPumpFunctionalty.png',
                              scale: 2,
                            ),
                            const Text(
                                "Figure 1: Functionalty of an open-loop groundwater heat pump"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text(
                  "Single heat pump",
                  style: TextStyle(
                      fontSize: 18, color: OurColors.textColor, height: 2),
                ),
                subtitle: const Text(""),
                controlAffinity: ListTileControlAffinity.leading,
                children: [
                  SelectableText.rich(
                    TextSpan(
                      style: const TextStyle(
                          fontSize: 18, color: OurColors.textColor, height: 2),
                      children: [
                        TooltipTextSpan(
                          path: "assets/CNN_Architektur.png",
                          textSpan: const TextSpan(
                            text: "The CNN",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                        const TextSpan(text: "approximates the "),
                        TooltipTextSpan(
                          path: "assets/SingleHeatPump_Wissenschaft.png",
                          textSpan: TextSpan(
                              text: "heat plume of a single heat pump",
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap =
                                    () => widget.tabController.animateTo(1)),
                        ),
                        const TextSpan(
                            text: " based on the input parameters of "),
                        const TextSpan(
                            text: "pressure and permeability.\n",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(
                          text:
                              "Figure 2 illustrates an exemplary heat plume of a single heat pump presented as a heatmap.\n"
                              "The CNN can be tested with varying input parameters, which can be selected using the sliders. "
                              "The output includes the AI-generated heat plume, the groundtruth and the difference field between "
                              "these two heat plumes.\nThe groundtruth is obtained by interpolating between previously simulated data points.\n",
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/examplePlume.png',
                          scale: 1.2,
                        ),
                        const Text("Figure 2: An example heat plume"),
                      ],
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text(
                  "Interaction of heat plumes",
                  style: TextStyle(
                      fontSize: 18, color: OurColors.textColor, height: 2),
                ),
                subtitle: const Text(""),
                controlAffinity: ListTileControlAffinity.leading,
                children: [
                  SelectableText.rich(
                    TextSpan(
                      style: const TextStyle(
                          fontSize: 18, color: OurColors.textColor, height: 2),
                      children: [
                        TooltipTextSpan(
                          path: "assets/CNN_Architektur.png",
                          textSpan: const TextSpan(
                            text: "The CNN",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                        const TextSpan(text: "approximates the "),
                        TooltipTextSpan(
                          path:
                              "assets/InteractionOfHeatPlumes_Wissenschaft.png",
                          textSpan: TextSpan(
                              text: "interaction of heat plumes from two pumps",
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap =
                                    () => widget.tabController.animateTo(2)),
                        ),
                        const TextSpan(
                          text:
                              " positioned relative to each other.\nFigure 3 illustrates an example of this interaction presented "
                              "as a heatmap.\nThe CNN can be tested with varying ",
                        ),
                        const TextSpan(
                            text: "pressure and permeability",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(
                            text:
                                ", which can be selected using the sliders. Additionally, the "),
                        const TextSpan(
                            text: "position ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(
                          text:
                              // position of first pump is determined
                              "of the second heat pump can be selected on the output field via point and click or drag and drop of the red "
                              "pointer while the position of the first pump is fixed.\nFor this scenario, we chose not to generate a groundtruth "
                              "so that the input parameters are freely selectable, and thus, only the AI-generated results are provided.\n",
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/examplePhase2.png',
                          scale: 1.6,
                        ),
                        const Text(
                            "Figure 3: An example of the interaction of two heat plumes"),
                      ],
                    ),
                  ),
                ],
              ),
              const SelectableText.rich(
                TextSpan(
                  style: TextStyle(
                      fontSize: 18, color: OurColors.textColor, height: 2),
                  children: [
                    TextSpan(
                        text:
                            "\nFeel free to play around with this app to get an idea of how far artificial intelligence has come in terms of real-life simulation.\n"),
                  ],
                ),
              ),
              ExpansionTile(
                title: const Text(
                  "Quellen",
                  style: TextStyle(
                      fontSize: 18, color: OurColors.textColor, height: 2),
                ),
                subtitle: const Text(""),
                controlAffinity: ListTileControlAffinity.leading,
                children: [
                  SelectableText.rich(
                    TextSpan(
                      style: const TextStyle(
                          fontSize: 18, color: OurColors.textColor, height: 2),
                      children: [
                        const TextSpan(
                          text:
                              "Pelzer, Julia und Schulte, Miriam (2024). “Two-Stage Learning of the Interaction of Heat Plumes of Geothermal Heat Pumps”. In: Elsevier (unveröffentlicht).\n",
                        ),
                        TextSpan(
                          text: "https://www.bbc.com/news/uk-wales-49579094 \n",
                          style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => launchUrlString(
                                "https://www.bbc.com/news/uk-wales-49579094"),
                        ),
                        TextSpan(
                          text:
                              "https://www.energy.gov/energysaver/geothermal-heat-pumps \n",
                          style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => launchUrlString(
                                "https://www.energy.gov/energysaver/geothermal-heat-pumps"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Class for a textspan that shows an image when hovering over the text.
/// The String variable path is the path of the image and textSpan the text which can be hovered over.
class TooltipTextSpan extends WidgetSpan {
  TooltipTextSpan({
    required String path,
    required TextSpan textSpan,
  }) : super(
          child: Tooltip(
            richMessage: WidgetSpan(
              child: Container(
                constraints:
                    const BoxConstraints(maxHeight: 500, maxWidth: 700),
                child: Image.asset(path),
              ),
            ),
            child: SelectableText.rich(textSpan),
          ),
        );
}

/// Class for the introduction of the children version with a roboter animation.
class IntroKids extends StatelessWidget {
  final TabController tabController;
  const IntroKids(this.tabController, {super.key});

  @override
  Widget build(BuildContext context) {
    return RobotIntro(tabController);
  }
}

/// Class for the roboter which is used for the introduction. The roboter can "talk" and show several emotions.
class RobotIntro extends StatefulWidget {
  final TabController tabController;
  const RobotIntro(this.tabController, {super.key});

  @override
  State<RobotIntro> createState() => _RobotIntroState();
}

class _RobotIntroState extends State<RobotIntro> {
  bool speechBubble = false;
  bool speechBubble2 = false;
  double volume = 1;
  Player player = Player();
  int times = 0;
  late String name;
  _RobotIntroState() {
    name = MainMaterial.name;
  }
  List<String> imagePaths = [
    'assets/happy.jpeg',
    'assets/starry.jpeg',
    'assets/happy.jpeg',
    'assets/confused.jpeg',
    'assets/happy.jpeg',
    'assets/happy.jpeg',
    'assets/starry.jpeg',
    'assets/happy.jpeg',
    'assets/happy.jpeg',
    'assets/starry.jpeg',
    'assets/starry.jpeg',
    'assets/happy.jpeg',
    'assets/confused.jpeg',
    'assets/happy.jpeg',
    'assets/starry.jpeg',
    'assets/happy.jpeg',
    'assets/starry.jpeg',
    'assets/happy.jpeg',
    'assets/starry.jpeg',
  ];
  List<String> speeches = [
    "",
    "Hallo mein Name ist Kai. Ich bin eine künstliche Intelligenz und dein heutiger Begleiter.",
    "Ich mag's schön warm zuhause.\nIm Winter heize ich mit Wärmepumpen. Weißt du was das ist?",
    "Eine Wärmepumpe entzieht Wärme aus dem Grundwasser und pumpt sie in dein Haus.\nDann kannst du zum Beispiel warm duschen!\nLinks kannst du sehen wie das funktioniert.",
    "Eine Wärmepumpe ändert auch die Temperatur des Wassers untem im Boden. Von irgendwo muss die Wärme ja schließlich kommen!",
    "Eine Wärmepumpe ändert auch die Temperatur des Wassers unten im Boden. Von irgendwo muss die Wärme ja schließlich kommen!",
    "Wenn der Druck des Wassers oder die Durchlässigkeit des Bodens anders ist, verändert sich dieses Feld!",
    "Wenn der Druck des Wassers oder die Durchlässigkeit des Bodens anders ist, verändert sich dieses Feld!",
    "Aber leider bin ich noch ein wenig tollpatschig und meine Berechnungen sind noch nicht perfekt! Gleich kannst du sehen was ich meine.",
    "Aber leider bin ich noch ein wenig tollpatschig und meine Berechnungen sind noch nicht perfekt! Gleich kannst du sehen was ich meine.",
    "Ich kann mit deiner Hilfe aber auch dazulernen! Du sollst mir Fahnen zeigen bei denen ich wie gerade eben nicht so gut war, dann kann ich lernen!",
    "Ich kann mit deiner Hilfe aber auch dazulernen! Du sollst mir Fahnen zeigen bei denen ich wie gerade eben nicht so gut war, dann kann ich lernen!",
    "Wenn du Werte findest, bei denen ich mich verbessern kann kriegst du eine hohe Punktzahl. Schaffst du es 1000 Punkte zu bekommen?",
    "Wenn du Werte findest, bei denen ich mich verbessern kann kriegst du eine hohe Punktzahl. Schaffst du es 1000 Punkte zu bekommen?",
  ];
  List<String> speeches2 = [
    "",
    "",
    "",
    "",
    "",
    "Unten kannst du sehen, wie sich die Temperatur verändert. Rot steht hier für Wärme. Die Wärme breitet sich in Flussrichtung aus.",
    "",
    "Und da komm ich ins Spiel! Ich kann das nämlich ausrechnen! Beziehungsweise versuche ich das.",
    "",
    "Oben ist meine Berechnung. In der Mitte siehst du die richtige Lösung. Der Unterschied (unten) ist leider groß, man kann sich also noch nicht auf mich verlassen.",
    "",
    'Du kannst gleich mit Schiebereglern die Werte "Druck" und "Durchlässigkeit" anpassen um mir Sachen zum Rechnen zu geben! Unten siehst du so einen Schieberegler.',
    "",
    "Um dich auf der Bestenliste verewigen zu können, wird dir ein Name gegeben. Du bist ...",
    "",
    "",
  ];

  List<String> nextButtonSpeech = [
    "",
    "Hallo!",
    "Zeig es mir!",
    "Cool!",
    "Klar",
    "Interessant!",
    "Logisch",
    "Ist das so einfach?",
    "Zeig es mir!",
    "Ich verstehe",
    "Ich helf dir gerne!",
    "Und jetzt?",
    "Ja, auf jeden Fall!",
    "Los geht's!"
  ];

  List<String> lastButtonSpeech = [
    "",
    "Zurück",
    "Wer bist du nochmal?",
    "Erklär das nochmal",
    "Zurück!",
    "Einen Schritt zurück",
    "Wie war das nochmal?",
    "Zurück!",
    "Einen Schritt zurück",
    "Wie war das nochmal?",
    "Zurück!",
    "Einen Schritt zurück",
    "Wie war das nochmal?",
    "Einen Schritt zurück"
  ];

  Widget secondSpeechBubble() {
    Widget bubble = Positioned(
      top: 310,
      left: 650,
      width: 600,
      height: 700,
      child: AnimatedOpacity(
        opacity: speechBubble2 ? 1.0 : 0,
        duration: const Duration(milliseconds: 500),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: BubbleSpecialThree(
            key: ValueKey<int>(
                times), // Use a ValueKey to ensure proper animation when the key changes
            text: speeches2[times],
            color: OurColors.accentColor,
            tail: true,
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 35,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
    return bubble;
  }

  void nextState() {
    setState(() {
      speechBubble = true;
      player.play(times);
      times++;
      if (times == 5 ||
          times == 7 ||
          times == 9 ||
          times == 11 ||
          times == 13) {
        speechBubble2 = true;
      } else {
        speechBubble2 = false;
      }
    });
  }

  void previousState() {
    setState(() {
      if (times != 0) {
        if (times == 1) {
          speechBubble = false;
          times--;
        } else {
          times--;
          player.play(times);
        }
        if (times == 5 ||
            times == 7 ||
            times == 9 ||
            times == 11 ||
            times == 13) {
          speechBubble2 = true;
        } else {
          speechBubble2 = false;
        }
      }
    });
  }

  Widget getButtons() {
    if (times == 0) {
      return Center(
        child: ElevatedButton(
          style: ButtonStyle(
            foregroundColor:
                MaterialStateProperty.all<Color>(OurColors.appBarTextColor),
            backgroundColor: MaterialStateProperty.all<Color>(
              OurColors.appBarColor,
            ),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(15)),
          ),
          onPressed: () {
            if (times == 8) {
              widget.tabController.animateTo(1);
            } else {
              nextState();
            }
          },
          child: const Text(
            "Los geht's!",
            style: TextStyle(color: OurColors.appBarTextColor),
            textScaleFactor: 3,
          ),
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(200, 0)),
                foregroundColor:
                    MaterialStateProperty.all<Color>(OurColors.appBarTextColor),
                backgroundColor: MaterialStateProperty.all<Color>(
                  OurColors.appBarColor,
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.all(15)),
              ),
              onPressed: () {
                previousState();
              },
              child: Text(
                lastButtonSpeech[times],
                style: const TextStyle(color: OurColors.appBarTextColor),
                textScaleFactor: 3,
              ),
            ),
          ),
          const SizedBox(
            width: 50,
          ),
          Center(
            child: ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(200, 0)),
                foregroundColor:
                    MaterialStateProperty.all<Color>(OurColors.appBarTextColor),
                backgroundColor: MaterialStateProperty.all<Color>(
                  OurColors.appBarColor,
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.all(15)),
              ),
              onPressed: () {
                if (times == 13) {
                  widget.tabController.animateTo(1);
                } else {
                  nextState();
                }
              },
              child: Text(
                nextButtonSpeech[times],
                style: const TextStyle(color: OurColors.appBarTextColor),
                textScaleFactor: 3,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget introIllustration() {
    Widget child = Container();
    if (times == 9) {
      return Positioned(
        top: 100,
        left: -60,
        child: SizedBox(
          width: 700,
          height: 600,
          child: Image.asset(
            "assets/bigDifference.png",
            fit: BoxFit.contain,
          ),
        ),
      );
    } else if (times == 5) {
      return Positioned(
        top: 400,
        left: 400,
        child: SizedBox(
            width: 1150,
            height: 550,
            child: Image.asset(
              "assets/examplePlume.png",
              fit: BoxFit.contain,
            )),
      );
    } else if (times == 3) {
      return Positioned(
        top: 100,
        left: -100,
        child: SizedBox(
          width: 800,
          height: 500,
          child: Image.asset(
            "assets/watersource.gif",
            fit: BoxFit.contain,
          ),
        ),
      );
    } else if (times == 11) {
      return Positioned(
        top: 700,
        left: 400,
        child: PressureSlider(
          900,
          const {
            "pressure_range": [0.0, 100.0],
            "permeability_range": [0.0, 100.0],
          },
          SliderType.dummy,
          true,
          true,
        ),
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    name = MainMaterial.name;
    speeches2[13] =
        "Um dich auf der Bestenliste verewigen zu können, wird dir ein Name gegeben. Du bist $name.";
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 2000,
        height: 1000,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                  child: SizedBox(
                width: 1800,
                height: 800,
                child: Stack(
                  children: <Widget>[
                    AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        top: 100,
                        left: speechBubble ? 1300 : 650,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            key: ValueKey<int>(
                                times), // Use a ValueKey to ensure proper animation when the key changes
                            height: 500,
                            width: 500,
                            decoration: BoxDecoration(
                              border: Border.all(width: 5),
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(500),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(500),
                              child: Image.asset(
                                imagePaths[times],
                                key: ValueKey<int>(
                                    times), // Use a ValueKey to ensure proper animation when the key changes
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )),
                    Positioned(
                      top: 50,
                      left: 650,
                      width: 600,
                      height: 700,
                      child: AnimatedOpacity(
                        opacity: speechBubble ? 1.0 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: BubbleSpecialThree(
                            key: ValueKey<int>(
                                times), // Use a ValueKey to ensure proper animation when the key changes
                            text: speeches[times],
                            color: OurColors.accentColor,
                            tail: true,
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 35,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    secondSpeechBubble(),
                    introIllustration()
                  ],
                ),
              )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.volume_up_rounded),
                  Slider(
                    value: volume,
                    thumbColor: OurColors.appBarColor,
                    activeColor: OurColors.darkerAccentColor,
                    inactiveColor: OurColors.accentColor,
                    onChanged: (value) => setState(() {
                      volume = value;
                      player.setVolume(volume);
                    }),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              getButtons()
            ],
          ),
        ),
      ),
    );
  }
}

class Player {
  final player = AudioPlayer();
  List<String> soundPaths = [
    "animalese1.wav",
    "animalese2.wav",
    "animalese0.wav",
    "animalese2.wav",
    "animalese0.wav",
    "animalese2.wav",
    "animalese0.wav",
    "animalese2.wav",
    "animalese1.wav",
    "animalese2.wav",
    "animalese0.wav",
    "animalese2.wav",
    "animalese0.wav",
    "animalese2.wav",
    "animalese0.wav",
    "animalese2.wav",
    "animalese0.wav",
    "animalese2.wav",
    "animalese0.wav",
    "animalese2.wav",
  ];

  Player() {
    player.setSource(AssetSource("animalese0.wav"));
    player.setVolume(50);
  }

  void setVolume(double volume) {
    player.setVolume(volume);
  }

  void play(int state) async {
    if (state == 13) {
      await player.release();
    } else {
      await player.stop();
      await player.setSource(AssetSource(soundPaths[state]));
      await player.resume();
    }
  }
}

/// Class to acces all of our Colors throughout the App.
class OurColors {
  static const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);
  static const Color appBarColor = Color.fromARGB(255, 84, 161, 224);
  static const Color textColor = Color.fromARGB(255, 0, 0, 0);
  static const Color appBarTextColor = Color.fromARGB(255, 0, 0, 0);
  static const Color accentColor = Color.fromARGB(172, 115, 192, 255);
  static const Color darkerAccentColor = Color.fromARGB(172, 91, 153, 204);
  //backup red Color i didn't want to just delete: Color.fromARGB(176, 215, 80, 80) AND Color.fromARGB(255, 221, 115, 115)
}

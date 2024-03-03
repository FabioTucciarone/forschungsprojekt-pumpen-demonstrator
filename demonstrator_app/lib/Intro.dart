import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        const TextSpan(text: "approximates the "),
                        TextSpan(
                            text: "heat plume of a single heat pump",
                            style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap =
                                  () => widget.tabController.animateTo(1)),
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
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        const TextSpan(text: "approximates the "),
                        TextSpan(
                            text: "interaction of heat plumes from two pumps",
                            style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap =
                                  () => widget.tabController.animateTo(2)),
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
  double volume = 1;
  Player player = Player();
  int times = 0;
  List<String> imagePaths = [
    'assets/happy.jpeg',
    'assets/starry.jpeg',
    'assets/happy.jpeg',
    'assets/starry.jpeg',
    'assets/confused.jpeg',
    'assets/happy.jpeg',
    'assets/starry.jpeg',
    'assets/starry.jpeg',
    'assets/happy.jpeg',
    'assets/starry.jpeg',
  ];
  List<String> speeches = [
    "",
    "Hallo mein Name ist Kai. Ich bin eine künstliche Intelligenz",
    "Mir wurde beigebracht Wärmefahnen von Grundwasser-Wärmepumpen zu berechnen. Wärmepumpen sind super, weil sie meine Wohnung im Winter heizen und sie gut für die Umwelt sind! Mega cool, oder?",
    "Eine Wärmefahne ist sozusagen das Feld, in dem sich die Wärme um die Pumpe herum ausbreitet. Schau mal, da unten kannst du sehen wie so etwas aussieht",
    "Ihr könnt euch das wie eine Fahne im Wind vorstellen, genauso folgt die Wärmefahne der Richtung des Grundwassers unterirdisch und verändert die Temperatur des Wassers, verstehst du?",
    "Leider bin ich noch jung und tollpatschig. Kannst du mir helfen mich zu verbessern?",
    "Du wirst gleich durch Schieberegler Eingaben machen können, dadurch berechne ich dann die Wärmefahnen. Je stärker mein Ergebnis von der Realität abweicht, desto höher wird deine Punktzahl sein. Schau mal, hier unten ist so ein Schieberegler, probier ihn mal aus!",
    "Hier siehst du, dass ich sehr schlecht war :( meine Wärmefahne (die obere) ist länger als sie sein soll. In der Mitte sieht man wie es eigentlich sein sollte und darunter den Unterschied. Das heißt für dich aber eine hohe Punktzahl, da ich jetzt weiß, was ich noch besser machen muss :)",
    "Dir wird automatisch ein Nutzername gegeben, damit man dich auf der Bestenliste verewigen kann. Dein Name wird oben rechts angezeigt. Wenn du willst kannst du später du auch oben auf den Tab ganz rechts gehen und schauen was dich da erwartet. Viel Erfolg!",
    ""
  ];

  void nextState() {
    setState(() {
      speechBubble = true;
      player.play(times);
      times++;
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
            "Start",
            textScaleFactor: 2,
          ),
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
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
                previousState();
              },
              child: const Text(
                "Zurück",
                textScaleFactor: 2,
              ),
            ),
          ),
          const SizedBox(
            width: 50,
          ),
          Center(
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
                "Weiter",
                textScaleFactor: 2,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget introIllustration() {
    Widget child = Container();
    if (times == 7) {
      return Positioned(
        top: 160,
        child: SizedBox(
          width: 550,
          height: 400,
          child: Image.asset(
            "assets/bigDifference.png",
            fit: BoxFit.contain,
          ),
        ),
      );
    } else if (times == 2) {
      return Positioned(
        top: 250,
        left: 0,
        child: SizedBox(
            width: 250,
            height: 250,
            child: Image.asset(
              "assets/heatpump.png",
              fit: BoxFit.contain,
            )),
      );
    } else if (times == 3) {
      return Positioned(
        top: 160,
        left: 0,
        child: SizedBox(
          width: 800,
          height: 400,
          child: Image.asset(
            "assets/examplePlume.png",
            fit: BoxFit.contain,
          ),
        ),
      );
    } else if (times == 6) {
      return Positioned(
        top: 320,
        child: PressureSlider(
          350,
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
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 1400,
        height: 700,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                  child: SizedBox(
                width: 700,
                height: 500,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 20,
                      left: 380,
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
                        left: 250,
                        child: Row(
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
                        )),
                    introIllustration()
                  ],
                ),
              )),
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
  ];

  Player() {
    player.setSource(AssetSource("animalese0.wav"));
    player.setVolume(50);
  }

  void setVolume(double volume) {
    player.setVolume(volume);
  }

  void play(int state) async {
    if (state == 8) {
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

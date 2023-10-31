import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'MainScreen_kids.dart';
import 'Layout.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RobotIntro(),
    );
  }
}

class RobotIntro extends StatefulWidget {
  const RobotIntro({
    super.key,
  });

  @override
  State<RobotIntro> createState() => _RobotIntroState();
}

class _RobotIntroState extends State<RobotIntro> {
  bool _speechBubble = false;
  bool _speechBubble2 = false;
  int times = 0;
  String textSpeechBubble = 'Hello...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demonstrator App"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Introduction()));
          },
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Center(
              child: SizedBox(
            width: 500,
            height: 300,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 20,
                  left: 150,
                  child: Container(
                    color: Colors.white,
                    height: 300,
                    width: 200,
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image:
                          'https://cdn.dribbble.com/users/1787323/screenshots/11427608/media/8fda96ec0ca9b0477fbd612f709e5c37.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 95,
                  child: AnimatedOpacity(
                    opacity: _speechBubble ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: BubbleSpecialThree(
                      text: textSpeechBubble,
                      color: const Color.fromARGB(255, 190, 190, 190),
                      tail: true,
                      textStyle: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 95,
                  child: AnimatedOpacity(
                    opacity: _speechBubble2 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: BubbleSpecialThree(
                      text: textSpeechBubble,
                      color: const Color.fromARGB(255, 190, 190, 190),
                      tail: true,
                      textStyle: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final player = AudioPlayer();
                await player.play(AssetSource("test.wav"));
                if (times == 0) {
                  setState(() {
                    _speechBubble = !_speechBubble;
                    times = times + 1;
                  });
                } else if (times == 1) {
                  setState(() {
                    _speechBubble = !_speechBubble;
                    _speechBubble2 = !_speechBubble2;
                    times = times + 1;
                    textSpeechBubble = '...';
                  });
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainSlide()));
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

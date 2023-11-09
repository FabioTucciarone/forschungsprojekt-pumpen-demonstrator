import 'package:demonstrator_app/Checkboxes.dart';
import 'package:demonstrator_app/Outputbox.dart';
import 'package:flutter/services.dart';
import 'Intro.dart';
import 'Slider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainSlide extends StatelessWidget {
  const MainSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => CheckboxModel(),
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text("Demonstrator App"),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const IntroScreen()));
                  }),
            ),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: const [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          PressureSlider(600, 870000, 910000),
                          PressureSlider(600, 870000, 910000),
                        ],
                      ),
                      SizedBox(
                        width: 100,
                      ),
                      RoboBox()
                    ],
                  ),
                  OutputBox(
                    name: "erste Outputbox",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  OutputBox(
                    name: "zweite Outputbox",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CheckboxBox(),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: null,
                    child: Text(
                      "Anwenden",
                      textScaleFactor: 2,
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class RoboBox extends StatefulWidget {
  const RoboBox({super.key});

  @override
  State<RoboBox> createState() => _RoboBoxState();
}

class _RoboBoxState extends State<RoboBox> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            "assets/mad.jpeg",
            height: 250,
            width: 250,
          ),
        ),
      ),
    );
  }
}

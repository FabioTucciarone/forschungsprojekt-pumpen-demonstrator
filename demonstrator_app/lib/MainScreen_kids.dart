import 'package:demonstrator_app/Checkboxes.dart';
import 'package:demonstrator_app/Outputbox.dart';
import 'package:flutter/services.dart';
import 'BuildConnection.dart';
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
              actions: const <Widget>[
                ButtonAnmelden(),
              ],
            ),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: const [
                  OutputBox(
                    name: "erste Outputboxx",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  OutputBox(
                    name: "zweite Outputboxx",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  PressureSlider(800, 870000, 910000),
                  SizedBox(
                    height: 10,
                  ),
                  PressureSlider(800, 870000, 910000),
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

import 'package:demonstrator_app/Checkboxes.dart';
import 'package:demonstrator_app/Layout.dart';
import 'package:demonstrator_app/Outputbox.dart';
import 'package:demonstrator_app/Sliderbox.dart';
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
                            builder: (context) => const Introduction()));
                  }),
            ),
            backgroundColor: Color.fromARGB(255, 33, 128, 231),
            body: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
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
                  SliderBox(
                    text: "erster Slider.",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SliderBox(text: "zweiter Slider"),
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
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}









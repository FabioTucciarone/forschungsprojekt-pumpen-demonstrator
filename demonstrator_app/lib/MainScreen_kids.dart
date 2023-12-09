import 'package:demonstrator_app/Layout.dart';
import 'package:demonstrator_app/Outputbox.dart';
import 'package:flutter/services.dart';
import 'Intro.dart';
import 'Slider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'MainScreen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class MainSlideKids extends StatelessWidget with MainScreenElements {
  MainSlideKids({super.key});

  final FutureNotifier futureNotifier = FutureNotifier();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<FutureNotifier>(
            create: ((context) => futureNotifier),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text("Demonstrator App"),
              backgroundColor: OurColors.appBarColor,
              titleTextStyle: const TextStyle(
                  color: OurColors.appBarTextColor, fontSize: 25),
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: OurColors.appBarTextColor,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => IntroKids()));
                  }),
            ),
            backgroundColor: OurColors.backgroundColor,
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  ...input(),
                  ...output(),
                  AnwendenButton(
                      futureNotifier: futureNotifier,
                      permeability: getPermeability(),
                      pressure: getPressure()),
                ],
              ),
            ),
          ),
        ));
  }
}

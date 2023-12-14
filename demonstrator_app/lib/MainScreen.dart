import 'package:demonstrator_app/Intro.dart';
import 'package:demonstrator_app/Layout.dart';
import 'package:demonstrator_app/MainScreen_kids.dart';
import 'package:demonstrator_app/Outputbox.dart';
import 'Slider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class MainSlide extends StatefulWidget with MainScreenElements {
  final bool children;
  MainSlide({super.key, required this.children});

  @override
  State<MainSlide> createState() => _MainSlideState();
}

class _MainSlideState extends State<MainSlide>
    with SingleTickerProviderStateMixin {
  final FutureNotifier futureNotifier = FutureNotifier();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: MultiProvider(
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
                bottom: TabBar(
                    controller: _tabController,
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                    ),
                    unselectedLabelColor: OurColors.appBarTextColor,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    labelColor: OurColors.appBarTextColor,
                    indicatorColor: OurColors.appBarTextColor,
                    tabs: const <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info),
                          Text("Infotext"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.device_thermostat),
                          Text("Eine Wärmepumpe"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.device_thermostat),
                          Icon(Icons.device_thermostat),
                          Text("Zwei Wärmepumpen"),
                        ],
                      ),
                    ]),
              ),
              backgroundColor: OurColors.backgroundColor,
              body: TabBarView(controller: _tabController, children: <Widget>[
                widget.children
                    ? IntroKids(_tabController)
                    : IntroductionScience(_tabController),
                widget.children
                    ? Phase1Kids(futureNotifier)
                    : MainScreenContent(futureNotifier),
                const SciencePhase2(),
              ]),
            ),
          )),
    );
  }
}

class MainScreenContent extends StatelessWidget with MainScreenElements {
  final FutureNotifier futureNotifier;
  MainScreenContent(this.futureNotifier, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class SciencePhase2 extends StatelessWidget {
  const SciencePhase2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 700,
      height: 300,
      decoration: const BoxDecoration(color: OurColors.accentColor),
      child: const Center(
        child: Text(
          "TODO Phase 2",
          textScaleFactor: 1.5,
        ),
      ),
    );
  }
}

mixin MainScreenElements {
  final PressureSlider pressure = PressureSlider(
      900,
      -4 * pow(10, -3).toDouble(),
      -1 * pow(10, -3).toDouble(),
      SliderType.pressure,
      -4 * pow(10, -3).toDouble());
  final PressureSlider permeability = PressureSlider(
      900,
      pow(10, -11).toDouble(),
      5 * pow(10, -9).toDouble(),
      SliderType.permeability,
      pow(10, -11).toDouble());

  PressureSlider getPressure() {
    return pressure;
  }

  PressureSlider getPermeability() {
    return permeability;
  }

  List<Widget> input() {
    return <Widget>[
      pressure,
      const SizedBox(
        height: 10,
      ),
      permeability,
    ];
  }

  List<Widget> output() {
    return <Widget>[
      const SizedBox(
        height: 10,
      ),
      const Text(
        "Ausgabe:",
        textScaleFactor: 2,
      ),
      const SizedBox(
        height: 5,
      ),
      OutputBox(
        name: ImageType.aIGenerated,
      ),
      const SizedBox(
        height: 10,
      ),
      OutputBox(
        name: ImageType.groundtruth,
      ),
      const SizedBox(
        height: 10,
      ),
      OutputBox(
        name: ImageType.differenceField,
      ),
      const SizedBox(
        height: 10,
      ),
    ];
  }
}

class AnwendenButton extends StatelessWidget {
  const AnwendenButton(
      {super.key,
      required this.futureNotifier,
      required this.permeability,
      required this.pressure});
  final FutureNotifier futureNotifier;
  final PressureSlider pressure;
  final PressureSlider permeability;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: OurColors.appBarColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size(150, 50),
          ),
          onPressed: () {
            futureNotifier.setFuture(useOfBackend.backend.sendInputData(
                permeability.getCurrent(), pressure.getCurrent(), ""));
          },
          child: const Text(
            "Anwenden",
            textScaleFactor: 1.5,
            style: TextStyle(color: OurColors.appBarTextColor),
          ),
        ),
      ],
    );
  }
}

class FutureNotifier extends ChangeNotifier {
  Future<String> future = Future.value("keinWert");

  Future<String> get getFuture => future;

  void setFuture(Future<String> newFuture) {
    future = newFuture;
    notifyListeners();
  }
}

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
  static FutureNotifier futureNotifier = FutureNotifier();

  @override
  State<MainSlide> createState() => _MainSlideState();
}

class _MainSlideState extends State<MainSlide>
    with SingleTickerProviderStateMixin {
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
              create: ((context) => MainSlide.futureNotifier),
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
                widget.children ? Phase1Kids() : MainScreenContent(),
                const SciencePhase2(),
              ]),
            ),
          )),
    );
  }
}

class MainScreenContent extends StatelessWidget with MainScreenElements {
  MainScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 1350,
          height: 600,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...input(),
                ...output(),
              ],
            ),
          ),
        ),
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
  static PressureSlider pressureSlider = PressureSlider(
      900,
      const {
        "pressure_range": [0, 1],
        "permeability_range": [0, 1]
      },
      SliderType.pressure,
      0);
  final Widget pressureWidget = FutureBuilder(
      future: useOfBackend.backend.getValueRanges(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        Widget child;
        if (snapshot.connectionState == ConnectionState.done) {
          pressureSlider =
              PressureSlider(900, snapshot.data, SliderType.pressure, 0);
          child = pressureSlider;
        } else {
          child = const SizedBox(
            width: 80,
            height: 80,
            child: Center(
              child: CircularProgressIndicator(
                color: OurColors.accentColor,
              ),
            ),
          );
        }
        return child;
      });

  static PressureSlider permeabilitySlider = PressureSlider(
      900,
      const {
        "pressure_range": [0, 1],
        "permeability_range": [0, 1]
      },
      SliderType.pressure,
      0);
  final Widget permeabilityWidget = FutureBuilder(
      future: useOfBackend.backend.getValueRanges(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        Widget child;
        if (snapshot.connectionState == ConnectionState.done) {
          permeabilitySlider =
              PressureSlider(900, snapshot.data, SliderType.permeability, 0);
          child = permeabilitySlider;
        } else {
          child = const SizedBox(
            width: 80,
            height: 80,
            child: Center(
              child: CircularProgressIndicator(
                color: OurColors.accentColor,
              ),
            ),
          );
        }
        return child;
      });

  List<Widget> input() {
    return <Widget>[
      pressureWidget,
      const SizedBox(
        height: 10,
      ),
      permeabilityWidget,
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

class FutureNotifier extends ChangeNotifier {
  Future<String> future = Future.value("keinWert");

  Future<String> get getFuture => future;

  void setFuture(Future<String> newFuture) {
    future = newFuture;
    notifyListeners();
  }
}

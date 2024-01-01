import 'package:demonstrator_app/Intro.dart';
import 'package:demonstrator_app/Layout.dart';
import 'package:demonstrator_app/MainScreen_kids.dart';
import 'package:demonstrator_app/Outputbox.dart';
import 'package:demonstrator_app/Timer.dart';
import 'Highscores.dart';
import 'Slider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class MainSlide extends StatefulWidget with MainScreenElements {
  final bool children;
  MainSlide({super.key, required this.children});
  static FutureNotifier futureNotifier = FutureNotifier();
  static RestartTimer restartTimer = RestartTimer();

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
            ChangeNotifierProvider<RestartTimer>(
              create: ((context) => MainSlide.restartTimer),
            ),
          ],
          child: MainMaterial(
            tabController: _tabController,
            widget: widget,
          )),
    );
  }
}

class MainMaterial extends StatelessWidget {
  const MainMaterial({
    super.key,
    required TabController tabController,
    required this.widget,
  }) : _tabController = tabController;

  final TabController _tabController;
  final MainSlide widget;

  void reset() {
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children) {
      RestartTimer restartTimer = context.watch<RestartTimer>();
      restartTimer.addListener(reset);
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Demonstrator App"),
          backgroundColor: OurColors.appBarColor,
          titleTextStyle:
              const TextStyle(color: OurColors.appBarTextColor, fontSize: 25),
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
              tabs: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info),
                    Text("Infotext"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.device_thermostat),
                    widget.children
                        ? const Text("Eine Wärmepumpe")
                        : const Text('One Heat Pump'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.device_thermostat),
                    const Icon(Icons.device_thermostat),
                    widget.children
                        ? const Text("Zwei Wärmepumpen")
                        : const Text('Two Heat Pumps'),
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
                ...input(900, false),
                const SizedBox(
                  height: 10,
                ),
                const OutputHeader(),
                ...output(false),
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
      0,
      false);

  static PressureSlider permeabilitySlider = PressureSlider(
      900,
      const {
        "pressure_range": [0, 1],
        "permeability_range": [0, 1]
      },
      SliderType.permeability,
      0,
      false);

  Widget getSliderWidget(double width, SliderType type, bool children) {
    return FutureBuilder(
      future: useOfBackend.backend.getValueRanges(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        Widget child;
        if (snapshot.connectionState == ConnectionState.done) {
          if (type == SliderType.pressure) {
            pressureSlider =
                PressureSlider(width, snapshot.data, type, 0, children);
            child = pressureSlider;
          } else {
            permeabilitySlider =
                PressureSlider(width, snapshot.data, type, 0, children);
            child = permeabilitySlider;
          }
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
      },
    );
  }

  List<Widget> input(double width, bool children) {
    return <Widget>[
      getSliderWidget(width, SliderType.pressure, children),
      const SizedBox(
        height: 10,
      ),
      getSliderWidget(width, SliderType.permeability, children),
    ];
  }

  List<Widget> output(bool children) {
    return <Widget>[
      const SizedBox(
        height: 5,
      ),
      OutputBox(
        name: ImageType.aIGenerated,
        children: children,
      ),
      const SizedBox(
        height: 10,
      ),
      OutputBox(
        name: ImageType.groundtruth,
        children: children,
      ),
      const SizedBox(
        height: 10,
      ),
      OutputBox(
        name: ImageType.differenceField,
        children: children,
      ),
      const SizedBox(
        height: 10,
      ),
    ];
  }
}

class OutputHeader extends StatelessWidget {
  const OutputHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Output:",
          textScaleFactor: 2,
        ),
        AverageError(false)
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

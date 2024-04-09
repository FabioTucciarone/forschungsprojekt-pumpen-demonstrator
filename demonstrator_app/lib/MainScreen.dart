import 'package:demonstrator_app/Intro.dart';
import 'package:demonstrator_app/AdminPage.dart';
import 'package:demonstrator_app/MainScreen_kids.dart';
import 'package:demonstrator_app/NamePicker.dart';
import 'package:demonstrator_app/Outputbox.dart';
import 'package:demonstrator_app/Timer.dart';
import 'Highscores.dart';
import 'Slider.dart';
import 'PumpInputBox.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Class for the site the user interacts with.
class MainSlide extends StatefulWidget with MainScreenElements {
  final bool children;
  MainSlide({super.key, required this.children});
  static FutureNotifier futureNotifier = FutureNotifier();
  static FutureNotifierPhase2 futureNotifierPhase2 = FutureNotifierPhase2();
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
            ChangeNotifierProvider<FutureNotifierPhase2>(
              create: ((context) => MainSlide.futureNotifierPhase2),
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

/// Class for the tab bar with which the user can choose between the information text, phase 1 and phase 2.
class MainMaterial extends StatefulWidget {
  const MainMaterial({
    super.key,
    required TabController tabController,
    required this.widget,
  }) : _tabController = tabController;
  final TabController _tabController;
  final MainSlide widget;
  static String name = NamePicker.getRandomName();

  static String getName() {
    return name;
  }

  @override
  State<MainMaterial> createState() => _MainMaterialState();
}

class _MainMaterialState extends State<MainMaterial> {
  void reset() {
    widget._tabController.animateTo(0);
    setState(() {
      MainMaterial.name = NamePicker.getRandomName();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.widget.children) {
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
          // Display of the username for the children version with an icon in the top right corner.
          actions: widget.widget.children
              ? [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.person,
                        color: OurColors.appBarTextColor,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        MainMaterial.name,
                        style: const TextStyle(
                            color: OurColors.appBarTextColor, fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  )
                ]
              : [],
          // Tab bar for selecting a section. Depending on whether the version is for children,
          // the title of the section is in German or English.
          bottom: TabBar(
              controller: widget._tabController,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info),
                    const SizedBox(
                      width: 8,
                    ),
                    widget.widget.children
                        ? const Text("Einführung")
                        : const Text("Infotext"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.device_thermostat),
                    const SizedBox(
                      width: 6,
                    ),
                    widget.widget.children
                        ? const Text("Eine Wärmepumpe")
                        : const Text('Single heat pump'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.device_thermostat),
                    const Icon(Icons.device_thermostat),
                    const SizedBox(
                      width: 6,
                    ),
                    widget.widget.children
                        ? const Text("Zwei Wärmepumpen")
                        : const Text('Interaction of heat plumes'),
                  ],
                ),
              ]),
        ),
        backgroundColor: OurColors.backgroundColor,
        // Depending on whether the version is for children, the correct content (introduction, phase 1 or phase 2) is shown.
        body: TabBarView(controller: widget._tabController, children: <Widget>[
          widget.widget.children
              ? IntroKids(widget._tabController)
              : IntroductionScience(widget._tabController),
          widget.widget.children ? Phase1Kids() : MainScreenContent(),
          widget.widget.children ? Phase2Kids() : SciencePhase2()
        ]),
      ),
    );
  }
}

/// Class for the phase 1 simulation in the science version.
class MainScreenContent extends StatelessWidget with MainScreenElements {
  MainScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 1450,
        height: 640,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...input(900, false, true),
              const SizedBox(
                height: 10,
              ),
              // Decorative border around the average error and the output images in order to indicate the output.
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: OurColors.darkerAccentColor,
                    width: 10,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AverageError(false),
                      ...output(false),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Class for the phase 2 simulation with 2 heat pumps in the science version.
class SciencePhase2 extends StatelessWidget with MainScreenElements {
  SciencePhase2({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 1350,
        height: 600,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...input(900, false, false),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Position of the second heat pump:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: OurColors.textColor),
                textScaleFactor: 1.2,
              ),
              outputSecondPhase(false),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mixin for the elements of the main screen consisting of 2 sliders for pressure and permeability and
/// the output boxes for the ai generated output, groundtruth and difference field or the pump input box
/// if it is phase 2. This mixin is used in order to use the same elements in both versions and so
/// avoid redundant code.
mixin MainScreenElements {
  static PressureSlider pressureSlider = PressureSlider(
      900,
      const {
        "pressure_range": [0.0, 1.0],
        "permeability_range": [0.0, 1.0]
      },
      SliderType.pressure,
      false,
      true);

  static PressureSlider permeabilitySlider = PressureSlider(
      900,
      const {
        "pressure_range": [0.0, 1.0],
        "permeability_range": [0.0, 1.0]
      },
      SliderType.permeability,
      false,
      true);

  /// Returns slider with given [type] (pressure or permeability), [width], whether it is for [children] and
  /// whether is used for the [firstPhase]. A future builder is used to await the response of the server
  /// which is the value range of the slider.
  Widget getSliderWidget(
      double width, SliderType type, bool children, bool firstPhase) {
    return FutureBuilder(
      future: useOfBackend.backend.getValueRanges(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        Widget child;
        // Response of the server, so the value range, is available. Thus the slider of given type is displayed.
        if (snapshot.connectionState == ConnectionState.done) {
          if (type == SliderType.pressure) {
            pressureSlider = PressureSlider(
                width, snapshot.data, type, children, firstPhase);
            child = pressureSlider;
          } else {
            permeabilitySlider = PressureSlider(
                width, snapshot.data, type, children, firstPhase);
            child = permeabilitySlider;
          }
          // Response isn't available yet, so a loading circle is shown.
        } else {
          child = const SizedBox(
            width: 50,
            height: 50,
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

  /// Returns input area consisting of the sliders for pressure and permeability.
  List<Widget> input(double width, bool children, bool firstPhase) {
    return <Widget>[
      getSliderWidget(width, SliderType.pressure, children, firstPhase),
      const SizedBox(
        height: 10,
      ),
      getSliderWidget(width, SliderType.permeability, children, firstPhase),
    ];
  }

  /// Returns output area consisting of the AI generated output, groundtruth and difference field.
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

  static PumpInputBox heatPumpBox = PumpInputBox(
      width: 1000, height: 200, valueRange: const [0, 1], children: false);

  /// Returns the input box for selecting the position of the second heat pump which is also the output of the AI:
  /// [children] indicates whether this widget is used for the children version. A future builder is used to
  /// await the response of the server which is the value range/shape of the box.
  Widget outputSecondPhase(bool children) {
    return FutureBuilder(
      future: useOfBackend.backend.getOutputShape(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        Widget child;
        // Response of the server, so the value range, is available. Thus the pump input box is displayed.
        if (snapshot.connectionState == ConnectionState.done) {
          heatPumpBox = PumpInputBox(
              width: 1105,
              height: 88,
              valueRange: snapshot.data,
              children: children);
          child = heatPumpBox;
          // Response isn't available yet, so a loading circle is shown.
        } else {
          child = const SizedBox(
            width: 50,
            height: 50,
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
}

/// Class for the header of the output with the average error.
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

/// Main way of notifying other widgets of the new future.
class FutureNotifier extends ChangeNotifier {
  Future<String> future = Future.value("keinWert");

  Future<String> get getFuture => future;

  void setFuture(Future<String> newFuture) {
    future = newFuture;
    notifyListeners();
  }
}

class FutureNotifierPhase2 extends ChangeNotifier {
  static bool slider =
      true; // Children only, sets whether the slider has been used first instead of the position.
  static bool clickedOnce =
      false; // Children only, sets whether the position has been used once.
  Future<String> future = Future.value("keinWert");

  Future<String> get getFuture => future;

  void setFuture(Future<String> newFuture) {
    future = newFuture;
    notifyListeners();
  }
}

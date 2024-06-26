import 'package:demonstrator_app/Intro.dart';
import 'package:demonstrator_app/MainScreen.dart';

import 'AdminPage.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Specifies what kind of parameter the slider represents.
enum SliderType { pressure, permeability, dummy }

/// Class for a slider which can be adjusted by its [sliderWidth], range of possible values ([valueRange]), [name] of parameter,
/// [currentValue] of the thumb, a boolean indicating whether the slider is for the [children] version and a boolean indicating
/// whether the slider is used for the [firstPhase].
class PressureSlider extends StatefulWidget {
  final double sliderWidth;
  final Map<String, dynamic>? valueRange;
  final SliderType name;
  double currentValue = 0;
  final bool children;
  final bool firstPhase;
  PressureSlider(
    this.sliderWidth,
    this.valueRange,
    this.name,
    this.children,
    this.firstPhase,
  );

  double getCurrent() {
    return currentValue;
  }

  @override
  State<PressureSlider> createState() => _PressureSliderState();
}

class _PressureSliderState extends State<PressureSlider> {
  // Colors of which the color gradient is used for the slider track.
  final List<Color> colorsGradient = [
    const Color.fromARGB(255, 4, 48, 97),
    const Color.fromARGB(255, 255, 255, 255),
    const Color.fromARGB(255, 204, 51, 51),
  ];
  double sliderPos =
      0; // Selected position that can be corrected if it is outside the track. Initiated with position 0.
  Color shadowColor = Colors.grey; // Color of the shadow of the slider track.
  double spreadRadius = 0.8; // Spread radius of the shadow of the slider track.
  double spreadRadiusChildren =
      4; // Spread radius of the shadow of the slider track in the children version.

  @override
  void initState() {
    super.initState();
    widget.currentValue = determineValue(sliderPos);
  }

  /// Determines the start value of the value range.
  double getStart() {
    double start = 0;
    if (widget.name == SliderType.pressure) {
      start = widget.valueRange?["pressure_range"][1];
    } else {
      start = widget.valueRange?["permeability_range"][0];
    }
    return start;
  }

  /// Determines the end value of the value range.
  double getEnd() {
    double end = 0;
    if (widget.name == SliderType.pressure) {
      end = widget.valueRange?["pressure_range"][0];
    } else {
      end = widget.valueRange?["permeability_range"][1];
    }
    return end;
  }

  /// Determines the value that the position of the thumb represents.
  double determineValue(double sliderPos) {
    double diff = getEnd() - getStart();
    double interval = widget.sliderWidth / diff;
    double i = sliderPos / interval;
    double value = getStart() + i;
    return value;
  }

  /// This method makes sure that the slider thumb doesn't leave the track.
  void correctingPosition(double position) {
    if (position > widget.sliderWidth) {
      position = widget.sliderWidth;
    }
    if (position < 0) {
      position = 0;
    }
    setState(() {
      sliderPos = position;
      if (widget.name != SliderType.dummy) {
        widget.currentValue = determineValue(sliderPos);
      }
    });
  }

  /// Gets the value and parameter name to display. If the slider is used for the children version then
  /// the parameter name is given in German otherwise in English. The number of the value's decimal places
  /// is limited to three.
  /// [displayIdentifier] indicates whether the identifier should be returned or the value.
  Widget getDisplayOfValues(SliderType name, double currentValue, bool children,
      bool displayIdentifier) {
    String identifier = '';
    String unit = '';
    if (name == SliderType.pressure) {
      if (children) {
        identifier = 'Druck';
      } else {
        identifier = 'Pressure gradient';
      }
      unit = '';
    } else {
      if (children) {
        identifier = 'Durchlässigkeit';
      } else {
        identifier = 'Logarithm of permeability';
      }
      unit = 'm\u00B2';
    }
    int exp = 0;
    double value = currentValue.abs();
    while (value < 1) {
      value = value * 10;
      exp++;
    }
    // The pressure value is given as positive to make the value more comprehensible.
    if (name == SliderType.pressure) {
      currentValue = ((currentValue * pow(10, 2 + exp)).round().toDouble() /
              pow(10, 2 + exp))
          .abs();
      // The permeability value is given as its logarithm to make the value more comprehensible.
    } else {
      currentValue = ((log(currentValue) / ln10) * 100).round() / 100;
    }
    if (displayIdentifier) {
      return Text(
        identifier,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: OurColors.textColor),
        textScaleFactor: 1.2,
      );
    } else {
      return Text(
        '$currentValue $unit',
        textScaleFactor: 1.2,
      );
    }
  }

  /// Returns the display of the value (container to the left of the slider), which is just given
  /// as "niedrig" in the children version and not present in the dummy version.
  Widget getValueContainer(SliderType name, bool children) {
    if (name != SliderType.dummy) {
      if (children) {
        return Container(
          width: 70,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(200, 200, 200, 0.5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Text(
            'niedrig',
            textScaleFactor: 1.2,
          ),
        );
      } else {
        return Container(
          width: 100,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(200, 200, 200, 0.5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: getDisplayOfValues(
              name, widget.currentValue, widget.children, false),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  /// Builds a row consisting of the displayed value and the slider. The sending of the selected data is triggered
  /// when the thumb is released or clicked. The position is corrected
  /// whenever the thumb is moved or the track is clicked.
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: (widget.name != SliderType.dummy)
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.center,
      children: <Widget>[
        // If the type of the slider is dummy (used as an example slider in the children introduction), no identifier/label is displayed.
        (widget.name != SliderType.dummy)
            ? Container(
                constraints: const BoxConstraints(minWidth: 150),
                child: getDisplayOfValues(
                    widget.name, widget.currentValue, widget.children, true),
              )
            : const SizedBox.shrink(),
        Row(
          children: <Widget>[
            getValueContainer(widget.name, widget.children),
            const SizedBox(
              width: 10,
            ),
            // Use a gesture detector to correct and process the gestures made by the user.
            // In the children version the slider additionally reacts to gestures by glowing blue,
            // by turning the shadow color blue and increasing the size/radius of the shadow.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              // When the thumb is moved or clicked to a position, it is corrected to avoid leaving the track.
              onHorizontalDragStart: (DragStartDetails details) {
                correctingPosition(details.localPosition.dx);
                if (widget.children) {
                  setState(() {
                    shadowColor = OurColors.appBarColor;
                    spreadRadius = spreadRadiusChildren;
                  });
                }
              },
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                correctingPosition(details.localPosition.dx);
                if (widget.children) {
                  setState(() {
                    shadowColor = OurColors.appBarColor;
                    spreadRadius = spreadRadiusChildren;
                  });
                }
              },
              onTapDown: (TapDownDetails details) {
                correctingPosition(details.localPosition.dx);
                if (widget.children) {
                  setState(() {
                    shadowColor = OurColors.appBarColor;
                    spreadRadius = spreadRadiusChildren;
                  });
                }
              },
              // When the thumb stops moving and is released, the inputs are send to the backend and
              // the outputs are displayed.
              onHorizontalDragEnd: (DragEndDetails details) {
                if (widget.name == SliderType.pressure) {
                  if (widget.firstPhase) {
                    MainSlide.futureNotifier.setFuture(useOfBackend.backend
                        .sendInputData(
                            MainScreenElements.permeabilitySlider.getCurrent(),
                            widget.currentValue,
                            MainMaterial.getName()));
                  } else {
                    FutureNotifierPhase2.slider = true;
                    MainSlide.futureNotifierPhase2.setFuture(
                        useOfBackend.backend.sendInputDataPhase2(
                            MainScreenElements.permeabilitySlider.getCurrent(),
                            widget.currentValue,
                            MainMaterial.getName(), [
                      MainScreenElements.heatPumpBox.getCurrent().dx,
                      MainScreenElements.heatPumpBox.getCurrent().dy
                    ]));
                  }
                  MainSlide.restartTimer.restartTimer();
                } else if (widget.name == SliderType.permeability) {
                  if (widget.firstPhase) {
                    MainSlide.futureNotifier.setFuture(useOfBackend.backend
                        .sendInputData(
                            widget.currentValue,
                            MainScreenElements.pressureSlider.getCurrent(),
                            MainMaterial.getName()));
                  } else {
                    FutureNotifierPhase2.slider = true;
                    MainSlide.futureNotifierPhase2.setFuture(
                        useOfBackend.backend.sendInputDataPhase2(
                            widget.currentValue,
                            MainScreenElements.pressureSlider.getCurrent(),
                            MainMaterial.getName(), [
                      MainScreenElements.heatPumpBox.getCurrent().dx,
                      MainScreenElements.heatPumpBox.getCurrent().dy
                    ]));
                  }
                  MainSlide.restartTimer.restartTimer();
                }
                if (widget.children) {
                  setState(() {
                    shadowColor = Colors.grey;
                    spreadRadius = 0.8;
                  });
                }
              },
              // When a spot on the track is clicked, the inputs are send to the backend and
              // the outputs are displayed.
              onTapUp: (TapUpDetails details) {
                if (widget.name == SliderType.pressure) {
                  if (widget.firstPhase) {
                    MainSlide.futureNotifier.setFuture(useOfBackend.backend
                        .sendInputData(
                            MainScreenElements.permeabilitySlider.getCurrent(),
                            widget.currentValue,
                            MainMaterial.getName()));
                  } else {
                    FutureNotifierPhase2.slider = true;
                    MainSlide.futureNotifierPhase2.setFuture(
                        useOfBackend.backend.sendInputDataPhase2(
                            MainScreenElements.permeabilitySlider.getCurrent(),
                            widget.currentValue,
                            MainMaterial.getName(), [
                      MainScreenElements.heatPumpBox.getCurrent().dx,
                      MainScreenElements.heatPumpBox.getCurrent().dy
                    ]));
                  }
                  MainSlide.restartTimer.restartTimer();
                } else if (widget.name == SliderType.permeability) {
                  if (widget.firstPhase) {
                    MainSlide.futureNotifier.setFuture(useOfBackend.backend
                        .sendInputData(
                            widget.currentValue,
                            MainScreenElements.pressureSlider.getCurrent(),
                            MainMaterial.getName()));
                  } else {
                    FutureNotifierPhase2.slider = true;
                    MainSlide.futureNotifierPhase2.setFuture(
                        useOfBackend.backend.sendInputDataPhase2(
                            widget.currentValue,
                            MainScreenElements.pressureSlider.getCurrent(),
                            MainMaterial.getName(), [
                      MainScreenElements.heatPumpBox.getCurrent().dx,
                      MainScreenElements.heatPumpBox.getCurrent().dy
                    ]));
                  }
                  MainSlide.restartTimer.restartTimer();
                }
                if (widget.children) {
                  setState(() {
                    shadowColor = Colors.grey;
                    spreadRadius = 0.8;
                  });
                }
              },
              // Slider track with color gradient and (changeable) shadow.
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  width: widget.sliderWidth,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(colors: colorsGradient),
                    boxShadow: [
                      BoxShadow(
                          color: shadowColor,
                          spreadRadius: spreadRadius,
                          blurRadius: 8),
                    ],
                  ),
                  child: CustomPaint(
                    painter: SliderThumb(sliderPos),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            // If the slider is used in the children version, a value display, namely "hoch" is added to
            // the right side of the slider.
            (widget.children && (widget.name != SliderType.dummy))
                ? Container(
                    width: 70,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(200, 200, 200, 0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'hoch',
                      textScaleFactor: 1.2,
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}

/// Class for the appearance and position of the slider thumb.
class SliderThumb extends CustomPainter {
  final double pos;
  SliderThumb(this.pos);

  /// Paints the thumb in the shape of a rectangle with rounded corners. [pos] is used to put the thumb
  /// at the position the user chooses.
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
        RRect.fromLTRBR(
            pos - 4, -5, pos + 4, size.height + 5, const Radius.circular(2)),
        Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(SliderThumb oldThumb) {
    return true;
  }
}

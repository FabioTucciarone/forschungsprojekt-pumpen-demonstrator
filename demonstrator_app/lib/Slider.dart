import 'package:demonstrator_app/MainScreen.dart';

import 'Layout.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// specifies what kind of parameter the slider represents
enum SliderType { pressure, permeability }

/// class for a slider which can be adjusted by its width, range of possible values, type of parameter,
/// current value of the thumb and a boolean indicating whether the slider is for the children version
class PressureSlider extends StatefulWidget {
  final double sliderWidth;
  final Map<String, dynamic>? valueRange;
  final SliderType name;
  double currentValue;
  bool children;
  PressureSlider(
    this.sliderWidth,
    this.valueRange,
    this.name,
    this.currentValue,
    this.children,
  );

  double getCurrent() {
    return currentValue;
  }

  @override
  State<PressureSlider> createState() => _PressureSliderState();
}

class _PressureSliderState extends State<PressureSlider>
    with MainScreenElements {
  final List<Color> colorsGradient = [
    const Color.fromARGB(255, 182, 2, 2),
    const Color.fromARGB(255, 255, 0, 0),
    const Color.fromARGB(255, 244, 153, 153),
    const Color.fromARGB(255, 255, 255, 255),
    const Color.fromARGB(255, 64, 141, 235),
    const Color.fromARGB(255, 0, 115, 255),
    const Color.fromARGB(255, 2, 69, 152),
  ];
  double sliderPos = 0;

  @override
  void initState() {
    super.initState();
    widget.currentValue = determineValue(sliderPos);
  }

  /// determines the start value of the value range
  double getStart() {
    double start = 0;
    if (widget.name == SliderType.pressure) {
      start = widget.valueRange?["pressure_range"][0];
    } else {
      start = widget.valueRange?["permeability_range"][0];
    }
    return start;
  }

  /// determines the end value of the value range
  double getEnd() {
    double end = 0;
    if (widget.name == SliderType.pressure) {
      end = widget.valueRange?["pressure_range"][1];
    } else {
      end = widget.valueRange?["permeability_range"][1];
    }
    return end;
  }

  /// determines the value that the position of the thumb represents
  double determineValue(double sliderPos) {
    double diff = getEnd() - getStart();
    double interval = widget.sliderWidth / diff;
    double i = sliderPos / interval;
    double value = getStart() + i;
    return value;
  }

  void correctingPosition(double position) {
    if (position > widget.sliderWidth) {
      position = widget.sliderWidth;
    }
    if (position < 0) {
      position = 0;
    }
    setState(() {
      sliderPos = position;
      widget.currentValue = determineValue(sliderPos);
    });
  }

  Widget getDisplayOfValues(
      SliderType name, double currentValue, bool children) {
    String identifier = '';
    if (name == SliderType.pressure) {
      if (children) {
        identifier = 'Druck';
      } else {
        identifier = 'Pressure';
      }
    } else {
      if (children) {
        identifier = 'Durchlässigkeit';
      } else {
        identifier = 'Permeability';
      }
    }
    int exp = 0;
    double value = currentValue.abs();
    while (value < 1) {
      value = value * 10;
      exp++;
    }
    currentValue =
        (currentValue * pow(10, 3 + exp)).round().toDouble() / pow(10, 3 + exp);
    return Text(
      '$identifier: ${currentValue.abs()}',
      textScaleFactor: 1.2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        getDisplayOfValues(widget.name, widget.currentValue, widget.children),
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (DragStartDetails details) {
              correctingPosition(details.localPosition.dx);
            },
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              correctingPosition(details.localPosition.dx);
            },
            onTapDown: (TapDownDetails details) {
              correctingPosition(details.localPosition.dx);
            },
            onHorizontalDragEnd: (DragEndDetails details) {
              if (widget.name == SliderType.pressure) {
                MainSlide.futureNotifier.setFuture(useOfBackend.backend
                    .sendInputData(
                        MainScreenElements.permeabilitySlider.getCurrent(),
                        widget.currentValue,
                        "test"));
                MainSlide.restartTimer.restartTimer();
              } else {
                MainSlide.futureNotifier.setFuture(useOfBackend.backend
                    .sendInputData(
                        widget.currentValue,
                        MainScreenElements.pressureSlider.getCurrent(),
                        "test"));
                MainSlide.restartTimer.restartTimer();
              }
            },
            onTapUp: (TapUpDetails details) {
              if (widget.name == SliderType.pressure) {
                MainSlide.futureNotifier.setFuture(useOfBackend.backend
                    .sendInputData(
                        MainScreenElements.permeabilitySlider.getCurrent(),
                        widget.currentValue,
                        "test"));
                MainSlide.restartTimer.restartTimer();
              } else {
                MainSlide.futureNotifier.setFuture(useOfBackend.backend
                    .sendInputData(
                        widget.currentValue,
                        MainScreenElements.pressureSlider.getCurrent(),
                        "test"));
                MainSlide.restartTimer.restartTimer();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: widget.sliderWidth,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.black),
                  gradient: LinearGradient(colors: colorsGradient),
                ),
                child: CustomPaint(
                  painter: SliderThumb(sliderPos),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SliderThumb extends CustomPainter {
  final double pos;
  SliderThumb(this.pos);

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

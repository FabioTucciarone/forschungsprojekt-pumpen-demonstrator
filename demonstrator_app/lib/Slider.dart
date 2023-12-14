import 'Layout.dart';
import 'Intro.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum SliderType { pressure, permeability }

class PressureSlider extends StatefulWidget {
  final double sliderWidth;
  final double start;
  final double end;
  final SliderType name;
  double currentValue;
  PressureSlider(
    this.sliderWidth,
    this.start,
    this.end,
    this.name,
    this.currentValue,
  );

  double getCurrent() {
    return currentValue;
  }

  @override
  State<PressureSlider> createState() => _PressureSliderState();
}

class _PressureSliderState extends State<PressureSlider> {
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

  double determineValue(double sliderPos) {
    double diff = widget.end - widget.start;
    double interval = widget.sliderWidth / diff;
    double i = sliderPos / interval;
    double value = widget.start + i;
    int exp = (log(value.abs()) / ln10).abs().round();
    value = (value * pow(10, 7 + exp)).round().toDouble() / pow(10, 7 + exp);
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

  Widget getDisplayOfValues(SliderType name, double currentValue) {
    if (name == SliderType.pressure) {
      return Text(
        'Druck: $currentValue',
        textScaleFactor: 1.2,
      );
    } else {
      return Text(
        'Durchlässigkeit: $currentValue',
        textScaleFactor: 1.2,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        /*FutureBuilder(
            future: useOfBackend.backend.getValueRanges(),
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, dynamic>> snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                if (name == SliderType.pressure) {
                  child = Text(
                    '$name: $currentValue',
                    textScaleFactor: 1.2,
                  );
                } else {
                  child = Text(
                    '$name: $currentValue',
                    textScaleFactor: 1.2,
                  );
                }
              } else {
                child = const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    color: OurColors.accentColor,
                  ),
                );
              }
              return child;
            }),*/
        getDisplayOfValues(widget.name, widget.currentValue),
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
            child: Padding(
              padding: const EdgeInsets.all(15),
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
    canvas.drawLine(
        Offset(pos, -5),
        Offset(pos, size.height),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 3.0);
  }

  @override
  bool shouldRepaint(SliderThumb oldThumb) {
    return true;
  }
}

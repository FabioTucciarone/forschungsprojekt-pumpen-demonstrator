import 'package:flutter/material.dart';
import 'dart:math';

class PressureSlider extends StatefulWidget {
  final double sliderWidth;
  final double start;
  final double end;
  final String name;
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

  @override
  Widget build(BuildContext context) {
    String name = widget.name;
    double currentValue = widget.currentValue;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          '$name: $currentValue',
          textScaleFactor: 1.2,
        ),
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


import 'package:flutter/material.dart';



class PressureSlider extends StatefulWidget {
  final double sliderWidth;
  final double start;
  final double end;
  const PressureSlider(this.sliderWidth, this.start, this.end);

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
  double currentValue = 870000;
  double sliderPos = 0;

  @override
  void initState() {
    super.initState();
    currentValue = determineValue(sliderPos);
  }

  double determineValue(double sliderPos) {
    double diff = widget.end - widget.start;
    double interval = widget.sliderWidth / diff;
    int i = (sliderPos / interval).round();
    double value = widget.start + i;
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
      currentValue = determineValue(sliderPos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'Druck: $currentValue',
          style: TextStyle(fontWeight: FontWeight.bold),
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
    /*return SliderTheme(
        data: SliderTheme.of(context).copyWith(
          inactiveTrackColor: Colors.white,
          activeTrackColor: Colors.red,
          thumbColor: Colors.black,
          overlayColor: Colors.grey,
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 15,
            pressedElevation: 8,
          ),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 30),
          trackShape: const RectangularSliderTrackShape(),
          trackHeight: 10,
        ),
        child: Slider(
          value: currentValue,
          min: 870000,
          max: 910000,
          divisions: 1000,
          label: '${currentValue.round()}',
          onChanged: (double value) {
            setState(() {
              currentValue = value;
            });
          },
        ));*/
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
          ..strokeWidth = 2.0);
  }

  @override
  bool shouldRepaint(SliderThumb oldThumb) {
    return true;
  }
}
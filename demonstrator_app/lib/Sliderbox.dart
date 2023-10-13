import 'package:flutter/material.dart';

class SliderBox extends StatefulWidget {
  const SliderBox({super.key, required this.text});
  final String text;

  @override
  State<SliderBox> createState() => _SliderBoxState();
}

class _SliderBoxState extends State<SliderBox> {
  double _sliderValue = 0.0;

  Color getColorFromValue(double value) {
    // Calculate color based on the slider value
    final redValue = (value * 255).toInt();
    final blueValue = (255 - redValue).toInt();
    return Color.fromRGBO(redValue, 0, blueValue, 1.0);
  }

  LinearGradient getGradientFromValue(double value) {
    final colorStops = [
      ColorStop(0.0, Colors.red),
      ColorStop(1.0, Colors.blue),
    ];

    // Create a gradient with color stops based on the slider value
    final gradient = LinearGradient(
      colors: colorStops.map((colorStop) => colorStop.color).toList(),
      stops: colorStops
          .map((colorStop) => (value * colorStop.stop).clamp(0.0, 1.0))
          .toList(),
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return gradient;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text("${widget.text}"),
      Container(
        width: 200.0,
        height: 10.0,
        decoration: BoxDecoration(
          color: getColorFromValue(_sliderValue),
        ),
      ),
      ShaderMask(
        shaderCallback: (rect) {
          return getGradientFromValue(_sliderValue).createShader(rect);
        },
        child: Slider(
          activeColor: getColorFromValue(_sliderValue),
          value: _sliderValue,
          onChanged: (value) {
            setState(() {
              _sliderValue = value;
            });
          },
        ),
      )
    ]);
  }
}

class ColorStop {
  final double stop;
  final Color color;

  ColorStop(this.stop, this.color);
}
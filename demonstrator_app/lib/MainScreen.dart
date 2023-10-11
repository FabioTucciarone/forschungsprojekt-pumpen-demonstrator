import 'package:demonstrator_app/Layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainSlide extends StatelessWidget {
  const MainSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => CheckboxModel(),
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text("Demonstrator App"),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Introduction()));
                  }),
            ),
            backgroundColor: Color.fromARGB(255, 33, 128, 231),
            body: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  OutputBox(
                    name: "erste Outputboxx",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  OutputBox(
                    name: "zweite Outputboxx",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SliderBox(
                    text: "erster Slider.",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SliderBox(text: "zweiter Slider"),
                  SizedBox(
                    height: 10,
                  ),
                  CheckboxBox(),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: null,
                      child: Text(
                        "Anwenden",
                        textScaleFactor: 2,
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}

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

class OutputBox extends StatelessWidget {
  const OutputBox({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final checkBoxModel = Provider.of<CheckboxModel>(context);
    final isChecked1 = checkBoxModel.isChecked1;
    final isChecked2 = checkBoxModel.isChecked2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$name",
          textScaleFactor: 2,
        ),
        Text("Checkbox1 is ${isChecked1 ? 'checked' : 'not checked'}"),
        Text("Checkbox2 is ${isChecked2 ? 'checked' : 'not checked'}"),
        SizedBox(
          height: 100,
          child: Container(
            color: Colors.blue,
          ),
        )
      ],
    );
  }
}

class CheckboxModel extends ChangeNotifier {
  bool _isChecked1 = false;
  bool _isChecked2 = false;

  bool get isChecked1 => _isChecked1;
  bool get isChecked2 => _isChecked2;

  void setChecked1(bool value) {
    _isChecked1 = value;
    _isChecked2 = !value;
    notifyListeners();
  }

  void setChecked2(bool value) {
    _isChecked2 = value;
    _isChecked1 = !value;
    notifyListeners();
  }
}

class CheckboxBox extends StatefulWidget {
  const CheckboxBox({super.key});

  @override
  State<CheckboxBox> createState() => _CheckboxBoxState();
}

class _CheckboxBoxState extends State<CheckboxBox> {
  @override
  Widget build(BuildContext context) {
    final checkBoxModel = Provider.of<CheckboxModel>(context);

    return ColoredBox(
      color: Colors.green,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text(
            "Modell",
            textScaleFactor: 2,
          ),
          Column(
            children: [
              const Text(
                "Neuronales Netzwerk 1",
                textScaleFactor: 1.5,
              ),
              Checkbox(
                value: checkBoxModel._isChecked1,
                onChanged: (newBool) {
                  setState(() {
                    checkBoxModel.setChecked1(newBool!);
                    checkBoxModel.setChecked2(false);
                  });
                },
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                "Neuronales Netzwerk 2",
                textScaleFactor: 1.5,
              ),
              Checkbox(
                value: checkBoxModel.isChecked2,
                onChanged: (newBool) {
                  setState(() {
                    checkBoxModel.setChecked2(newBool!);
                    checkBoxModel.setChecked1(false);
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ColorStop {
  final double stop;
  final Color color;

  ColorStop(this.stop, this.color);
}

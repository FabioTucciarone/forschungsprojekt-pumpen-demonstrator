import 'package:demonstrator_app/Layout.dart';
import 'package:flutter/material.dart';

class MainSlide extends StatelessWidget {
  const MainSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Demonstrator App"),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const Introduction()
                ));
            }),
        ),
        backgroundColor: Color.fromARGB(255, 33, 128, 231),
        body: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              OutputBox(name: "erste Outputboxx",),
              SizedBox(height: 50,),
              OutputBox(name: "zweite Outputboxx",),
              SizedBox(height: 50,),
              SliderBox(text: "erster Slider.",),
              SizedBox(height: 50,),
              SliderBox(text: "zweiter Slider"),
              SizedBox(height: 50,),
              CheckboxBox(),
              SizedBox(height: 50,),
              ElevatedButton(onPressed: anwenden(), child: Text("Anwenden",textScaleFactor: 2,))
              
              
        
        
            ],
          ),
        ),
        )
        ,);
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
    return  Column(
      children: [Text("${widget.text}"),
      Container( width: 200.0,
              height: 10.0,
              decoration: BoxDecoration(
                color: getColorFromValue(_sliderValue),
              ),),
      
      ShaderMask(shaderCallback: (rect) {
                return getGradientFromValue(_sliderValue).createShader(rect);
              },
              child: Slider(
        activeColor: getColorFromValue(_sliderValue),
        value: _sliderValue,
        onChanged: (value){ setState(() {
          _sliderValue=value;
        });},
        ),)
      ]
      
    );
  }
}

class OutputBox extends StatelessWidget {
  const OutputBox({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        Text("$name", textScaleFactor: 2,),
        SizedBox(height: 100, child: Container(color: Colors.blue,),)
        ],
      );
    
  }
}

class CheckboxBox extends StatefulWidget {
  const CheckboxBox({super.key});

  @override
  State<CheckboxBox> createState() => _CheckboxBoxState();
}

class _CheckboxBoxState extends State<CheckboxBox> {
  bool? isChecked1 = false;
  bool? isChecked2 = false;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.green, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("Modell", textScaleFactor: 2,),
          Column(
            children: [
              Text("Neuronales Netzwerk 1", textScaleFactor: 1.5,),
              Checkbox(value: isChecked1, onChanged: (newBool){ setState(() {
                isChecked1=newBool;
                isChecked2=false;
              });},),
            ],
          ),
          Column(
            children: [
              Text("Neuronales Netzwerk 2", textScaleFactor: 1.5,),
              Checkbox(value: isChecked2, onChanged: (newBool){ setState(() {
                isChecked2=newBool;
                isChecked1=false;
              });},),
            ],
          )
          ],),);
  }
}

class ColorStop {
  final double stop;
  final Color color;

  ColorStop(this.stop, this.color);
}

void anwenden(){}
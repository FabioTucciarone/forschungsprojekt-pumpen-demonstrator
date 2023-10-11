import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'Data.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  /*
   * "Notifier"-Widgets sind für alle in der Baumhierarchie absteigenden Widgets sichtbar.
   * Da die Eingabe auch die Ausgabe beeinflusst: Verschachtelung
   */
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Demonstrator'),
        ),
        drawer: const DrawerDemonstrator(),
        body: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ChangeNotifierProvider(
              create: (context) => InputData(),
              child: ChangeNotifierProvider(
                create: (context) => OutputData(),
                child: const DataDisplay(),
              ),
            ),
            const Text(
              'Eingabeparameter:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('Durchlässigkeit'),
                PressureSlider(800, 870000, 910000),
                Text('Position der Wärmepumpe'),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'Modell: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ButtonNN1(),
                ButtonNN2(),
                ButtonAnalytical()
              ],
            ),
            const ButtonAnwenden(),
          ],
        ),
      ),
    );
  }
}

class ProjekterlaeuterungApp extends StatelessWidget {
  const ProjekterlaeuterungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Demonstrator'),
        ),
        drawer: const DrawerDemonstrator(),
        body: Center(
          child: Container(
            width: 1000,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(255, 235, 229, 229),
                  offset: Offset(10.0, 10.0),
                ),
              ],
            ),
            child: const Center(
                child: Text(
              'Einführungstext: ...',
            )),
          ),
        ),
      ),
    );
  }
}

class DrawerDemonstrator extends StatelessWidget {
  const DrawerDemonstrator({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Demonstrator'),
          ),
          ListTile(
            title: const Text('Start'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainApp()),
              );
            },
          ),
          ListTile(
            title: const Text('Projekterläuterung'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProjekterlaeuterungApp()),
              );
            },
          ),
        ],
      ),
    );
  }
}

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

class ButtonNN1 extends StatefulWidget {
  const ButtonNN1({super.key});

  @override
  State<ButtonNN1> createState() => _ButtonNN1();
}

class _ButtonNN1 extends State<ButtonNN1> {
  void _choose() {
    print('NN 1 wurde gewählt');
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _choose,
      child: const Text('NN 1'),
    );
  }
}

class ButtonNN2 extends StatefulWidget {
  const ButtonNN2({super.key});

  @override
  State<ButtonNN2> createState() => _ButtonNN2();
}

class _ButtonNN2 extends State<ButtonNN2> {
  void _choose() {
    print('NN 2 wurde gewählt');
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _choose,
      child: const Text('NN 2'),
    );
  }
}

class ButtonAnalytical extends StatefulWidget {
  const ButtonAnalytical({super.key});

  @override
  State<ButtonAnalytical> createState() => _ButtonAnalytical();
}

class _ButtonAnalytical extends State<ButtonAnalytical> {
  void _choose() {
    print('Analytical wurde gewählt');
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _choose,
      child: const Text('Analytical'),
    );
  }
}

class ButtonAnwenden extends StatefulWidget {
  const ButtonAnwenden({super.key});

  @override
  State<ButtonAnwenden> createState() => _ButtonAnwenden();
}

class _ButtonAnwenden extends State<ButtonAnwenden> {
  void _apply() {
    print('Modell mit gewählten Parametern wird angewendet');
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _apply,
      child: const Text('Anwenden'),
    );
  }
}

class DataDisplay extends StatelessWidget {
  const DataDisplay({super.key});

  /*
   * Aktualisiere Ein- und Ausgabedaten durch Knopfdruck
   * Eingabedaten: direkt hier aktualisiert
   * Ausgabedaten: HTTP-Anfrage an Python Backend
   */
  void handleInputChange(BuildContext context) {
    var inputData = context.read<InputData>();
    if (inputData.view.isEmpty) {
      inputData.add(0);
    } else {
      inputData.add(inputData.view.last + 1);
    }
    updateOutputData(inputData, context.read<OutputData>());
  }

  /*
   * Stelle HTTP-Anfrage und aktualisiere Daten
   */
  void updateOutputData(InputData inputData, OutputData outputData) {
    http
        .post(
      Uri.parse('http://127.0.0.1:5000'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(inputData.view),
    )
        .then((response) {
      if (response.statusCode == 200) {
        dynamic responseList = jsonDecode(response.body);
        outputData.list = List<int>.from(responseList as List);
      } else {
        print('Uh oh, schlechti :(');
      }
    }).catchError((error) {
      print('Uh oh, schlechti :(');
    });
  }

  /*
   * Darstellung der Daten und des Knopfs
   */
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () => handleInputChange(context),
          child: const Text("Ändere Eingabe"),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,

          // Möglichst weit unten in der Hierarchie, um unnötiges Neubauen des Rests zu verhindern.
          children: <Widget>[
            Consumer<InputData>(
                builder: (context, data, child) => Text(
                    'Data: ${data.view} (Aktualisiert von Flutter)')), // Akualisiert durch notifyListeners()
            Consumer<OutputData>(
                builder: (context, data, child) => Text(
                    'Data: ${data.view} (Aktualisiert von Python-Backend)')), // Akualisiert durch notifyListeners()
          ],
        ),
      ],
    );
  }
}

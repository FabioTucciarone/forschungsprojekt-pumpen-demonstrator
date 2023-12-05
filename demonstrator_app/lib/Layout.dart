import 'package:demonstrator_app/BackendConnection.dart';
import 'package:flutter/material.dart';
import 'MainScreen.dart';
import 'Intro.dart';
import 'package:demonstrator_app/BuildConnection.dart';

class Introduction extends StatelessWidget {
  const Introduction({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IntroHomeScaffold(),
    );
  }
}

class IntroHomeScaffold extends StatelessWidget {
  const IntroHomeScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demonstrator App"),
        backgroundColor: const Color.fromARGB(255, 184, 44, 44),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
        actions: const <Widget>[
          DebugSwitch(),
          ButtonAnmelden(),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(children: <TextSpan>[
                  TextSpan(
                      text: "Erklärung für Admins: \n",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          "1. Oben rechts anmelden \n 2. Auswählen welche Version \n ACHTUNG: keinen Weg zurückzukommen, wenn einmal die Version gewählt wurde (dass User keinen Zugriff auf Anmeldung etc. haben) \n Debug Mode für lokale Ausführung des Backends")
                ], style: TextStyle(fontSize: 30, color: Colors.black))),
          ),
          const SizedBox(
            height: 100,
          ),
          ElevatedButton(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 184, 44, 44),
                )),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => IntroScience()));
            },
            child: const Text("Los geht's zur wissenschaftlichen Version"),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 184, 44, 44),
                  )),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => IntroScreen()));
              },
              child: const Text(
                "Los geht's zur Kinderversion",
              ))
        ],
      ),
    );
  }
}

class DebugSwitch extends StatefulWidget {
  const DebugSwitch({super.key});

  @override
  State<DebugSwitch> createState() => _DebugSwitchState();
}

class _DebugSwitchState extends State<DebugSwitch> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      const Text(
        'Debug Modus',
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
      Switch(
        value: useOfBackend.backend.debugEnabled,
        activeColor: Colors.green,
        onChanged: (bool value) {
          setState(() {
            useOfBackend.backend.debugEnabled = value;
          });
        },
      )
    ]);
  }
}

class UseOfBackendConnection {
  static final UseOfBackendConnection _useOfBackendConnection =
      new UseOfBackendConnection._internal();
  BackendConnection backend = new BackendConnection();
  factory UseOfBackendConnection() {
    return _useOfBackendConnection;
  }
  UseOfBackendConnection._internal();
}

final useOfBackend = UseOfBackendConnection();

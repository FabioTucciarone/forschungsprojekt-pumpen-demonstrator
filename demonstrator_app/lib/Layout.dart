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
        leading: const IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: null,
        ),
        actions: const <Widget>[
          DebugSwitch(),
          ButtonAnmelden(),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 159, 151, 174),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Hier kommt der Einführungstext hin",
            textScaleFactor: 4,
          ),
          const SizedBox(
            height: 100,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MainSlide()));
            },
            child: const Text("Los geht's zur wissenschaftlichen Version"),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => IntroScreen()));
              },
              child: const Text("Los geht's zur Kinderversion"))
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
      const Text('Debug Mode'),
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

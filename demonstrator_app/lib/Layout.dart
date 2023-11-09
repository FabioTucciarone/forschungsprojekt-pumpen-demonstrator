import 'package:flutter/material.dart';
import 'MainScreen.dart';
import 'Intro.dart';
import 'BuildConnection.dart';
import 'BackendConnection.dart';

class Introduction extends StatelessWidget {
  const Introduction({super.key, required this.backend});

  final BackendConnection backend;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IntroHomeScaffold(
        backend: backend,
      ),
    );
  }
}

class IntroHomeScaffold extends StatelessWidget {
  const IntroHomeScaffold({
    super.key,
    required this.backend,
  });

  final BackendConnection backend;

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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainSlide(
                            backend: backend,
                          )));
            },
            child: const Text("Los geht's zur wissenschaftlichen Version"),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => IntroScreen(backend: backend)));
              },
              child: const Text("Los geht's zur Kinderversion"))
        ],
      ),
    );
  }
}

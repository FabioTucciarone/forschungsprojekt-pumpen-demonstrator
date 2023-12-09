import 'package:demonstrator_app/BackendConnection.dart';
import 'package:demonstrator_app/MainScreen.dart';
import 'package:flutter/material.dart';
import 'Intro.dart';
import 'package:demonstrator_app/BuildConnection.dart';

class Introduction extends StatelessWidget {
  const Introduction({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: IntroHomeScaffold(),
    );
  }
}

class IntroHomeScaffold extends StatelessWidget {
  void showErrorDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Fehler!"),
            content: const Text(
                "Melde dich erst an oder benutze den Debug Modus für lokale Benutzung!"),
            actions: <Widget>[
              TextButton(
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          OurColors.appBarTextColor),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          OurColors.appBarColor)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Verstanden"))
            ],
          );
        });
  }

  const IntroHomeScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demonstrator App"),
        titleTextStyle:
            const TextStyle(color: OurColors.appBarTextColor, fontSize: 25),
        backgroundColor: OurColors.appBarColor,
        actions: const <Widget>[
          DebugSwitch(),
          ButtonAnmelden(),
        ],
      ),
      backgroundColor: OurColors.backgroundColor,
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
                ], style: TextStyle(fontSize: 30, color: OurColors.textColor))),
          ),
          const SizedBox(
            height: 100,
          ),
          ElevatedButton(
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(OurColors.textColor),
                backgroundColor: MaterialStateProperty.all<Color>(
                  OurColors.appBarColor,
                )),
            onPressed: () {
              if (useOfBackend.backend.debugEnabled ||
                  useOfBackend.backend.readyForHTTPRequests) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MainSlide(children: false)));
              } else {
                showErrorDialog(context);
              }
            },
            child: const Text(
              "Los geht's zur wissenschaftlichen Version",
              style: TextStyle(color: OurColors.appBarTextColor),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(OurColors.textColor),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    OurColors.appBarColor,
                  )),
              onPressed: () {
                if (useOfBackend.backend.debugEnabled ||
                    useOfBackend.backend.readyForHTTPRequests) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const IntroKids()));
                } else {
                  showErrorDialog(context);
                }
              },
              child: const Text(
                "Los geht's zur Kinderversion",
                style: TextStyle(color: OurColors.appBarTextColor),
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
        'Debug Mode',
        style: TextStyle(color: OurColors.appBarTextColor, fontSize: 15),
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
      UseOfBackendConnection._internal();
  BackendConnection backend = BackendConnection();
  factory UseOfBackendConnection() {
    return _useOfBackendConnection;
  }
  UseOfBackendConnection._internal();
}

final useOfBackend = UseOfBackendConnection();

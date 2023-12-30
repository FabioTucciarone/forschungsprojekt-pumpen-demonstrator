import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Intro.dart';
import 'Layout.dart';
import 'MainScreen.dart';
import 'Outputbox.dart';

class AverageError extends StatelessWidget {
  final bool children;
  AverageError(this.children, {super.key});
  ResponseDecoder responseDecoder = ResponseDecoder();
  static dynamic publicError = 0;

  @override
  Widget build(BuildContext context) {
    final Future<String> future = context.watch<FutureNotifier>().future;
    final String text = children ? "Score:" : "Average Error:";
    return Container(
      constraints: const BoxConstraints(minWidth: 300),
      child: FutureBuilder(
          future: future,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            Widget child;
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != "keinWert") {
                responseDecoder.setResponse(snapshot.data);
                double averageError =
                    responseDecoder.jsonDecoded["average_error"];
                publicError = averageError;
                if (children) {
                  int roundedError = (averageError * 1000).round();
                  publicError = roundedError;
                  child = Text(
                    "$text $roundedError",
                    textScaleFactor: 2,
                  );
                } else {
                  child = Text(
                    "$text $averageError",
                    textScaleFactor: 2,
                  );
                }
              } else {
                child = Text(
                  "$text -",
                  textScaleFactor: 2,
                );
              }
            } else {
              child = Row(
                children: [
                  Text(
                    text,
                    textScaleFactor: 2,
                  ),
                  const SizedBox(
                    child: CircularProgressIndicator(
                      color: OurColors.accentColor,
                    ),
                  ),
                ],
              );
            }

            return child;
          }),
    );
  }
}

class Highscore extends StatefulWidget {
  const Highscore({super.key});

  @override
  State<Highscore> createState() => _HighscoreState();
}

class _HighscoreState extends State<Highscore> {
  int highscore = 0;
  String name = "";

  @override
  Widget build(BuildContext context) {
    context.watch<FutureNotifier>().future;
    Future<Map<String, dynamic>> futureMap =
        useOfBackend.backend.getHighscoreAndName();
    if (AverageError.publicError < highscore) {
      return Text(
        "Highscore: $highscore von $name",
        textScaleFactor: 2,
      );
    } else {
      return FutureBuilder(
          future: futureMap,
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> snapshot) {
            Widget child;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null) {
                highscore = (snapshot.data!["score"] * 1000).round();
                name = snapshot.data!["name"];
              }
              child = Text(
                "Highscore: $highscore von $name",
                textScaleFactor: 2,
              );
            } else {
              child = const Text("FEHLER");
            }
            return child;
          });
    }
  }
}

class HighscoreDialog extends StatelessWidget {
  const HighscoreDialog({super.key});

  void showHighscores() {
    print("hallo");
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
            foregroundColor:
                MaterialStateProperty.all<Color>(OurColors.appBarTextColor),
            backgroundColor:
                MaterialStateProperty.all<Color>(OurColors.appBarColor)),
        onPressed: showHighscores,
        child: const Text(
          "Highscores",
          textScaleFactor: 2,
        ));
  }
}

class ScoreBoard extends StatelessWidget {
  bool children;
  ScoreBoard(this.children, {super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            decoration: BoxDecoration(
                color: OurColors.accentColor,
                border: Border.all(color: OurColors.accentColor, width: 4.0),
                borderRadius: BorderRadius.circular(20)),
            child: AverageError(true)),
        const HighscoreDialog(),
        Container(
            constraints: const BoxConstraints(minWidth: 300),
            decoration: BoxDecoration(
                color: OurColors.accentColor,
                border: Border.all(color: OurColors.accentColor, width: 4.0),
                borderRadius: BorderRadius.circular(20)),
            child: const Highscore()),
      ],
    );
  }
}

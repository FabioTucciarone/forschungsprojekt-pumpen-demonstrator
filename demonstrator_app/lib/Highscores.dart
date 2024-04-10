import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Intro.dart';
import 'AdminPage.dart';
import 'MainScreen.dart';
import 'Outputbox.dart';

/// Widget that outputs the average Error of the Output.
/// If for children the value gets rounded and multiplied by 10000.
class AverageError extends StatelessWidget {
  final bool children;
  AverageError(this.children, {super.key});
  final ResponseDecoder responseDecoder = ResponseDecoder();
  static dynamic publicError = 0;

  /// A future builder is used to await the response of the server (the average error).
  @override
  Widget build(BuildContext context) {
    final Future<String> future = context.watch<FutureNotifier>().future;
    final String text = children
        ? "Punktzahl:"
        : "Average error of the AI generated output:"; // label for the average error which is "Punktzahl" in the children version.
    return Container(
      constraints: const BoxConstraints(minWidth: 300),
      child: FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          Widget child;
          // Response of the server, so the average error, is available.
          if (snapshot.connectionState == ConnectionState.done) {
            // The user already has selected values, so the average error is rounded and displayed.
            if (snapshot.data != "keinWert") {
              responseDecoder.setResponse(snapshot.data);
              double averageError =
                  responseDecoder.jsonDecoded["average_error"];
              publicError = averageError;
              if (children) {
                int roundedError = (averageError * 10000).round();
                publicError = roundedError;
                child = Text(
                  "$text $roundedError",
                  textScaleFactor: 1.8,
                );
              } else {
                averageError = double.parse(averageError.toStringAsFixed(4));
                child = Text(
                  "$text $averageError °C",
                  textScaleFactor: 1.8,
                );
              }
              // The user hasn't selected values yet, so "-" is displayed instead of a number.
            } else {
              child = Text(
                "$text -",
                textScaleFactor: 1.8,
              );
            }
            // Response isn't available yet, so a loading circle is shown.
          } else {
            child = Row(
              children: [
                Text(
                  text,
                  textScaleFactor: 1.8,
                ),
                const SizedBox(
                  width: 10,
                ),
                const SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    color: OurColors.accentColor,
                  ),
                ),
              ],
            );
          }
          return child;
        },
      ),
    );
  }
}

/// Widget that outputs the Highscore.
/// Only for children.
/// Doesnt update if the averageError is smaller than the current Highscore.
class Highscore extends StatefulWidget {
  const Highscore({super.key});

  @override
  State<Highscore> createState() => _HighscoreState();
}

class _HighscoreState extends State<Highscore> {
  int highscore = 0;
  String name = "";
  bool updateOnNext = true;
  bool update = true;
  @override
  Widget build(BuildContext context) {
    context.watch<FutureNotifier>().future;
    if (updateOnNext) {
      update = true;
      updateOnNext = false;
    } else {
      update = false;
    }
    if (AverageError.publicError < highscore) {
      updateOnNext = false;
    } else {
      updateOnNext = true;
    }
    if (!update) {
      return Text(
        "Highscore: $highscore von $name",
        textScaleFactor: 1.8,
      );
    } else {
      Future<Map<String, dynamic>> futureMap =
          useOfBackend.backend.getHighscoreAndName();
      return FutureBuilder(
          future: futureMap,
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> snapshot) {
            Widget child;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return child = Text(
                "Highscore: $highscore von $name",
                textScaleFactor: 1.8,
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null) {
                if (snapshot.data!["score"] != null) {
                  highscore = (snapshot.data!["score"] * 10000).round();
                  name = snapshot.data!["name"];
                }
              }
              child = Text(
                "Highscore: $highscore von $name",
                textScaleFactor: 1.8,
              );
            } else {
              child = const Text("FEHLER");
            }
            return child;
          });
    }
  }
}

/// Highscore Dialog for the Top 10 Highscores Button.
class HighscoreDialog extends StatelessWidget {
  const HighscoreDialog({super.key});

  /// Returns the top ten list which is used in the children version.
  /// A future builder is used to await the response of the server (the top ten list).
  Widget getToptenList() {
    Future<List<dynamic>> topTen = useOfBackend.backend.getTopTenList();

    return FutureBuilder(
        future: topTen,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          Widget child;
          // Response of the server, so the top ten list, isn't available yet.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                color: OurColors.accentColor,
              ),
            );
            // The top ten list is available.
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              List<dynamic> highscores = snapshot.data!;
              List<TableRow> tableRows = [];
              tableRows.add(const TableRow(children: [
                TableCell(
                    child: Text(
                  "#",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                TableCell(
                    child: Text(
                  "Name",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                TableCell(
                    child: Text(
                  "Punktzahl",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
              ]));
              for (int i = 0; i < highscores.length; i++) {
                String name = highscores[i][0];
                int score = (highscores[i][1] * 10000).round();
                tableRows.add(TableRow(children: [
                  TableCell(
                    child: Text((i + 1).toString()),
                  ),
                  TableCell(child: Text(name)),
                  TableCell(child: Text(score.toString()))
                ]));
              }
              child = Table(
                columnWidths: const <int, TableColumnWidth>{
                  1: FixedColumnWidth(128),
                  2: FixedColumnWidth(80),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: tableRows,
              );
            } else {
              child = const Text("Keine Highscores bis jetzt");
            }
          } else {
            child = const Text("FEHLER");
          }
          return child;
        });
  }

  /// Method to display the dialog for the top ten list and a close button.
  void showHighscores(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Bestenliste"),
            content: getToptenList(),
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                      OurColors.appBarTextColor),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(OurColors.appBarColor),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(15)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Schließen"),
              ),
            ],
          );
        });
  }

  /// Builds a "Bestenliste" button that shows the top ten list when it is pressed.
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        foregroundColor:
            MaterialStateProperty.all<Color>(OurColors.appBarTextColor),
        backgroundColor:
            MaterialStateProperty.all<Color>(OurColors.accentColor),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.all(10)),
      ),
      onPressed: () {
        showHighscores(context);
      },
      child: const Text(
        "Bestenliste",
        textScaleFactor: 1.8,
      ),
    );
  }
}

/// Combines all 3 Widgets for Children Mainscreen.
class ScoreBoard extends StatelessWidget {
  final bool children;
  const ScoreBoard(this.children, {super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            decoration: BoxDecoration(
                color: OurColors.accentColor,
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 4, 12.0, 4),
              child: AverageError(true),
            )),
        const HighscoreDialog(),
        Container(
            constraints: const BoxConstraints(minWidth: 300),
            decoration: BoxDecoration(
                color: OurColors.accentColor,
                borderRadius: BorderRadius.circular(20)),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(12.0, 4, 12.0, 4),
              child: Highscore(),
            )),
      ],
    );
  }
}

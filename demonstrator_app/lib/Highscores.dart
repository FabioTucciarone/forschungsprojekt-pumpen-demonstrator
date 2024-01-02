import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Intro.dart';
import 'Layout.dart';
import 'MainScreen.dart';
import 'Outputbox.dart';

//Widget that outputs the average Error of the Output.
//If for children the value gets rounded and multiplied by 1000
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

//Widget that outputs the Highscore
//only for children
//Doesnt update if the averageError is smaller than the current Highscore
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
        textScaleFactor: 2,
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
              return const SizedBox(
                child: CircularProgressIndicator(
                  color: OurColors.accentColor,
                ),
              );
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

//Highscore Dialog for the Top 10 Highscores Button
class HighscoreDialog extends StatelessWidget {
  const HighscoreDialog({super.key});

  Widget getToptenList() {
    Future<List<dynamic>> topTen = useOfBackend.backend.getTopTenList();

    return FutureBuilder(
        future: topTen,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          Widget child;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
                child: CircularProgressIndicator(
              color: OurColors.accentColor,
            ));
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
                  "Score",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
              ]));
              for (int i = 0; i < highscores.length; i++) {
                String name = highscores[i][0];
                int score = (highscores[i][1] * 1000).round();
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
                  2: FlexColumnWidth(),
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

  void showHighscores(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Highscores"),
            content: getToptenList(),
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
                  child: const Text("Schließen"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
            foregroundColor:
                MaterialStateProperty.all<Color>(OurColors.appBarTextColor),
            backgroundColor:
                MaterialStateProperty.all<Color>(OurColors.appBarColor)),
        onPressed: () {
          showHighscores(context);
        },
        child: const Text(
          "Highscores",
          textScaleFactor: 2,
        ));
  }
}

//combines all 3 Widgets for Children Mainscreen
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 0),
              child: AverageError(true),
            )),
        const HighscoreDialog(),
        Container(
            constraints: const BoxConstraints(minWidth: 300),
            decoration: BoxDecoration(
                color: OurColors.accentColor,
                border: Border.all(color: OurColors.accentColor, width: 4.0),
                borderRadius: BorderRadius.circular(20)),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 0),
              child: Highscore(),
            )),
      ],
    );
  }
}

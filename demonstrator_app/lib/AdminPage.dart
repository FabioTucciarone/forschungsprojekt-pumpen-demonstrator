import 'package:demonstrator_app/BackendConnection.dart';
import 'package:demonstrator_app/MainScreen.dart';
import 'package:flutter/material.dart';
import 'Intro.dart';
import 'package:demonstrator_app/BuildConnection.dart';
import 'NamePicker.dart';

class Introduction extends StatelessWidget {
  const Introduction({super.key});

  @override
  Widget build(BuildContext context) {
    NamePicker.loadNameFile();
    return const MaterialApp(
      home: IntroHomeScaffold(),
    );
  }
}

/// This is the Homescreen for admins.
class IntroHomeScaffold extends StatelessWidget {
  /// Method for showing the Errordialog, when the server hasn't been started.
  void getStatus(BuildContext context, bool children) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: getDialogComponents("content", children),
          actions: <Widget>[
            getDialogComponents("actions", children),
          ],
        );
      },
    );
  }

  /// Gets the content and actions of the dialog depending on [component] and [children].
  /// [component] indicates whether a content (message) or an action (button) is needed
  /// and [children] is propagated in case it goes to another page.
  /// A future builder is used to await the response of the server.
  Widget getDialogComponents(String component, bool children) {
    return FutureBuilder<bool>(
      future: useOfBackend.backend.testServerStatus(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        Widget child;
        // Response of the server, so its status, is available.
        if (snapshot.connectionState == ConnectionState.done) {
          // Server isn't available, so if the requested component is a content a corresponding message
          // is displayed and if the component is an action a "Verstanden" button is displayed.
          if (snapshot.data == false) {
            if (component == "content") {
              child = const Text("Server wurde nicht gestartet!");
            } else {
              child = ElevatedButton(
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
                child: const Text("Verstanden"),
              );
            }
            // Server is available, so if the requested component is a content no message
            // is displayed and if the component is an action no button is displayed.
          } else {
            if (component == "content") {
              child = const Text("");
            } else {
              child = const Text("");
            }
            Future.delayed(const Duration(microseconds: 0), () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainSlide(children: children)));
            });
          }
          // Response isn't yet available, so if the requested component is a content a loading circle
          // is displayed and if the component is an action a "Abbrechen" button is displayed.
        } else {
          if (component == "content") {
            child = const SizedBox(
              width: 60,
              height: 60,
              child: Center(
                  child: CircularProgressIndicator(
                color: OurColors.accentColor,
              )),
            );
          } else {
            child = ElevatedButton(
              style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(OurColors.appBarTextColor),
                backgroundColor:
                    MaterialStateProperty.all<Color>(OurColors.appBarColor),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.all(15)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Abbrechen"),
            );
          }
        }
        return child;
      },
    );
  }

  const IntroHomeScaffold({
    super.key,
  });

  /// Admin page with instructions and the selection of the version.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demonstrator App"),
        titleTextStyle:
            const TextStyle(color: OurColors.appBarTextColor, fontSize: 25),
        automaticallyImplyLeading: false,
        backgroundColor: OurColors.appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: OurColors.appBarTextColor,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => RegisterApp()));
          },
        ),
      ),
      backgroundColor: OurColors.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Instructions for the admin.
          Padding(
            padding: const EdgeInsets.fromLTRB(180, 20, 180, 20),
            child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(children: <TextSpan>[
                  TextSpan(
                      text: "Erklärung für Admins: \n",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          "Auswählen welche Version \n ACHTUNG: keinen Weg zurückzukommen, wenn einmal die Version gewählt wurde "
                          "(dass User keinen Zugriff auf Anmeldung etc. haben) \n Debug Mode für lokale Ausführung des Backends")
                ], style: TextStyle(fontSize: 25, color: OurColors.textColor))),
          ),
          const SizedBox(
            height: 40,
          ),
          // Button to continue to the science version.
          ElevatedButton(
            style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all<Color>(OurColors.appBarTextColor),
              backgroundColor: MaterialStateProperty.all<Color>(
                OurColors.appBarColor,
              ),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.all(15)),
            ),
            onPressed: () {
              getStatus(context, false);
            },
            child: const Text(
              "Los geht's zur wissenschaftlichen Version",
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          // Button to continue to the children version.
          ElevatedButton(
            style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all<Color>(OurColors.appBarTextColor),
              backgroundColor: MaterialStateProperty.all<Color>(
                OurColors.appBarColor,
              ),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.all(15)),
            ),
            onPressed: () {
              getStatus(context, true);
            },
            child: const Text(
              "Los geht's zur Kinderversion",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// This class is used so that [backend] and its methods can be accessed from anywhere.
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

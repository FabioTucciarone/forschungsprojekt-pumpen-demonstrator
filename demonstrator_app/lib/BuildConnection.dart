import 'package:demonstrator_app/Intro.dart';
import 'package:demonstrator_app/AdminPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Class for the login of the ssh account.
class RegisterApp extends StatelessWidget {
  const RegisterApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Demonstrator App",
          ),
          backgroundColor: OurColors.appBarColor,
          titleTextStyle:
              const TextStyle(color: OurColors.appBarTextColor, fontSize: 25),
        ),
        backgroundColor: OurColors.backgroundColor,
        body: Center(
          child: Container(
            width: 400,
            color: OurColors.accentColor,
            child: const Card(
              child: RegisterBox(),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterBox extends StatefulWidget {
  const RegisterBox();

  @override
  State<RegisterBox> createState() => _RegisterState();
}

/// Class for the entry form with the fields [username], [password], [portNumber] and [server] to be filled.
class _RegisterState extends State<RegisterBox> {
  final username = TextEditingController(); // Username of the IPVS account.
  final password = TextEditingController(); // Password of the IPVS account.
  final portNumber =
      TextEditingController(); // Number of the port the server is running on.
  final server =
      TextEditingController(); // Name of the IPVS server the server is running on.
  bool passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Anmelden',
              textScaleFactor: 2,
            ),
            // Entry field for the username with OurColors.appBarColor as focus color.
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextFormField(
                controller: username,
                decoration: InputDecoration(
                  hintText: 'Benutzername',
                  prefixIcon: const Icon(Icons.person),
                  prefixIconColor: MaterialStateColor.resolveWith(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.focused)) {
                      return OurColors.appBarColor;
                    }
                    return Colors.grey;
                  }),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: OurColors.accentColor, width: 2),
                  ),
                ),
                cursorColor: OurColors.accentColor,
                // When the enter key is pressed, the login takes place with the current entries.
                // If no port number is given 5000 is used and if no server is given pcsgs08 is used.
                focusNode: FocusNode(
                  onKeyEvent: (node, event) {
                    if (event.logicalKey == LogicalKeyboardKey.enter) {
                      if (portNumber.text == "") {
                        portNumber.text = "5000";
                      }
                      if (server.text == "") {
                        portNumber.text = "pcsgs08";
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultApp(
                            username: username.text,
                            password: password.text,
                            portNumber: int.parse(portNumber.text),
                            server: server.text,
                          ),
                        ),
                      );
                      return KeyEventResult.handled;
                    } else {
                      return KeyEventResult.ignored;
                    }
                  },
                ),
              ),
            ),
            // Entry field for the password with a visibility button/icon and OurColors.appBarColor as focus color.
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextFormField(
                obscureText: passwordVisible,
                controller: password,
                decoration: InputDecoration(
                  hintText: 'Passwort',
                  suffixIcon: IconButton(
                    icon: Icon(passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ),
                  suffixIconColor: MaterialStateColor.resolveWith(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.focused)) {
                      return OurColors.appBarColor;
                    }
                    return Colors.grey;
                  }),
                  prefixIcon: const Icon(Icons.key),
                  prefixIconColor: MaterialStateColor.resolveWith(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.focused)) {
                      return OurColors.appBarColor;
                    }
                    return Colors.grey;
                  }),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: OurColors.accentColor, width: 2),
                  ),
                ),
                cursorColor: OurColors.accentColor,
                // When the enter key is pressed, the login takes place with the current entries.
                // If no port number is given 5000 is used and if no server is given pcsgs08 is used.
                focusNode: FocusNode(
                  onKeyEvent: (node, event) {
                    if (event.logicalKey == LogicalKeyboardKey.enter) {
                      if (portNumber.text == "") {
                        portNumber.text = "5000";
                      }
                      if (server.text == "") {
                        server.text = "pcsgs08";
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultApp(
                            username: username.text,
                            password: password.text,
                            server: server.text,
                            portNumber: int.parse(portNumber.text),
                          ),
                        ),
                      );
                      return KeyEventResult.handled;
                    } else {
                      return KeyEventResult.ignored;
                    }
                  },
                ),
              ),
            ),
            Row(
              children: [
                Flexible(
                  // Entry field for the server name with OurColors.appBarColor as focus color.
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextFormField(
                      controller: server,
                      decoration: InputDecoration(
                        hintText: 'Server (pcsgs08)',
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: OurColors.accentColor, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.router),
                        prefixIconColor: MaterialStateColor.resolveWith(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.focused)) {
                            return OurColors.appBarColor;
                          }
                          return Colors.grey;
                        }),
                      ),
                      cursorColor: OurColors.accentColor,
                      // When the enter key is pressed, the login takes place with the current entries.
                      // If no port number is given 5000 is used and if no server is given pcsgs08 is used.
                      focusNode: FocusNode(
                        onKeyEvent: (node, event) {
                          if (event.logicalKey == LogicalKeyboardKey.enter) {
                            if (portNumber.text == "") {
                              portNumber.text = "5000";
                            }
                            if (server.text == "") {
                              server.text = "pcsgs08";
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultApp(
                                  username: username.text,
                                  password: password.text,
                                  server: server.text,
                                  portNumber: int.parse(portNumber.text),
                                ),
                              ),
                            );
                            return KeyEventResult.handled;
                          } else {
                            return KeyEventResult.ignored;
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Flexible(
                  // Entry field for the port number with OurColors.appBarColor as focus color.
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextFormField(
                      controller: portNumber,
                      decoration: InputDecoration(
                        hintText: 'Port (5000)',
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: OurColors.accentColor, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.router),
                        prefixIconColor: MaterialStateColor.resolveWith(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.focused)) {
                            return OurColors.appBarColor;
                          }
                          return Colors.grey;
                        }),
                      ),
                      cursorColor: OurColors.accentColor,
                      // When the enter key is pressed, the login takes place with the current entries.
                      // If no port number is given 5000 is used and if no server is given pcsgs08 is used.
                      focusNode: FocusNode(
                        onKeyEvent: (node, event) {
                          if (event.logicalKey == LogicalKeyboardKey.enter) {
                            if (portNumber.text == "") {
                              portNumber.text = "5000";
                            }
                            if (server.text == "") {
                              server.text = "pcsgs08";
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultApp(
                                  username: username.text,
                                  password: password.text,
                                  server: server.text,
                                  portNumber: int.parse(portNumber.text),
                                ),
                              ),
                            );
                            return KeyEventResult.handled;
                          } else {
                            return KeyEventResult.ignored;
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            // Button to start the login. If no port number is given 5000 is used and if no server is given pcsgs08 is used.
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
                if (portNumber.text == "") {
                  portNumber.text = "5000";
                }
                if (server.text == "") {
                  server.text = "pcsgs08";
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultApp(
                      username: username.text,
                      password: password.text,
                      server: server.text,
                      portNumber: int.parse(portNumber.text),
                    ),
                  ),
                );
              },
              child: const Text('Verbinden'),
            ),
            const SizedBox(
              height: 20,
            ),
            // Button to continue to the admin page. No login takes place and the entries are not used.
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
                setState(() {
                  useOfBackend.backend.debugEnabled = true;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Introduction()),
                );
              },
              child: const Text('Weiter im Debug Mode'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Class for the page that displays the feedback whether the login was successful.
class ResultApp extends StatelessWidget {
  const ResultApp(
      {super.key,
      required this.username,
      required this.password,
      required this.server,
      required this.portNumber});

  final String username;
  final String password;
  final String server;
  final int portNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demonstrator App"),
        titleTextStyle:
            const TextStyle(color: OurColors.appBarTextColor, fontSize: 25),
        backgroundColor: OurColors.appBarColor,
        leading: IconButton(
            color: OurColors.appBarTextColor,
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RegisterApp()));
            }),
      ),
      backgroundColor: OurColors.backgroundColor,
      body: Center(
        child: Result(
          username: username,
          password: password,
          server: server,
          portNumber: portNumber,
        ),
      ),
    );
  }
}

class Result extends StatefulWidget {
  final String username;
  final String password;
  final String server;
  final int portNumber;
  const Result(
      {super.key,
      required this.username,
      required this.password,
      required this.portNumber,
      required this.server});

  @override
  State<Result> createState() => _ResultState();
}

/// This class is used for showing the message whether the login was successful.
class _ResultState extends State<Result> {
  bool errorSSHConnect =
      false; // Whether an error occured during the log in (connect to ssh server).

  /// A future builder is used to await whether an error occured during the login or whether it was successful.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<void>(
        future: useOfBackend.backend
            .connectToSSHServer(widget.username, widget.password)
            .catchError((error) => {errorSSHConnect = true}),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          Widget child;
          // An error occured during connectToSSHServer(), so a corresponding message is displayed.
          if (errorSSHConnect) {
            child = Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 300,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Anmeldung fehlgeschlagen',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                // Button to repeat the log in.
                ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                        OurColors.appBarTextColor),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      OurColors.appBarColor,
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.all(15)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterApp()),
                    );
                  },
                  child: const Text('Erneut versuchen'),
                ),
              ],
            );
            print('Client authentication failed.');
            // No error occured and the response of the server is available, so the message "Anmeldung erfolgreich" is shown.
          } else if (snapshot.connectionState == ConnectionState.done) {
            child = Container(
              width: 300,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text(
                  'Anmeldung erfolgreich',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            );
            useOfBackend.backend.addListener(() {
              print('HTTP requests can be send now.');
            });
            useOfBackend.backend
                .forwardConnection(widget.server, widget.portNumber);
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Introduction()));
            });
            // No error occured but the connection to ssh server hasn't finished yet, so a loading circle is displayed.
          } else {
            child = const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: OurColors.accentColor,
              ),
            );
          }
          return child;
        },
      ),
    );
  }
}

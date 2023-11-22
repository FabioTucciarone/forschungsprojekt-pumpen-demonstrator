import 'package:demonstrator_app/Layout.dart';
import 'package:flutter/material.dart';
import 'BackendConnection.dart';

class ButtonAnmelden extends StatefulWidget {
  const ButtonAnmelden({super.key});

  @override
  State<ButtonAnmelden> createState() => _ButtonAnmelden();
}

class _ButtonAnmelden extends State<ButtonAnmelden> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterApp()),
          );
        },
        child: const Text('Anmelden'));
  }
}

class RegisterApp extends StatelessWidget {
  const RegisterApp();

  @override
  Widget build(BuildContext context) {
    BackendConnection backend = new BackendConnection();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demonstrator App"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Introduction(
                            backend: backend,
                          )));
            }),
        actions: const <Widget>[
          ButtonAnmelden(),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
          child: SizedBox(
        width: 400,
        child: Card(
          child: RegisterBox(),
        ),
      )),
    );
  }
}

class RegisterBox extends StatefulWidget {
  const RegisterBox();

  @override
  State<RegisterBox> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterBox> {
  final username = TextEditingController();
  final password = TextEditingController();
  bool passwordVisible = true;
  String message = '';
  Color colorMessage = Colors.white;
  BackendConnection backendConnect = new BackendConnection();

  Future<void> processRequest(
      TextEditingController username, TextEditingController password) async {
    try {
      await backendConnect.connectToSSHServer(
          username.text,
          password
              .text /*)
          .then((value) {
        backendConnect.forwardConnection('pcsgs08', 5000);
      }*/
          );
      setState(() {
        message = 'Log in successful';
        colorMessage = Colors.green;
      });
    } catch (err) {
      print('Error $err occured');
      setState(() {
        message = 'Log in failed';
        colorMessage = Colors.red;
      });
    }
    backendConnect.forwardConnection('pcsgs08', 5000);
    await Future.delayed(Duration(seconds: 2));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Introduction(backend: backendConnect)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Anmelden',
                textScaleFactor: 2,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  controller: username,
                  decoration: const InputDecoration(hintText: 'Username'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  obscureText: passwordVisible,
                  controller: password,
                  decoration: InputDecoration(
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      )),
                ),
              ),
              TextButton(
                onPressed: () {
                  //TODO: Problembehandlung
                  // - Hier geht irgendwie was bei der Übergabe schief.
                  //   Wenn ich direkt einen String übergebe funktioniert's, wenn nicht wird ein Fehler geworfen.
                  // - Hängt dein Programm auch wenn du's für Windows (also nicht als Webanwendung) kompilierst?
                  // - Falls alles nichts hilft: versuch mal dartssh2 zu installieren, vielleicht versucht es das zu verwenden
                  //   siehe: https://pub.dev/packages/dartssh2 unter "# Install the `dartssh` command."
                  //   Dann einfach in Notion dokumentieren, falls das das Problem löst. Daraus bauen wir dann bald die README.md Datei.
                  processRequest(username, password);

                  // Hier darf nichts mehr kommen, das wird entweder nicht ausgeführt, oder passiert zu schnell, weil die Portweiterleitung asynchron gestartet wird.
                  // ggf. könnt ihr in in BackendConnection einen Listener hinzufügen, der die Oberfläche aktualisiert: siehe Zu-Tun.
                },
                child: const Text('Verbinden'),
              ),
            ],
          ),
        ),
        Container(
          width: 300,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: colorMessage,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              message,
              style: TextStyle(color: colorMessage),
            ),
          ),
        ),
      ],
    );
  }
}

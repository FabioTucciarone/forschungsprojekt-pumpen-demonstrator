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
  BackendConnection backendConnect = new BackendConnection();

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ResultApp(
                            username: username.text,
                            password: password.text,
                            backendConnect: backendConnect,
                          )),
                );
              },
              child: const Text('Verbinden'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultApp extends StatelessWidget {
  const ResultApp(
      {super.key,
      required this.username,
      required this.password,
      required this.backendConnect});

  final String username;
  final String password;
  final BackendConnection backendConnect;

  @override
  Widget build(BuildContext context) {
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
                            backend: backendConnect,
                          )));
            }),
        actions: const <Widget>[
          ButtonAnmelden(),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
          child: Result(
        backendConnect: backendConnect,
        username: username,
        password: password,
      )),
    );
  }
}

class Result extends StatefulWidget {
  final BackendConnection backendConnect;
  final String username;
  final String password;
  const Result(
      {super.key,
      required this.backendConnect,
      required this.username,
      required this.password});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<void>(
        future: widget.backendConnect
            .connectToSSHServer(widget.username, widget.password),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          Widget child;
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              child = Container(
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
                    'Log in failed',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              );
              print('Error ${snapshot.error} occured');
            } else {
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
                    'Log in successful',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              );
            }
          } else {
            child = const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            );
          }
          return child;
        },
      ),
    );
  }
}

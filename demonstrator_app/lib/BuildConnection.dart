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
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 184, 44, 44),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterApp()),
          );
        },
        child: const Text(
          'Anmelden',
          style: TextStyle(color: Colors.black),
        ));
  }
}

class RegisterApp extends StatelessWidget {
  const RegisterApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demonstrator App"),
        backgroundColor: Color.fromARGB(255, 184, 44, 44),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 25),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Introduction()));
            }),
        actions: const <Widget>[
          ButtonAnmelden(),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 221, 115, 115),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 184, 44, 44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ResultApp(
                            username: username.text,
                            password: password.text,
                          )),
                );
              },
              child: const Text(
                'Verbinden',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultApp extends StatelessWidget {
  const ResultApp({super.key, required this.username, required this.password});

  final String username;
  final String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demonstrator App"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Introduction()));
            }),
        actions: const <Widget>[
          ButtonAnmelden(),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Result(
          username: username,
          password: password,
        ),
      ),
    );
  }
}

class Result extends StatefulWidget {
  final String username;
  final String password;
  const Result({super.key, required this.username, required this.password});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<void>(
        future: useOfBackend.backend
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
              useOfBackend.backend.addListener(() {
                print('HTTP requests can be send now.');
              });
              useOfBackend.backend.forwardConnection('pcsgs08', 5000);
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

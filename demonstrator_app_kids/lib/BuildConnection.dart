import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'Data.dart';
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
    return const Scaffold(
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

/*class Album {
  final ByteData image;
  const Album({
    required this.image,
  });
  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(image: json['image']);
  }
}*/

class _RegisterState extends State<RegisterBox> {
  final username = TextEditingController();
  final password = TextEditingController();

  /*Future<Album> fetchAlbum(responseBody) async {
    return Album.fromJson(jsonDecode(responseBody));
  }*/

  @override
  Widget build(BuildContext context) {
    //Future<Album> futureImage;
    String message = '';
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
                  controller: password,
                  decoration: const InputDecoration(hintText: 'Password'),
                ),
              ),
              TextButton(
                onPressed: () {
                  print(0);
                  BackendConnection backendConnect = new BackendConnection();
                  print(1);
                  backendConnect.connectToSSHServer(
                      username.toString(), password.toString());
                  print(2);
                  backendConnect.forwardConnection('pcsgs08', 5000);
                  print(3);
                  /*futureImage =
                      fetchAlbum(backendConnect.sendInputData(5, 880000));*/
                  FutureBuilder(
                    future: backendConnect.sendInputData(5, 880000),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        message = 'works'; //Text(jsonDecode(snapshot));
                      } else {
                        message = 'Error';
                      }
                      return const Text('loading');
                    },
                  );
                },
                child: const Text('Verbinden'),
              ),
            ],
          ),
        ),
        Text(message),
      ],
    );
  }
}

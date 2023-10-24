import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BackendConnection {
  SSHClient? client;
  int? localPort;
  ServerSocket? serverSocket;
  bool readyForHTTPRequests = false;

  bool debugEnabled = false;

  /// Default constructor with optional debugging parameter.
  BackendConnection({this.debugEnabled = false});

  /// Connect to the ipvslogin.informatik.uni-stuttgart.de server via port 22.
  ///
  /// Does nothing if debug mode is enabled.
  ///
  /// [username]: IPVS-account username.
  /// [password]: IPVS-account password.
  ///
  /// Theows exception if client cannot be authenticated.
  Future<void> connectToSSHServer(String username, String password) async {
    print(4);
    if (debugEnabled) return;
    print(5);
    SSHSocket socket = await SSHSocket.connect(
        "ipvslogin.informatik.uni-stuttgart.de", 22,
        timeout: const Duration(seconds: 20));
    print(5.5);
    final client = SSHClient(
      socket,
      username: username,
      onPasswordRequest: () => password,
    );
    print(6);
    this.client = client;
    await client.authenticated.onError((error, stackTrace) {
      throw "Client authentication failed.";
    });
    print(7);
    serverSocket = await ServerSocket.bind('127.0.0.1', 0);
    localPort = serverSocket!.port;
    print(8);
    print("SSH connection to ipvslogin successfully established");
  }

  /// Establish local port forwarding to a server of the IPVS-network.
  ///
  /// This method requires a valid connection to ipvslogin. Use connectToSSHServer() first.
  /// Note that this method works asynchronously and will await requests to the server!
  /// (Does nothing if debug mode is enabled.)
  ///
  /// [ipvsServerName]: Name of the server you want to access via ipvslogin. e.g.: "pcsgs08".
  /// [serverPort]: The port to which to connect. Should be equal to the port to which the internal Flask-server connects. You probably need 5000.
  void forwardConnection(String ipvsServerName, int serverPort) async {
    if (debugEnabled) return;

    if (serverSocket == null || client == null) {
      throw "Error: No connection to ipvslogin established. Did you wait for connectToSSHServer() to finish?";
    }

    readyForHTTPRequests = true;
    //TODO: Könnt ihr hier einen Zustand aktualisieren oder eine Benachrichtigung an die Oberfläche senden?
    // Ab hier soll es erlaubt sein HTTP-Anfragen zu senden:

    //notifyListeners();

    await for (final socket in serverSocket!) {
      if (client == null || client!.isClosed) {
        serverSocket!.close(); //TODO: Notwendig? Testen!
        break;
      }
      final SSHForwardChannel forward = await client!.forwardLocal(
        "$ipvsServerName.informatik.uni-stuttgart.de",
        serverPort); //TODO: Fehlerbehandlung hinzufügen?
      forward.stream
        .cast<List<int>>()
        .pipe(socket)
        .onError((error, stackTrace) {
          print("Warning: Transmission of data via forwarding failed.\n$error");
          //TODO: Können Fehler Auftreten? Log-Warnung falls Fehler.
        });
      socket.cast<Uint8List>().pipe(forward.sink);
    }
  }

  /// Close the ssh tunnel if it is open.
  void terminateConnection() {
    if (client != null && !client!.isClosed) {
      client!.close();
      print("ssh connection terminated.");
    }
    readyForHTTPRequests = false;
  }

  /// Send a http-post request with the input data (of phase 1) via the specified ssh tunnel.
  ///
  /// Returns the json body of the response. (for now) TODO: Read paper and code of model.
  Future<String> sendInputData(double permeability, double density) async {
    if (!readyForHTTPRequests && !debugEnabled) {
      throw "Error: No SSH-port forwarding established.";
    }

    final ip = debugEnabled ? "http://127.0.0.1:5000" : "http://127.0.0.1:$localPort";

    final response = await http.post(
      Uri.parse(ip),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"permeability": permeability, "density": density}),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      //TODO: Besser?
      stderr.writeln("HTTP-request failed with status code ${response.statusCode}");
      return response.body;
    }
  }

  /// If [debug] is true then all ssh methods will be ignored and http-requests will be sent to http://localhost:5000.
  /// This is useful for testing the backend with a flask debug-server on the lokal machine.
  void setDebugMode(bool enabled) {
    debugEnabled = enabled;
  }
}

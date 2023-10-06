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


  bool debug = false;

  /// Connect to the ipvslogin.informatik.uni-stuttgart.de server via port 22.
  /// 
  /// [username]: IPVS-account username.
  /// [password]: IPVS-account password.
  /// 
  /// Theows exception if client cannot be authenticated.
  Future<void> connectToSSHServer(String username, String password) async {

    if(debug) return;

    SSHSocket socket = await SSHSocket.connect("ipvslogin.informatik.uni-stuttgart.de", 22, timeout: const Duration(seconds: 20));
    final client = SSHClient(
      socket,
      username: username,
      onPasswordRequest: () => password,
    );
    
    this.client = client;
    await client.authenticated.onError((error, stackTrace) {
      throw "Client authentication failed.";
    });

    serverSocket = await ServerSocket.bind('127.0.0.1', 0); 
    localPort = serverSocket!.port;

    print("SSH connection to ipvslogin successfully established");
  }

  /// Establish local port forwarding to a server of the IPVS-network.
  /// This method requires a valid connection to ipvslogin. Use connectToSSHServer() first.
  /// 
  /// [ipvsServerName]: Name of the server you want to access via ipvslogin. e.g.: "pcsgs08".
  /// [serverPort]: The port to which to connect. Should be equal to the port to which the internal Flask-server connects. You probably need 5000.
  void forwardConnection(String ipvsServerName, int serverPort) async {

    if(debug) return;

    if(serverSocket == null || client == null) {
      throw "Error: No connection to ipvslogin established. Did you wait for connectToSSHServer() to finish?";
    }

    readyForHTTPRequests = true;

    await for (final socket in serverSocket!) { 
      if (client == null || client!.isClosed) { //TODO: Notwendig?
        serverSocket!.close();
        break;
      }
      final SSHForwardChannel forward = await client!.forwardLocal("$ipvsServerName.informatik.uni-stuttgart.de", serverPort); //TODO: Können Fehler Auftreten?
      forward.stream.cast<List<int>>().pipe(socket).onError((error, stackTrace) { //TODO: Notwendig?
        terminateConnection(); 
        throw "Error: $error \nTerminating ssh connection."; //TODO: Können Fehler Auftreten?
      });
      socket.cast<Uint8List>().pipe(forward.sink);
    } 
  }

  void terminateConnection() {
    if(client != null && !client!.isClosed) {
      client!.close();
    }
    readyForHTTPRequests = false;
    print("ssh connection terminated.");
  }

  /// TODO: Kommentieren
  Future<String> sendInputData(double permeability, double density) async {
    if(!readyForHTTPRequests) {
      throw "Error: No SSH-port forwarding established.";
    }

    final ip = debug ? "http://127.0.0.1:5000" : "http://127.0.0.1:$localPort";

    final response = await http.post(
      Uri.parse(ip),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"permeability": permeability, "density": density}),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else { //TODO: Besser?
      stderr.writeln("HTTP-request failed with status code ${response.statusCode}");
      return response.body;
    }
  }

  /// If [debug] is true then all ssh methods will be ignored and http-requests will be sent to http://localhost:5000.
  /// This is useful for testing the backend with a flask debug-server on the lokal machine.
  void setDebugMode(bool debug) {
    this.debug = debug;
  }
}
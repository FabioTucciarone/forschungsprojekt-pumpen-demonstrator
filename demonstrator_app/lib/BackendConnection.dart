import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BackendConnection with ChangeNotifier {
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
    if (debugEnabled) return;
    SSHSocket socket = await SSHSocket.connect(
        "ipvslogin.informatik.uni-stuttgart.de", 22,
        timeout: const Duration(seconds: 20));
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
    notifyListeners();

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

  Uri getUri(String destination) {
    return Uri.parse(debugEnabled
        ? "http://127.0.0.1:5000/$destination"
        : "http://127.0.0.1:$localPort/$destination");
  }

  /// Send a http-post request with the input data (of phase 1) via the specified ssh tunnel.
  ///
  /// [name]: Name for tracking the highest error score.
  ///
  /// Returns the json body of the response.
  Future<String> sendInputData(
      double permeability, double pressure, String name) async {
    if (!readyForHTTPRequests && !debugEnabled) {
      throw "Error: No SSH-port forwarding established.";
    }

    final ip = debugEnabled
        ? "http://127.0.0.1:5000/"
        : "http://127.0.0.1:$localPort/";

    final response = await http.post(
      getUri("get_model_result"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
          {"permeability": permeability, "pressure": pressure, "name": name}),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw "HTTP-request failed with status code ${response.statusCode}"; // Ich hoff das geht
    }
  }

  /// Send a http-post request with the input data (of phase 2) via the specified ssh tunnel.
  ///
  /// [name]: Name for tracking the highest error score.
  ///
  /// Returns the json body of the response.
  Future<String> sendInputDataPhase2(double permeability, double pressure,
      String name, List<double> pos) async {
    if (!readyForHTTPRequests && !debugEnabled) {
      throw "Error: No SSH-port forwarding established.";
    }
    final response = await http.post(
      getUri("get_2hp_model_result"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "permeability": permeability,
        "pressure": pressure,
        "name": name,
        "pos": pos
      }),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw "HTTP-request failed with status code ${response.statusCode}"; // Ich hoff das geht
    }
  }

  Future<Map<String, dynamic>> getValueRanges() async {
    if (!readyForHTTPRequests && !debugEnabled) {
      throw "Error: No SSH-port forwarding established.";
    }
    final response = await http.get(getUri("get_value_ranges"));
    if (response.statusCode == 200) {
      final valueRanges = jsonDecode(response.body) as Map<String, dynamic>;
      return valueRanges;
    } else {
      throw "HTTP-request failed with status code ${response.statusCode}";
    }
  }

  Future<List<dynamic>> getOutputShape() async {
    if (!readyForHTTPRequests && !debugEnabled) {
      throw "Error: No SSH-port forwarding established.";
    }
    final response = await http.get(getUri("get_2hp_field_shape"));
    if (response.statusCode == 200) {
      final outputShape = jsonDecode(response.body) as List<dynamic>;
      return outputShape;
    } else {
      throw "HTTP-request failed with status code ${response.statusCode}";
    }
  }

  Future<Map<String, dynamic>> getHighscoreAndName() async {
    if (!readyForHTTPRequests && !debugEnabled) {
      throw "Error: No SSH-port forwarding established.";
    }
    final response = await http.get(getUri("get_highscore_and_name"));
    if (response.statusCode == 200) {
      final highscoreAndName =
          jsonDecode(response.body) as Map<String, dynamic>;
      return highscoreAndName;
    } else {
      throw "HTTP-request failed with status code ${response.statusCode}";
    }
  }

  Future<List<dynamic>> getTopTenList() async {
    if (!readyForHTTPRequests && !debugEnabled) {
      throw "Error: No SSH-port forwarding established.";
    }
    final response = await http.get(getUri("get_top_ten_list"));
    if (response.statusCode == 200) {
      final highscoreAndName = jsonDecode(response.body) as List<dynamic>;
      return highscoreAndName;
    } else {
      throw "HTTP-request failed with status code ${response.statusCode}";
    }
  }

  /// If [debug] is true then all ssh methods will be ignored and http-requests will be sent to http://localhost:5000.
  /// This is useful for testing the backend with a flask debug-server on the lokal machine.
  void setDebugMode(bool enabled) {
    debugEnabled = enabled;
  }
}

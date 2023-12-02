import 'dart:io';

import 'package:demonstrator_app/Checkboxes.dart';
import 'package:demonstrator_app/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';

class OutputBox extends StatelessWidget {
  OutputBox({super.key, required this.name});
  final String name;
  final ResponseDecoder responseDecoder = ResponseDecoder();

  @override
  Widget build(BuildContext context) {
    final checkBoxModel = Provider.of<CheckboxModel>(context);
    final isChecked1 = checkBoxModel.isChecked1;
    final isChecked2 = checkBoxModel.isChecked2;
    final Future<String> future = context.watch<FutureNotifier>().future;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Text("Checkbox1 is ${isChecked1 ? 'checked' : 'not checked'}"),
        //Text("Checkbox2 is ${isChecked2 ? 'checked' : 'not checked'}"),
        SizedBox(
          height: 100,
          //child: Image.network('http://127.0.0.1:5000/last_model_result.png'))
          child: FutureBuilder<String>(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
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
                        'ERROR',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                  print('Error ${snapshot.error} occured');
                } else {
                  if (snapshot.data == "keinWert") {
                    child = const Text("Kein Wert bis jetzt");
                  } else {
                    responseDecoder.setResponse(snapshot.data);
                    child =
                        Image.memory(responseDecoder.getBytes("error_measure"));

                    // child = Image.network(
                    //   'http://127.0.0.1:5000/last_model_result.png');
                  }
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
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
          "$name",
          textScaleFactor: 1.2,
        ),
      ],
    );
  }
}

class ResponseDecoder {
  late String response;
  late Map<String, dynamic> jsonDecoded;

  ResponseDecoder();

  void setResponse(String? response) {
    this.response = response!;
    jsonDecoded = decodeData();
  }

  Map<String, dynamic> decodeData() {
    Map<String, dynamic> decodedData = json.decode(response);
    return decodedData;
  }

  Uint8List getBytes(String? type) {
    if (type == null) {
      throw ArgumentError('Type cannot be null');
    } else if (jsonDecoded.containsKey(type)) {
      dynamic value = jsonDecoded[type];
      if (value is String) {
        return base64.decode(jsonDecoded[type]!);
      } else {
        throw ArgumentError("Invalid Data type");
      }
    } else {
      throw ArgumentError('Type not found');
    }
  }
}

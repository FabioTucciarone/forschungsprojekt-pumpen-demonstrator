import 'package:demonstrator_app/Intro.dart';
import 'package:demonstrator_app/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';

//The different parts of the response, can be extended for longer responses
enum ImageType { aIGenerated, groundtruth, differenceField }

//Outputbox, one Box corresponds to one Image
//TO-DO (for performance) rearrange it so the response is decoded on a parent level (so the response doesn't get decoded 3 times)
class OutputBox extends StatelessWidget {
  OutputBox({super.key, required this.name});
  final ImageType name;
  final ResponseDecoder responseDecoder = ResponseDecoder();

  String getName(ImageType name) {
    if (name == ImageType.aIGenerated) {
      return 'KI generiert';
    } else if (name == ImageType.groundtruth) {
      return 'Grundwahrheit';
    }
    return 'Differenzfeld';
  }

  @override
  Widget build(BuildContext context) {
    final Future<String> future = context.watch<FutureNotifier>().future;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 100,
          child: FutureBuilder<String>(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  child = Container(
                    width: 1050,
                    height: 80,
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
                    child = Container(
                      width: 1050,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                      ),
                      child: const Center(
                        child: Text(
                          "Kein Wert bis jetzt",
                        ),
                      ),
                    );
                  } else {
                    responseDecoder.setResponse(snapshot.data);
                    if (name == ImageType.aIGenerated) {
                      child = Image.memory(
                          responseDecoder.getBytes("model_result"));
                    } else if (name == ImageType.groundtruth) {
                      child =
                          Image.memory(responseDecoder.getBytes("groundtruth"));
                    } else {
                      child = Image.memory(
                          responseDecoder.getBytes("error_measure"));
                    }
                  }
                }
              } else {
                child = Container(
                  width: 1050,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                  ),
                  child: const SizedBox(
                    width: 100,
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: OurColors.accentColor,
                      ),
                    ),
                  ),
                );
              }
              return child;
            },
          ),
        ),
        const SizedBox(
          width: 30,
        ),
        Text(
          "${getName(name)}",
          textScaleFactor: 1.2,
        ),
      ],
    );
  }
}

//Helper Class for decoding the HTTP Request to Uint8Lists so we can use them for Images
class ResponseDecoder {
  late String response;
  late Map<String, dynamic> jsonDecoded;

  ResponseDecoder();

  //initially setting the response
  //[response] The HTTP response in JSON
  void setResponse(String? response) {
    this.response = response!;
    jsonDecoded = decodeData();
  }

  //internal Method
  Map<String, dynamic> decodeData() {
    Map<String, dynamic> decodedData = json.decode(response);
    return decodedData;
  }

  //Use this method to get the bytes
  //[type] the identifier of the JSON value
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

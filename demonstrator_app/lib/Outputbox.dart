import 'package:demonstrator_app/Intro.dart';
import 'package:demonstrator_app/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';

/// The different parts of the response, can be extended for longer responses.
enum ImageType { aIGenerated, groundtruth, differenceField }

/// Outputbox, one Box corresponds to one Image.
//TO-DO (for performance) rearrange it so the response is decoded on a parent level (so the response doesn't get decoded 3 times)
class OutputBox extends StatelessWidget {
  OutputBox({super.key, required this.name, required this.children});
  final ImageType name;
  final bool children;
  final ResponseDecoder responseDecoder = ResponseDecoder();
  Widget latestOutput = Container(
    width: 940,
    height: 100,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black),
    ),
  );

  /// Returns the label/description of the output image.
  Widget textWidget(ImageType name, bool children) {
    if (name == ImageType.groundtruth && children == false) {
      return GroundtruthText();
    }
    return Text(getName(name, children), textScaleFactor: 1.2);
  }

  /// Returns the label/description of the output image if it is not the groundtruth
  /// and not for the children version.
  String getName(ImageType name, bool children) {
    if (name == ImageType.aIGenerated) {
      if (children) {
        return 'KAIs Berechnung';
      } else {
        return 'AI generated';
      }
    } else if (name == ImageType.groundtruth) {
      if (children) {
        return 'Echte Lösung';
      } else {
        return 'Groundtruth';
      }
    }
    if (children) {
      return 'Unterschied';
    } else {
      return 'Difference field';
    }
  }

  /// A future builder is used to await the response of the server (the output images of the AI).
  @override
  Widget build(BuildContext context) {
    final Future<String> future = context.watch<FutureNotifier>().future;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 130,
          child: FutureBuilder<String>(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              Widget child;
              // Response of the server, so the output, is available.
              if (snapshot.connectionState == ConnectionState.done) {
                // An error occured, so a corresponding message is displayed.
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
                  // No error occured.
                } else {
                  // The user hasn't selected values yet, so a corresponding message is displayed.
                  if (snapshot.data == "keinWert") {
                    child = Container(
                      width: 940,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: children
                            ? const Text(
                                "Kein Wert bis jetzt",
                              )
                            : const Text('No value so far'),
                      ),
                    );
                    // The user already has selected values, so the output image is shown.
                  } else {
                    responseDecoder.setResponse(snapshot.data);
                    if (name == ImageType.aIGenerated) {
                      child = Image.memory(
                          responseDecoder.getBytes("model_result"));
                      latestOutput = child;
                    } else if (name == ImageType.groundtruth) {
                      child =
                          Image.memory(responseDecoder.getBytes("groundtruth"));
                      latestOutput = child;
                    } else {
                      child = Image.memory(
                          responseDecoder.getBytes("error_measure"));
                      latestOutput = child;
                    }
                  }
                }
                // Response isn't available yet, so a loading circle is displayed above the latest output image.
              } else {
                child = Stack(
                  children: <Widget>[
                    latestOutput,
                    const Positioned(
                      top: -6,
                      left: 450,
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: OurColors.accentColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return child;
            },
          ),
        ),
        const SizedBox(
          width: 30,
        ),
        textWidget(name, children)
      ],
    );
  }
}

/// Class to obtain the type of method that was used to generate the grountruth.
class GroundtruthText extends StatefulWidget {
  const GroundtruthText({super.key});
  @override
  State<GroundtruthText> createState() => _GroundtruthTextState();
}

class _GroundtruthTextState extends State<GroundtruthText> {
  String method = " ";

  @override
  Widget build(BuildContext context) {
    final Future<String> future = context.watch<FutureNotifier>().future;
    final ResponseDecoder responseDecoder = ResponseDecoder();
    future.then((value) => {
          if (value != "keinWert" && mounted)
            {
              responseDecoder.setResponse(value),
              setState(() {
                String methodName =
                    responseDecoder.jsonDecoded["groundtruth_method"];
                if (methodName == "closest") {
                  method = ": Closest parameter point";
                } else {
                  method = ": Interpolation";
                }
              })
            }
        });
    return Text(
      "Groundtruth $method",
      textScaleFactor: 1.2,
    );
  }
}

/// Helper Class for decoding the HTTP Request to Uint8Lists so we can use them for Images.
class ResponseDecoder {
  late String response;
  late Map<String, dynamic> jsonDecoded;

  ResponseDecoder();

  /// Initially setting the response.
  /// [response] The HTTP response in JSON.
  void setResponse(String? response) {
    this.response = response!;
    jsonDecoded = decodeData();
  }

  /// Internal Method.
  Map<String, dynamic> decodeData() {
    Map<String, dynamic> decodedData = json.decode(response);
    return decodedData;
  }

  /// Use this method to get the bytes.
  /// [type] the identifier of the JSON value.
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

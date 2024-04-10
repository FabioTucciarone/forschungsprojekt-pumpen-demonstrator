import 'package:demonstrator_app/MainScreen.dart';
import 'AdminPage.dart';
import 'Intro.dart';
import 'Outputbox.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Class for a box which is above the output image and where you can change the position of the second heat pump.
/// It can be adjusted by its [width], [height] and a boolean indicating whether the slider is for the [children] version.
class PumpInputBox extends StatefulWidget {
  final double width;
  final double height;
  final List<dynamic>?
      valueRange; // Possible range of the position of the heat pump.
  final bool children;
  Offset currentValue = const Offset(0, 0); // Current Position of the pump.
  PumpInputBox({
    super.key,
    required this.width,
    required this.height,
    required this.valueRange,
    required this.children,
  });

  Offset getCurrent() {
    return currentValue;
  }

  @override
  State<PumpInputBox> createState() => _PumpInputBoxState();
}

class _PumpInputBoxState extends State<PumpInputBox> {
  Offset pumpPos = const Offset(10,
      10); // Selected position that can be corrected if it is outside the box. Initiated with position (10,10).
  final ResponseDecoder responseDecoder = ResponseDecoder();
  double top = 30; // Used to position the gesture detector and messages.
  double left = 85; // Used to position the gesture detector and messages.
  // latest output that is used to show a loading circle over this image while waiting for the next output.
  Widget latestOutput = Container(
    width: 1105,
    height: 88,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.white),
    ),
  );

  @override
  void initState() {
    super.initState();
    widget.currentValue = determineValue(pumpPos);
  }

  /// Determines the actual position within the heat pump field (currentValue) that the position of
  /// the thumb represents ([pumpPos]).
  Offset determineValue(Offset pumpPos) {
    int endX = widget.valueRange?[0];
    int endY = widget.valueRange?[1];
    double intervalX = widget.width / endX;
    double intervalY = widget.height / endY;
    double valueX = pumpPos.dx / intervalX;
    double valueY = pumpPos.dy / intervalY;
    return Offset(valueX, valueY);
  }

  /// This method makes sure that the pointer doesn't leave the input box.
  void correctingPosition(Offset position) {
    if (position.dx > widget.width) {
      position = Offset(widget.width, position.dy);
    }
    if (position.dx < 0) {
      position = Offset(0, position.dy);
    }
    if (position.dy > widget.height) {
      position = Offset(position.dx, widget.height);
    }
    if (position.dy < 0) {
      position = Offset(position.dx, 0);
    }
    setState(() {
      pumpPos = position;
      widget.currentValue = determineValue(pumpPos);
    });
  }

  /// Returns the gesture detector widget that corrects and processes the gestures made by the user.
  /// [color] is the color of the border of this widget and changeable since the border shouldn't be
  /// visible when an output is available.
  Widget getGestureDetectorWidget(Color color) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // When the pointer is moved or clicked to a position, it is corrected to avoid leaving the box.
        onPanStart: (DragStartDetails details) {
          correctingPosition(details.localPosition);
        },
        onPanUpdate: (DragUpdateDetails details) {
          correctingPosition(details.localPosition);
        },
        onTapDown: (TapDownDetails details) {
          correctingPosition(details.localPosition);
        },
        // When the pointer stops moving and is released, the inputs are send to the backend and
        // the output is displayed.
        onPanEnd: (DragEndDetails details) {
          FutureNotifierPhase2.slider = false;
          FutureNotifierPhase2.clickedOnce = true;
          MainSlide.futureNotifierPhase2.setFuture(useOfBackend.backend
              .sendInputDataPhase2(
                  MainScreenElements.permeabilitySlider.getCurrent(),
                  MainScreenElements.pressureSlider.getCurrent(),
                  MainMaterial.getName(),
                  [widget.currentValue.dx, widget.currentValue.dy]));
          MainSlide.restartTimer.restartTimer();
        },
        // When a spot on the pump input box is clicked, the inputs are send to the backend and
        // the output is displayed.
        onTapUp: (TapUpDetails details) {
          FutureNotifierPhase2.slider = false;
          FutureNotifierPhase2.clickedOnce = true;
          MainSlide.futureNotifierPhase2.setFuture(useOfBackend.backend
              .sendInputDataPhase2(
                  MainScreenElements.permeabilitySlider.getCurrent(),
                  MainScreenElements.pressureSlider.getCurrent(),
                  MainMaterial.getName(),
                  [widget.currentValue.dx, widget.currentValue.dy]));
          MainSlide.restartTimer.restartTimer();
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: color),
          ),
          child: CustomPaint(
            painter: PointerThumb(pumpPos),
          ),
        ),
      ),
    );
  }

  /// Builds a stack consisting of the output and the input box for the position of the second heat pump (gesture detector widget).
  /// The sending of the selected data is triggered when the pointer is released or clicked. The position is corrected
  /// whenever the pointer is moved or the input box is clicked.
  /// A future builder is used to await the response of the server (the output of the AI).
  @override
  Widget build(BuildContext context) {
    final Future<String> future = context.watch<FutureNotifierPhase2>().future;
    return SizedBox(
      width: 1600,
      height: 200,
      child: FutureBuilder<String>(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          Widget child;
          // Response of the server, so the output, is available.
          if (snapshot.connectionState == ConnectionState.done) {
            // An error occured, so a corresponding message is displayed.
            if (snapshot.hasError) {
              child = Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Positioned(
                    top: top,
                    left: left,
                    child: Container(
                      width: widget.width,
                      height: widget.height,
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
                    ),
                  ),
                  getGestureDetectorWidget(const Color.fromRGBO(255, 0, 0, 0)),
                ],
              );
              print('Error ${snapshot.error} occured');
              // No error occured.
            } else {
              // The user hasn't selected values yet, so this fact is displayed in the science version or
              // an instruction is shown in the children version.
              if (snapshot.data == "keinWert") {
                child = Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    Positioned(
                      top: top,
                      left: left,
                      child: Container(
                        width: widget.width,
                        height: widget.height,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white),
                        ),
                        child: Center(
                          child: widget.children
                              ? const Text(
                                  "Klick hier rein!",
                                  textScaleFactor: 3,
                                )
                              : const Text(
                                  'No value so far',
                                ),
                        ),
                      ),
                    ),
                    getGestureDetectorWidget(Colors.black),
                  ],
                );
                // The user already has selected values, so the output is shown.
              } else {
                responseDecoder.setResponse(snapshot.data);
                child = Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    Image.memory(responseDecoder.getBytes("model_result")),
                    getGestureDetectorWidget(const Color.fromRGBO(0, 0, 0, 0)),
                  ],
                );
                latestOutput =
                    Image.memory(responseDecoder.getBytes("model_result"));
              }
            }
            // Response isn't available yet, so a loading circle over the latest output is shown.
          } else {
            child = Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                latestOutput,
                const Positioned(
                  top: 22,
                  left: 600,
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
                getGestureDetectorWidget(const Color.fromRGBO(0, 0, 0, 0)),
              ],
            );
          }
          return child;
        },
      ),
    );
  }
}

/// Class for the appearance and position of the pointer.
class PointerThumb extends CustomPainter {
  final Offset pos;
  PointerThumb(this.pos);

  /// Paints the pointer in the shape of a circle. [pos] is used to put the pointer at the position the user chooses.
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        pos, 6, Paint()..color = const Color.fromRGBO(255, 0, 0, 0.8));
  }

  @override
  bool shouldRepaint(PointerThumb oldThumb) {
    return true;
  }
}

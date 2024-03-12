import 'package:demonstrator_app/MainScreen.dart';
import 'AdminPage.dart';
import 'Intro.dart';
import 'Outputbox.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Class for a box which is above the output picture and where you can change the position of the second heat pump.
/// It can be adjusted by its width, height and a boolean indicating whether the slider is for the children version.
class PumpInputBox extends StatefulWidget {
  final double width;
  final double height;
  final List<dynamic>? valueRange;
  final bool children;
  Offset currentValue = const Offset(0, 0);
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
  Offset pumpPos = const Offset(10, 10);
  final ResponseDecoder responseDecoder = ResponseDecoder();
  double top = 30;
  double left = 85;
  Widget lastOutput = Container(
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

  /// Determines the value that the position of the thumb represents.
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

  Widget getGestureDetectorWidget(Color color) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (DragStartDetails details) {
          correctingPosition(details.localPosition);
        },
        onPanUpdate: (DragUpdateDetails details) {
          correctingPosition(details.localPosition);
        },
        onTapDown: (TapDownDetails details) {
          correctingPosition(details.localPosition);
        },
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

  /// Builds a stack consisting of the output and the input box for the position of the second heat pump.
  /// The sending of the selected data is triggered when the pointer is released or clicked. The position is corrected
  /// whenever the pointer is moved or the input box is clicked.
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
          if (snapshot.connectionState == ConnectionState.done) {
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
            } else {
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
              } else {
                responseDecoder.setResponse(snapshot.data);
                child = Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    Image.memory(responseDecoder.getBytes("model_result")),
                    getGestureDetectorWidget(const Color.fromRGBO(0, 0, 0, 0)),
                  ],
                );
                lastOutput =
                    Image.memory(responseDecoder.getBytes("model_result"));
              }
            }
          } else {
            child = Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                lastOutput,
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

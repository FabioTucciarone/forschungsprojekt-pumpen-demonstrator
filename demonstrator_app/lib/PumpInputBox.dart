import 'package:demonstrator_app/MainScreen.dart';

import 'package:flutter/material.dart';

/// Class for a box which is above the output picture and where you can change the position of the second heat pump.
/// It can be adjusted by its width, height and a boolean indicating whether the slider is for the children version.
class PumpInputBox extends StatefulWidget {
  final double width;
  final double height;
  final bool children;
  const PumpInputBox({
    super.key,
    required this.width,
    required this.height,
    required this.children,
  });

  @override
  State<PumpInputBox> createState() => _PumpInputBoxState();
}

class _PumpInputBoxState extends State<PumpInputBox> with MainScreenElements {
  Offset pumpPos = const Offset(100, 100);
  Offset currentValue = const Offset(0, 0);
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    currentValue = determineValue(pumpPos);
  }

  /// Determines the value that the position of the thumb represents.
  Offset determineValue(Offset pumpPos) {
    double endX = 255;
    double endY = 99;
    double intervalX = widget.width / endX;
    double intervalY = widget.height / endY;
    double valueX = pumpPos.dx / intervalX;
    double valueY = pumpPos.dy / intervalY;
    print('x: $valueX');
    print('y: $valueY');
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
      currentValue = determineValue(pumpPos);
    });
  }

  /// Builds a stack consisting of the output and the input box for the position of the second heat pump.
  /// The sending of the selected data is triggered when the pointer is released or clicked. The position is corrected
  /// whenever the pointer is moved or the input box is clicked. The pointer appears when the cursor hovers over the input box.
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Image.asset(
          'assets/example2ndPhase.jpg',
          scale: 2,
        ),
        Positioned(
          top: 12,
          left: 29,
          child: MouseRegion(
            onEnter: (event) => setState(() {
              opacity = 1.0;
            }),
            onExit: (event) => setState(() {
              opacity = 0.0;
            }),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (DragStartDetails details) {
                correctingPosition(details.localPosition);
              },
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                correctingPosition(details.localPosition);
              },
              onTapDown: (TapDownDetails details) {
                correctingPosition(details.localPosition);
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                /*MainSlide.futureNotifier.setFuture(useOfBackend.backend
                    .sendInputData(
                        MainScreenElements.permeabilitySlider.getCurrent(),
                        currentValue,
                        MainMaterial.getName()));*/
                MainSlide.restartTimer.restartTimer();
              },
              onTapUp: (TapUpDetails details) {
                /*MainSlide.futureNotifier.setFuture(useOfBackend.backend
                    .sendInputData(
                        MainScreenElements.permeabilitySlider.getCurrent(),
                        currentValue,
                        MainMaterial.getName()));*/
                MainSlide.restartTimer.restartTimer();
              },
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.black),
                ),
                child: CustomPaint(
                  painter: SliderThumb(pumpPos, opacity),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Class for the appearance and position of the pointer.
class SliderThumb extends CustomPainter {
  final Offset pos;
  double opacity;
  SliderThumb(this.pos, this.opacity);

  /// Paints the pointer in the shape of a circle. [pos] is used to put the pointer at the position
  /// the user chooses and [opacity] determines whether the circle is visible or not.
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        pos, 6, Paint()..color = Color.fromRGBO(255, 0, 0, opacity));
  }

  @override
  bool shouldRepaint(SliderThumb oldThumb) {
    return true;
  }
}

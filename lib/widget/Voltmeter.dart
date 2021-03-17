import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:typed_data';

class Voltmeter extends StatefulWidget {
  Voltmeter({Key key, this.milliVolts}) : super(key: key);

  final int milliVolts;
  String get volts => (milliVolts / 100).toStringAsFixed(2);

  @override
  _VoltmeterState createState() => _VoltmeterState();
}

class _VoltmeterState extends State<Voltmeter> {
  ui.Image image;
  bool isImageLoaded = false;

  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    final ByteData data = await rootBundle.load('assets/images/scale.png');
    image = await _loadImage(Uint8List.view(data.buffer));
  }

  Future<ui.Image> _loadImage(List<int> img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageLoaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {

    if (!isImageLoaded) {
      return Center(child: CircularProgressIndicator());
    }
    return FittedBox(
      child: SizedBox(
        width: image.width.toDouble(),
        height: image.height.toDouble(),
        child: CustomPaint(
          painter: VoltmeterPainter(image: image, milliVolts: widget.milliVolts),
        ),
      ),
    );
  }
}

class VoltmeterPainter extends CustomPainter {
  static const _ANGLE_ON_MILLIVOLT = (75 / 500);
  static const _DEGREE_ON_RADIAN = 0.0175;

  double radiusHigh;
  double radiusLow;
  double pictureCenterX;
  double arrowCenterOffsetY;
  int milliVolts;

  double milliVoltAngleValue;

  double arrowAngleRadians;

  ui.Image image;

  VoltmeterPainter({this.image, this.milliVolts});

  @override
  void paint(Canvas canvas, Size size) {
    milliVoltAngleValue = _ANGLE_ON_MILLIVOLT * milliVolts;
    radiusHigh = size.height * 1.05;
    radiusLow = size.height * 0.8;
    pictureCenterX = size.width / 2 + 1;
    arrowCenterOffsetY = size.height * 1.5;
    milliVoltAngleValue = _ANGLE_ON_MILLIVOLT * milliVolts;
    arrowAngleRadians = _toRadians(milliVoltAngleValue % 360);

    drawScale(canvas);
    drawArrow(canvas, size, milliVolts);

    final arrowTop = Offset(
        _getX(radiusHigh, arrowAngleRadians, pictureCenterX), _getY(radiusHigh, arrowAngleRadians, arrowCenterOffsetY));

    final arrowLeftBottom = Offset(_getX(radiusHigh - 15, arrowAngleRadians + 0.02, pictureCenterX),
        _getY(radiusHigh - 15, arrowAngleRadians + 0.02, arrowCenterOffsetY));

    final arrowRightBottom = Offset(_getX(radiusHigh - 15, arrowAngleRadians - 0.02, pictureCenterX),
        _getY(radiusHigh - 15, arrowAngleRadians - 0.02, arrowCenterOffsetY));

    final path = Path();
    path.moveTo(arrowTop.dx, arrowTop.dy);
    path.lineTo(arrowLeftBottom.dx, arrowLeftBottom.dy);
    path.lineTo(arrowRightBottom.dx, arrowRightBottom.dy);

    canvas.drawPath(
        path,
        Paint()
          ..strokeWidth = 1
          ..color = Colors.red);
  }

  double _toRadians(double degrees) => (135 - degrees) * _DEGREE_ON_RADIAN;

  void drawArrow(Canvas canvas, Size size, int milliVolts) {
    final mainLineStartOffset = Offset(
        _getX(radiusLow , arrowAngleRadians, pictureCenterX), _getY(radiusLow, arrowAngleRadians, arrowCenterOffsetY));
    final mainLineEndOffset = Offset(
        _getX(radiusHigh - 6, arrowAngleRadians, pictureCenterX), _getY(radiusHigh - 6, arrowAngleRadians, arrowCenterOffsetY));

    canvas.drawLine(
        mainLineStartOffset,
        mainLineEndOffset,
        Paint()
          ..strokeWidth = 3
          ..color = Colors.red);
  }

  double _getX(double radius, double angle, double offset) => offset + radius * cos(angle);

  double _getY(double radius, double angle, double offset) => offset - radius * sin(angle);

  void drawScale(Canvas canvas) {
    canvas.drawImage(image, Offset(0.0, 0.0), Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

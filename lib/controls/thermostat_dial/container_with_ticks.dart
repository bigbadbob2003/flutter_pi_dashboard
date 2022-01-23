import 'package:flutter/material.dart';

class ContainerWithTicks extends StatelessWidget {
  const ContainerWithTicks({
    Key? key,
    required this.child,
    this.height,
    this.tickColor = Colors.black,
    this.tickCount = 10,
  }) : super(key: key);

  final Widget child;
  final double? height;
  final Color tickColor;
  final int tickCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(painter: TickPainter(tickColor: tickColor, tickCount: tickCount), child: child),
    );
  }
}

class TickPainter extends CustomPainter {
  TickPainter({
    required this.tickColor,
    required this.tickCount,
  });

  final Color tickColor;
  final int tickCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = tickColor;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width / 4, size.height / 2), paint);
    canvas.drawLine(Offset((size.width / 4) * 3, size.height / 2), Offset(size.width, size.height / 2), paint);

    paint.strokeWidth = 1;

    for (var i = 0; i < tickCount; i++) {
      canvas.drawLine(Offset(0, (size.height / 10) * i), Offset(size.width / 8, (size.height / 10) * i), paint);
      canvas.drawLine(Offset((size.width / 8) * 7, (size.height / 10) * i), Offset(size.width, (size.height / 10) * i), paint);
    }
  }

  @override
  bool shouldRepaint(TickPainter oldDelegate) => false;
}

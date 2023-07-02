import 'dart:math';

import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 25,
        height: 25,
        child: CustomPaint(
          painter: MyCustomPainter(),
          child: Container(), // You can add other widgets here if needed
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Set up the paint object with desired properties
    final fillPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Define the position and dimensions of the circle
    final ox = size.width / 2;
    final oy = size.height / 2;
    final r = size.width / 2;

    // Define the path for the cut part of the circle
    final leftPath = Path()
      ..moveTo(ox, oy - r) // Move to the starting point
      ..arcTo(
        Rect.fromCircle(center: Offset(ox, oy), radius: r),
        pi / 2, // Start angle in radians (90 degrees counterclockwise)
        pi, // Sweep angle in radians (180 degrees)
        true, // Whether to draw in the counterclockwise direction
      )
      ..lineTo(ox, oy - r) // Draw a line to close the path
      ..close(); // Close the path

    // Draw the cut part of the circle on the canvas
    canvas.drawPath(leftPath, fillPaint);
    canvas.drawPath(leftPath, strokePaint);

    final reluPath = Path()
      ..moveTo(ox, oy)
      ..lineTo(ox + r / 2, oy)
      ..lineTo(ox + r * sqrt(3) / 2, oy - r / 2);
    canvas.drawArc(Rect.fromCircle(center: Offset(ox, oy), radius: r), -pi / 2,
        pi, false, strokePaint);
    canvas.drawPath(reluPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Set to true if the painter should repaint on updates
  }
}

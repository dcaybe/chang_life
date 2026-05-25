import 'package:flutter/material.dart';
import 'dart:math' as math;

class ChangeLifeLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const ChangeLifeLogo({super.key, this.size = 100, this.color});

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size(size, size), painter: _LogoPainter(color: logoColor)),
          Text(
            'CL',
            style: TextStyle(
              fontFamily: 'sans-serif',
              fontWeight: FontWeight.w900,
              fontSize: size * 0.35,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Original SVG size is 100x100, radius is 45, stroke is 8.
    // So radius is 45% of width.
    final radius = size.width * 0.45;
    final strokeWidth = size.width * 0.08;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Circumference = 2 * pi * 45 ~ 282.7
    // stroke-dasharray="210 70"
    // 210 / 282.7 = 0.7427 of a circle
    // arc angle = 0.7427 * 2 * pi = 4.667 radians (approx 267.4 degrees)
    // By default, SVG circle starts at 0 (3 o'clock).

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, 0, 4.667, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _LogoPainter) {
      return color != oldDelegate.color;
    }
    return true;
  }
}

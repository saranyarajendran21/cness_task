import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// CNESS logo widget rendering the bundled logo asset with vector fallback.
class CnessLogo extends StatelessWidget {
  const CnessLogo({
    super.key,
    this.iconSize = 32,
    this.fontSize = 24,
    this.textColor = AppColors.white,
  });

  final double iconSize;
  final double fontSize;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/cness_logo.png',
      height: iconSize,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomPaint(
            size: Size(iconSize, iconSize),
            painter: _SunburstCPainter(rayColor: textColor),
          ),
          SizedBox(width: iconSize * 0.08),
          Text(
            'ness',
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SunburstCPainter extends CustomPainter {
  _SunburstCPainter({required this.rayColor});

  final Color rayColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rayPaint = Paint()
      ..color = rayColor
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round;

    // Draw sunburst rays around a C-shaped opening on the right.
    const rayCount = 14;
    for (int i = 0; i < rayCount; i++) {
      final angle = (2 * math.pi * i) / rayCount;
      // Leave a subtle opening near 0 radians (right side) for the 'C' silhouette.
      if (angle < 0.42 || angle > (2 * math.pi - 0.42)) continue;
      final inner = Offset(
        center.dx + math.cos(angle) * radius * 0.48,
        center.dy + math.sin(angle) * radius * 0.48,
      );
      final outer = Offset(
        center.dx + math.cos(angle) * radius * 0.92,
        center.dy + math.sin(angle) * radius * 0.92,
      );
      canvas.drawLine(inner, outer, rayPaint);
    }

    // Inner C ring
    final arcPaint = Paint()
      ..color = rayColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.075
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.36),
      0.55,
      2 * math.pi - 1.1,
      false,
      arcPaint,
    );

    // Center amber dot
    final dotPaint = Paint()..color = AppColors.logoAmber;
    canvas.drawCircle(center, radius * 0.17, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SunburstCPainter oldDelegate) =>
      oldDelegate.rayColor != rayColor;
}

/// Crisp multi-color Google "G" badge for social login button.
class GoogleGIcon extends StatelessWidget {
  const GoogleGIcon({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleGPainter(),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.19;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    Paint arcPaint(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, -0.35, -1.65, false, arcPaint(const Color(0xFFEA4335)));
    canvas.drawArc(rect, -2.0, -1.5, false, arcPaint(const Color(0xFFFBBC05)));
    canvas.drawArc(rect, 2.78, -1.6, false, arcPaint(const Color(0xFF34A853)));
    canvas.drawArc(rect, 1.18, -1.25, false, arcPaint(const Color(0xFF4285F4)));

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.5),
      Offset(size.width * 0.94, size.height * 0.5),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

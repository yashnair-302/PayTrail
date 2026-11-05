import 'package:flutter/material.dart';

/// The PayTrail brand mark, drawn to match the launcher icon exactly.
///
/// A coin ring with the rupee sign over the app's "PT" initials — a payments
/// app for Indian freelancers. It is painted rather than shipped as a bitmap so
/// it stays crisp at any size and in both themes, and so there is a single
/// source of truth for the geometry shared with the Android adaptive icon (same
/// normalised proportions). Pass [rounded] = false for the coin alone with no
/// tile behind it.
class AppLogo extends StatelessWidget {
  const AppLogo({this.size = 32, this.rounded = true, super.key});

  final double size;

  /// Whether to draw the gradient tile behind the coin (the full app icon) or
  /// the white coin alone (for use on an already-coloured surface).
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _LogoPainter(withTile: rounded)),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter({required this.withTile});

  final bool withTile;

  // Coin geometry, normalised to the coin diameter D — identical to the values
  // the icon generator uses, so the widget and launcher icon never drift.
  static const double _ringStroke = 0.075; // ring width / D
  static const double _rupeeSize = 0.46; // glyph height / D
  static const double _rupeeDy = -0.135; // rupee centre offset / D
  static const double _ptSize = 0.30;
  static const double _ptDy = 0.185;
  static const double _coinFracTile = 0.78; // coin diameter / tile side

  static const Color _top = Color(0xFF2E9076);
  static const Color _bottom = Color(0xFF124E42);
  static const Color _white = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.shortestSide;
    final Rect tile = Offset.zero & Size(s, s);

    if (withTile) {
      final RRect rr =
          RRect.fromRectAndRadius(tile, Radius.circular(0.22 * s));
      canvas.save();
      canvas.clipRRect(rr);
      canvas.drawRect(
        tile,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[_top, _bottom],
          ).createShader(tile),
      );
      _drawCoin(canvas, Offset(s / 2, s / 2), _coinFracTile * s, _white);
      canvas.restore();
    } else {
      // No tile: the coin fills the box.
      _drawCoin(canvas, Offset(s / 2, s / 2), s, _white);
    }
  }

  void _drawCoin(Canvas canvas, Offset center, double diameter, Color color) {
    final double d = diameter;
    canvas.drawCircle(
      center,
      d / 2 - _ringStroke * d / 2,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringStroke * d,
    );
    _text(canvas, '₹', _rupeeSize * d, FontWeight.w900, color,
        center.translate(0, _rupeeDy * d));
    _text(canvas, 'PT', _ptSize * d, FontWeight.w900, color,
        center.translate(0, _ptDy * d));
  }

  void _text(Canvas canvas, String s, double fontSize, FontWeight weight,
      Color color, Offset center) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) =>
      oldDelegate.withTile != withTile;
}

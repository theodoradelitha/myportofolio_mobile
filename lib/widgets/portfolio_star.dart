import 'package:material_ui/material_ui.dart';

/// The star decoration used across my portfolio website
/// (`static/img/projects-star.svg`), drawn with a CustomPainter so the app
/// does not need an SVG package.
class PortfolioStar extends StatelessWidget {
  final double size;
  final Color? color;

  /// Rotation in radians.
  final double angle;

  /// Mirrors the star horizontally, like `transform: scaleX(-1)` on the site.
  final bool flipped;

  const PortfolioStar({
    super.key,
    this.size = 32.0,
    this.color,
    this.angle = 0.0,
    this.flipped = false,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Theme.of(context).colorScheme.primary;

    return ExcludeSemantics(
      child: Transform.rotate(
        angle: angle,
        child: Transform.flip(
          flipX: flipped,
          child: CustomPaint(
            size: Size(
              size,
              size * _StarPainter.viewBoxHeight / _StarPainter.viewBoxWidth,
            ),
            painter: _StarPainter(starColor),
          ),
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  static const double viewBoxWidth = 88.0;
  static const double viewBoxHeight = 76.0;

  // Points of the path in projects-star.svg (88 x 76 view box).
  static const List<Offset> _points = [
    Offset(36.44, 0.0),
    Offset(34.40, 28.48),
    Offset(0.0, 37.33),
    Offset(33.02, 47.67),
    Offset(31.00, 75.74),
    Offset(51.55, 53.48),
    Offset(81.32, 62.80),
    Offset(64.58, 39.38),
    Offset(87.16, 14.92),
    Offset(53.32, 23.62),
  ];

  final Color color;

  const _StarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / viewBoxWidth;
    final scaleY = size.height / viewBoxHeight;
    final path = Path()
      ..addPolygon(
        _points.map((p) => Offset(p.dx * scaleX, p.dy * scaleY)).toList(),
        true,
      );

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) => oldDelegate.color != color;
}

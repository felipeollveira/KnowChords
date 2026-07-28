import 'package:flutter/material.dart';
import '../data/chord_shapes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ChordDiagram widget
// ─────────────────────────────────────────────────────────────────────────────

class ChordDiagram extends StatelessWidget {
  final String chordName;
  final double size;

  const ChordDiagram({super.key, required this.chordName, this.size = 1.0});

  @override
  Widget build(BuildContext context) {
    final shape = kChordShapes[chordName];
    if (shape == null) return const SizedBox.shrink();

    const double baseWidth = 130;
    const double baseHeight = 150;

    return SizedBox(
      width: baseWidth * size,
      height: baseHeight * size,
      child: CustomPaint(
        painter: _ChordPainter(shape: shape, size: size),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter
// ─────────────────────────────────────────────────────────────────────────────

class _ChordPainter extends CustomPainter {
  final ChordShape shape;
  final double size;

  // Base layout constants (unscaled)
  static const double _topPad = 28;
  static const double _leftPad = 22;
  static const double _rightPad = 6;
  static const double _bottomPad = 6;
  static const double _baseWidth = 130;
  static const double _baseHeight = 150;
  static const int _numStrings = 6;
  static const int _numFrets = 4;

  static const double _stringSpacing =
      (_baseWidth - _leftPad - _rightPad) / (_numStrings - 1); // ≈ 20.4
  static const double _fretSpacing =
      (_baseHeight - _topPad - _bottomPad) / _numFrets; // = 29

  const _ChordPainter({required this.shape, required this.size});

  // x position of string s (0 = low E, 5 = high e), scaled
  double sx(int s) => ((_leftPad + s * _stringSpacing)) * size;

  // y position of fret line f (0 = top/nut line), scaled
  double fy(int f) => ((_topPad + f * _fretSpacing)) * size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final double ss = _stringSpacing * size; // scaled string spacing
    final double fs = _fretSpacing * size; // scaled fret spacing

    // ── 1. Nut / top line ───────────────────────────────────────────────────
    final nutPaint = Paint()
      ..color = const Color(0xFF0F1D2E)
      ..strokeWidth = (shape.baseFret == 1 ? 3.5 : 1.0) * size
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(
      Offset(sx(0), fy(0)),
      Offset(sx(_numStrings - 1), fy(0)),
      nutPaint,
    );

    // ── 2. Fret lines (below the nut) ───────────────────────────────────────
    final fretPaint = Paint()
      ..color = const Color(0xFFCBD5E0)
      ..strokeWidth = 1.0 * size;

    for (int f = 1; f <= _numFrets; f++) {
      canvas.drawLine(
        Offset(sx(0), fy(f)),
        Offset(sx(_numStrings - 1), fy(f)),
        fretPaint,
      );
    }

    // ── 3. String lines ──────────────────────────────────────────────────────
    final stringPaint = Paint()
      ..color = const Color(0xFFCBD5E0)
      ..strokeWidth = 0.8 * size;

    for (int s = 0; s < _numStrings; s++) {
      canvas.drawLine(
        Offset(sx(s), fy(0)),
        Offset(sx(s), fy(_numFrets)),
        stringPaint,
      );
    }

    // ── 4. Fret number label ─────────────────────────────────────────────────
    if (shape.baseFret > 1) {
      final tp = TextPainter(
        text: TextSpan(
          text: '${shape.baseFret}fr',
          style: TextStyle(
            fontSize: 10 * size,
            color: const Color(0xFF0F1D2E),
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(2 * size, fy(0) - tp.height / 2));
    }

    // ── 5. String markers above nut (muted × / open ○) ───────────────────────
    for (int s = 0; s < _numStrings; s++) {
      final fret = shape.frets[s];
      if (fret == -1) {
        // Muted: draw ×
        final tp = TextPainter(
          text: TextSpan(
            text: '×',
            style: TextStyle(
              fontSize: 13 * size,
              color: const Color(0xFF94A3B8),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(sx(s) - tp.width / 2, fy(0) - tp.height - 2 * size),
        );
      } else if (fret == 0) {
        // Open: draw circle
        final openPaint = Paint()
          ..color = const Color(0xFF334155)
          ..strokeWidth = 1.5 * size
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(
          Offset(sx(s), fy(0) - 12 * size),
          5 * size,
          openPaint,
        );
      }
    }

    // ── 6. Barre ─────────────────────────────────────────────────────────────
    if (shape.barreString != null) {
      final int bs = shape.barreString!;

      // Find the last non-muted string at baseFret
      int lastString = bs;
      for (int s = _numStrings - 1; s >= bs; s--) {
        if (shape.frets[s] != -1) {
          lastString = s;
          break;
        }
      }

      final double barreY = fy(0) + fs / 2;
      final double barreHeight = ss * 0.55;
      final double barreRadius = ss * 0.28;

      final barrePaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          sx(bs) - barreHeight / 2,
          barreY - barreHeight / 2,
          sx(lastString) + barreHeight / 2,
          barreY + barreHeight / 2,
        ),
        Radius.circular(barreRadius),
      );
      canvas.drawRRect(rrect, barrePaint);
    }

    // ── 7. Individual finger dots ─────────────────────────────────────────────
    final dotPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final double dotRadius = ss * 0.32;

    for (int s = 0; s < _numStrings; s++) {
      final int fret = shape.frets[s];
      if (fret <= 0) continue; // muted or open: no dot

      final int row = fret - shape.baseFret + 1;
      if (row < 1 || row > _numFrets) continue;

      // Skip if this string is covered by the barre at row 1
      if (shape.barreString != null && row == 1 && s >= shape.barreString!) {
        continue;
      }

      canvas.drawCircle(
        Offset(sx(s), fy(row - 1) + fs / 2),
        dotRadius,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ChordPainter old) =>
      old.shape != shape || old.size != size;
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet helper
// ─────────────────────────────────────────────────────────────────────────────

void showChordDiagram(BuildContext context, String chordName) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Chord name
          Text(
            chordName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F1D2E),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),

          // Diagram (centered)
          ChordDiagram(chordName: chordName, size: 1.4),
          const SizedBox(height: 4),

          // String name labels aligned to string positions
          _StringLabels(size: 1.4),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// String labels row (E A D G B e) aligned to diagram string positions
// ─────────────────────────────────────────────────────────────────────────────

class _StringLabels extends StatelessWidget {
  final double size;

  const _StringLabels({this.size = 1.0});

  @override
  Widget build(BuildContext context) {
    // Mirror the CustomPainter layout so labels sit under each string column.
    const double leftPad = 22;
    const double rightPad = 6;
    const double baseWidth = 130;
    const double stringSpacing = (baseWidth - leftPad - rightPad) / 5;

    final double scaledWidth = baseWidth * size;
    final double scaledLeftPad = leftPad * size;
    final double scaledStringSpacing = stringSpacing * size;

    const List<String> names = ['E', 'A', 'D', 'G', 'B', 'e'];

    return SizedBox(
      width: scaledWidth,
      height: 18 * size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int s = 0; s < 6; s++)
            Positioned(
              left: scaledLeftPad + s * scaledStringSpacing,
              child: Transform.translate(
                offset: Offset(-9 * size, 0),
                child: SizedBox(
                  width: 18 * size,
                  child: Center(
                    child: Text(
                      names[s],
                      style: TextStyle(
                        fontSize: 11 * size,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../models/chord_voicing.dart';

/// Draws a simple 6-string fretboard diagram for one chord voicing —
/// an open circle/X above a muted or open string, a filled dot on the
/// fretted position.
class ChordDiagram extends StatelessWidget {
  final ChordVoicing voicing;

  const ChordDiagram({super.key, required this.voicing});

  @override
  Widget build(BuildContext context) {
    final frets = voicing.fretsPerString; // low string (6th) to high (1st)
    final playedFrets = frets.whereType<int>().where((f) => f > 0);
    final minFret = playedFrets.isEmpty ? 1 : playedFrets.reduce((a, b) => a < b ? a : b);
    final maxFret = playedFrets.isEmpty ? 1 : playedFrets.reduce((a, b) => a > b ? a : b);
    // Show a 4-fret window, starting at the lowest fretted position (or 1).
    final startFret = maxFret <= 4 ? 1 : minFret;

    return SizedBox(
      width: 160,
      height: 190,
      child: CustomPaint(
        painter: _ChordDiagramPainter(
          frets: frets,
          startFret: startFret,
          isDark: AppColors.isDark,
        ),
      ),
    );
  }
}

class _ChordDiagramPainter extends CustomPainter {
  final List<int?> frets; // 6 entries, low to high string, null = muted
  final int startFret;
  final bool isDark;

  _ChordDiagramPainter({required this.frets, required this.startFret, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    const stringCount = 6;
    const fretCount = 4;
    final gridLeft = 20.0;
    final gridTop = 30.0;
    final gridWidth = size.width - 40;
    final gridHeight = size.height - 60;
    final stringSpacing = gridWidth / (stringCount - 1);
    final fretSpacing = gridHeight / fretCount;

    final lineColor = isDark ? Colors.white54 : Colors.black45;
    final dotColor = AppColors.accentPrimary;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2;

    // Strings (vertical lines)
    for (int s = 0; s < stringCount; s++) {
      final x = gridLeft + s * stringSpacing;
      canvas.drawLine(Offset(x, gridTop), Offset(x, gridTop + gridHeight), linePaint);
    }

    // Frets (horizontal lines) — top one thicker if starting at fret 1 (the nut)
    for (int f = 0; f <= fretCount; f++) {
      final y = gridTop + f * fretSpacing;
      final isNut = f == 0 && startFret == 1;
      canvas.drawLine(
        Offset(gridLeft, y),
        Offset(gridLeft + gridWidth, y),
        isNut ? (Paint()..color = lineColor..strokeWidth = 3) : linePaint,
      );
    }

    // Starting fret label, if not showing from the nut
    if (startFret > 1) {
      final tp = TextPainter(
        text: TextSpan(text: '${startFret}fr', style: TextStyle(color: textColor, fontSize: 11)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(gridLeft + gridWidth + 6, gridTop - 2));
    }

    // Per-string markers above the grid (X = muted, O = open) and dots
    // on fretted positions.
    for (int s = 0; s < stringCount; s++) {
      final x = gridLeft + s * stringSpacing;
      final fret = frets.length > s ? frets[s] : null;

      if (fret == null) {
        _drawX(canvas, Offset(x, gridTop - 14), lineColor);
      } else if (fret == 0) {
        _drawO(canvas, Offset(x, gridTop - 14), lineColor);
      } else {
        final relativeFret = fret - startFret + 1;
        if (relativeFret >= 1 && relativeFret <= fretCount) {
          final y = gridTop + (relativeFret - 0.5) * fretSpacing;
          canvas.drawCircle(Offset(x, y), 9, Paint()..color = dotColor);
        }
      }
    }
  }

  void _drawX(Canvas canvas, Offset center, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    const r = 4.0;
    canvas.drawLine(center + const Offset(-r, -r), center + const Offset(r, r), paint);
    canvas.drawLine(center + const Offset(-r, r), center + const Offset(r, -r), paint);
  }

  void _drawO(Canvas canvas, Offset center, Color color) {
    canvas.drawCircle(center, 5, Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant _ChordDiagramPainter oldDelegate) {
    return oldDelegate.frets != frets || oldDelegate.startFret != startFret || oldDelegate.isDark != isDark;
  }
}

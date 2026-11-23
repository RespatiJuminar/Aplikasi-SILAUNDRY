import 'dart:math';

import 'package:flutter/material.dart';

import '../../shared/data/models.dart';
import '../../shared/theme.dart';

// ---------------------------------------------------------------------------
// Grafik untuk dashboard laporan admin: bar chart, line chart, dan pie chart.
// Digambar sendiri dengan CustomPaint (Canvas), tanpa package tambahan.
// Data masuk berupa daftar ReportPoint(label, value).
// ---------------------------------------------------------------------------

/// Warna batang pada bar chart (bergantian).
const List<Color> chartPalette = [
  Color(0xFF1877F2),
  Color(0xFF4FB8E8),
  Color(0xFFF59E0B),
  Color(0xFF16A34A),
  Color(0xFFF5136B),
];

/// Angka ringkas untuk label sumbu: 168000 menjadi "168 rb", 1200000 menjadi "1,2 jt".
String compactNumber(double v) {
  if (v >= 1000000) {
    final x = v / 1000000;
    final text = x == x.roundToDouble() ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
    return '${text.replaceAll('.', ',')} jt';
  }
  if (v >= 1000) return '${(v / 1000).round()} rb';
  return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

/// Batas atas sumbu yang "rapi" (1, 2, 5, 10 dikali pangkat 10).
double _niceMax(double v) {
  if (v <= 0) return 1;
  final exponent = pow(10, (log(v) / ln10).floor()).toDouble();
  final fraction = v / exponent;
  final nice = fraction <= 1
      ? 1.0
      : fraction <= 2
          ? 2.0
          : fraction <= 5
              ? 5.0
              : 10.0;
  return nice * exponent;
}

/// Batas atas sumbu untuk data cacah (jumlah order): kelipatan 4 supaya
/// garis bantu jatuh di bilangan bulat.
double _niceMaxCount(double v) => max(4.0, (v / 4).ceilToDouble() * 4);

enum _Anchor { center, right }

void _drawText(
  Canvas canvas,
  String text,
  Offset anchor, {
  double fontSize = 11,
  Color color = const Color(0xFF666666),
  FontWeight? weight,
  _Anchor align = _Anchor.center,
  double maxWidth = 90,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontSize: fontSize, color: color, fontWeight: weight),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: maxWidth);

  final offset = switch (align) {
    _Anchor.center => Offset(anchor.dx - painter.width / 2, anchor.dy),
    _Anchor.right => Offset(anchor.dx - painter.width, anchor.dy - painter.height / 2),
  };
  painter.paint(canvas, offset);
}

class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Belum ada data', style: TextStyle(color: AppColors.muted)),
    );
  }
}

// ============================ BAR CHART ====================================

/// Bar chart: membandingkan nilai antar kategori (contoh: antar layanan).
class ReportBarChart extends StatelessWidget {
  const ReportBarChart({
    super.key,
    required this.data,
    this.height = 240,
    this.valueLabel = compactNumber,
  });

  final List<ReportPoint> data;
  final double height;
  final String Function(double) valueLabel;

  @override
  Widget build(BuildContext context) {
    final empty = data.isEmpty || data.every((p) => p.value <= 0);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: empty
          ? const _NoData()
          : CustomPaint(painter: _BarPainter(data, valueLabel)),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.data, this.valueLabel);

  final List<ReportPoint> data;
  final String Function(double) valueLabel;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 48.0, right = 8.0, top = 22.0, bottom = 34.0;
    final area = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    final maxValue = _niceMax(data.map((p) => p.value).reduce(max));

    // Garis bantu dan angka di sumbu Y.
    final grid = Paint()
      ..color = const Color(0xFFE2E2E2)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = area.bottom - area.height * i / 4;
      canvas.drawLine(Offset(area.left, y), Offset(area.right, y), grid);
      _drawText(
        canvas,
        valueLabel(maxValue * i / 4),
        Offset(area.left - 6, y),
        align: _Anchor.right,
        maxWidth: left - 8,
      );
    }

    // Batang, nilai di atas batang, dan nama kategori di bawah.
    final slot = area.width / data.length;
    final barWidth = min(slot * 0.55, 64.0);
    for (var i = 0; i < data.length; i++) {
      final point = data[i];
      final barHeight = area.height * (point.value / maxValue);
      final x = area.left + slot * i + (slot - barWidth) / 2;
      final rect = Rect.fromLTWH(x, area.bottom - barHeight, barWidth, barHeight);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        ),
        Paint()..color = chartPalette[i % chartPalette.length],
      );
      _drawText(
        canvas,
        valueLabel(point.value),
        Offset(x + barWidth / 2, area.bottom - barHeight - 16),
        weight: FontWeight.w600,
        color: Colors.black87,
        maxWidth: slot,
      );
      _drawText(
        canvas,
        point.label,
        Offset(area.left + slot * i + slot / 2, area.bottom + 8),
        maxWidth: slot - 4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) => true;
}

// ============================ LINE CHART ===================================

/// Line chart: perubahan nilai dari waktu ke waktu (contoh: order per minggu).
class ReportLineChart extends StatelessWidget {
  const ReportLineChart({super.key, required this.data, this.height = 240});

  final List<ReportPoint> data;
  final double height;

  @override
  Widget build(BuildContext context) {
    final empty = data.isEmpty || data.every((p) => p.value <= 0);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: empty ? const _NoData() : CustomPaint(painter: _LinePainter(data)),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.data);

  final List<ReportPoint> data;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 36.0, right = 16.0, top = 22.0, bottom = 34.0;
    final area = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    final maxValue = _niceMaxCount(data.map((p) => p.value).reduce(max));

    final grid = Paint()
      ..color = const Color(0xFFE2E2E2)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = area.bottom - area.height * i / 4;
      canvas.drawLine(Offset(area.left, y), Offset(area.right, y), grid);
      _drawText(
        canvas,
        (maxValue * i / 4).round().toString(),
        Offset(area.left - 6, y),
        align: _Anchor.right,
        maxWidth: left - 8,
      );
    }

    // Posisi tiap titik: tersebar rata di sumbu X.
    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? area.center.dx
          : area.left + area.width * i / (data.length - 1);
      final y = area.bottom - area.height * (data[i].value / maxValue);
      points.add(Offset(x, y));
    }

    // Area samar di bawah garis.
    final fill = Path()..moveTo(points.first.dx, area.bottom);
    for (final p in points) {
      fill.lineTo(p.dx, p.dy);
    }
    fill
      ..lineTo(points.last.dx, area.bottom)
      ..close();
    canvas.drawPath(fill, Paint()..color = AppColors.primary.withAlpha(30));

    // Garis.
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    // Titik, nilai di atas titik, dan label minggu di bawah.
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5, Paint()..color = AppColors.primary);
      canvas.drawCircle(points[i], 2.2, Paint()..color = Colors.white);
      _drawText(
        canvas,
        data[i].value.round().toString(),
        Offset(points[i].dx, points[i].dy - 20),
        weight: FontWeight.w600,
        color: Colors.black87,
      );
      _drawText(canvas, data[i].label, Offset(points[i].dx, area.bottom + 8), maxWidth: 48);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) => true;
}

// ============================= PIE CHART ===================================

/// Pie (donat) chart: komposisi bagian terhadap keseluruhan (contoh: status order).
class ReportPieChart extends StatelessWidget {
  const ReportPieChart({
    super.key,
    required this.data,
    required this.colors,
    this.height = 240,
  });

  final List<ReportPoint> data;
  final List<Color> colors;
  final double height;

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (sum, p) => sum + p.value);
    if (total <= 0) {
      return SizedBox(height: height, child: const _NoData());
    }
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(painter: _PiePainter(data, colors, total)),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < data.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${data[i].label}: ${data[i].value.round()} '
                    '(${(data[i].value / total * 100).round()}%)',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter(this.data, this.colors, this.total);

  final List<ReportPoint> data;
  final List<Color> colors;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    var start = -pi / 2; // mulai dari atas
    for (var i = 0; i < data.length; i++) {
      final value = data[i].value;
      if (value <= 0) continue;
      final sweep = 2 * pi * value / total;
      canvas.drawArc(rect, start, sweep, true, Paint()..color = colors[i % colors.length]);
      // Garis putih pemisah antar irisan.
      canvas.drawArc(
        rect,
        start,
        sweep,
        true,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      start += sweep;
    }

    // Lubang di tengah (donat) berisi jumlah total.
    canvas.drawCircle(center, radius * 0.55, Paint()..color = Colors.white);
    _drawText(
      canvas,
      total.round().toString(),
      center.translate(0, -14),
      fontSize: 24,
      weight: FontWeight.w600,
      color: Colors.black87,
      maxWidth: radius,
    );
    _drawText(canvas, 'order', center.translate(0, 12), maxWidth: radius);
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) => true;
}

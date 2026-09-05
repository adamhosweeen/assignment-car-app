import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

const int _size = 1024;
const Color _black = Color(0xFF000000);
const Color _white = Color(0xFFFFFFFF);
const Color _clear = Color(0x00000000);

Future<void> _render(String dir, String name, Color background) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final s = _size.toDouble();
  canvas.drawRect(Rect.fromLTWH(0, 0, s, s), Paint()..color = background);

  final glyph = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(Icons.directions_car_filled.codePoint),
      style: TextStyle(
        fontFamily: Icons.directions_car_filled.fontFamily,
        package: Icons.directions_car_filled.fontPackage,
        fontSize: s * 0.46,
        color: _white,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  final word = TextPainter(
    text: TextSpan(
      text: 'CarSell',
      style: GoogleFonts.inter(
        fontSize: s * 0.15,
        fontWeight: FontWeight.w700,
        color: _white,
        letterSpacing: -2,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  final gap = s * 0.02;
  final total = glyph.height + gap + word.height;
  var y = (s - total) / 2;
  glyph.paint(canvas, Offset((s - glyph.width) / 2, y));
  y += glyph.height + gap;
  word.paint(canvas, Offset((s - word.width) / 2, y));

  final image = await recorder.endRecording().toImage(_size, _size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File('$dir/$name').writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders the CarSell launcher icon sources', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Text('CarSell', style: GoogleFonts.inter()),
        ),
      ),
    );
    await tester.runAsync(() async {
      await GoogleFonts.pendingFonts();
      await Future<void>.delayed(const Duration(seconds: 2));
      final dir = (await getExternalStorageDirectory())!.path;
      await _render(dir, 'icon.png', _black);
      await _render(dir, 'icon_foreground.png', _clear);
      // ignore: avoid_print
      print('ICON_DIR=$dir');
      expect(File('$dir/icon.png').lengthSync(), greaterThan(20000));
    });
  });
}

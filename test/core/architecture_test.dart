import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib/core never imports Flutter or other app layers', () {
    final forbidden = RegExp(
      r'''import\s+['"](package:flutter|dart:ui|package:tengri_taslari/(ui|data|services)|\.\./(ui|data|services))''',
    );
    final offenders = <String>[];
    for (final f in Directory('lib/core').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (forbidden.hasMatch(f.readAsStringSync())) offenders.add(f.path);
    }
    expect(offenders, isEmpty);
  });
}

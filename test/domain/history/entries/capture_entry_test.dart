import 'package:abyss/domain/history/history_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/history_entry_samples.dart';

void main() {
  group('CaptureEntry.isVolcanicKernel', () {
    test('recognizes the kernel capture', () {
      final entry = captureEntry(CaptureEntry.volcanicKernel);
      expect(entry.isVolcanicKernel, isTrue);
    });

    test('recognizes the kernel capture of older saves', () {
      expect(captureEntry('Noyau Volcanique').isVolcanicKernel, isTrue);
    });

    test('leaves transition bases out', () {
      expect(captureEntry('Faille Alpha').isVolcanicKernel, isFalse);
    });
  });
}

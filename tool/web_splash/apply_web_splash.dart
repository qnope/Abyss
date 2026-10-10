// Usage, from the repository root after `flutter create . --platforms=web`:
//   dart run tool/web_splash/apply_web_splash.dart
import 'dart:io';

import 'web_splash.dart';

void main() {
  final index = File('web/index.html');
  if (!index.existsSync()) {
    stderr.writeln('web/index.html not found: run flutter create first.');
    exit(1);
  }
  final updated = applySplash(
    index.readAsStringSync(),
    css: File('tool/web_splash/splash.css').readAsStringSync(),
    markup: File('tool/web_splash/splash.html').readAsStringSync(),
  );
  index.writeAsStringSync(updated);
  stdout.writeln('Web splash applied to ${index.path}.');
}

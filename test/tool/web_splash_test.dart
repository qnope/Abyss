import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/web_splash/web_splash.dart';

const _index = '''<!DOCTYPE html>
<html>
<head>
  <title>abyss</title>
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
''';

String _apply(String html) =>
    applySplash(html, css: 'body{}', markup: '<p>x</p>');

int _count(String text, String part) => part.allMatches(text).length;

void main() {
  test('puts the style in the head and the markup at the top of the body', () {
    final html = _apply(_index);
    expect(html.indexOf('<style>'), lessThan(html.indexOf('</head>')));
    expect(html.indexOf('<p>x</p>'), greaterThan(html.indexOf('<body>')));
    expect(
      html.indexOf('<p>x</p>'),
      lessThan(html.indexOf('flutter_bootstrap.js')),
    );
  });

  test('running it twice injects the splash once', () {
    final once = _apply(_index);
    final twice = _apply(once);
    expect(twice, once);
    expect(_count(twice, cssStart), 1);
    expect(_count(twice, bodyStart), 1);
  });

  test('removing the splash restores the generated page', () {
    expect(removeSplash(_apply(_index)), _index);
  });

  test('rejects a page without head and body', () {
    expect(() => _apply('<html></html>'), throwsFormatException);
  });

  test('the versioned splash hides itself on the first Flutter frame', () {
    final markup = File('tool/web_splash/splash.html').readAsStringSync();
    final css = File('tool/web_splash/splash.css').readAsStringSync();
    expect(markup, contains("addEventListener('flutter-first-frame'"));
    expect(markup, contains('id="abyss-splash"'));
    expect(css, contains('prefers-reduced-motion'));
    expect(css, isNot(contains('http')));
  });
}

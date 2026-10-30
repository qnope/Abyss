import 'dart:ui';

/// The trident of the army's crest, upright, centred on the origin, in
/// the mockup's units (about 34 wide and 52 tall): a shaft with its head
/// and two curved side prongs.
Path armyTrident() => Path()
  // The shaft and its middle prong.
  ..moveTo(0, -30)
  ..lineTo(4, -20)
  ..lineTo(1.6, -20)
  ..lineTo(1.6, 22)
  ..lineTo(-1.6, 22)
  ..lineTo(-1.6, -20)
  ..lineTo(-4, -20)
  ..close()
  // The left prong, curving into the shaft.
  ..moveTo(-14, -24)
  ..lineTo(-11, -14)
  ..lineTo(-12.3, -14)
  ..cubicTo(-12, -6, -7, -2, -1.6, -2)
  ..lineTo(-1.6, 1.5)
  ..cubicTo(-9, 1.5, -15.4, -4, -15.6, -14)
  ..lineTo(-17, -14)
  ..close()
  // The right prong, its mirror.
  ..moveTo(14, -24)
  ..lineTo(17, -14)
  ..lineTo(15.6, -14)
  ..cubicTo(15.4, -4, 9, 1.5, 1.6, 1.5)
  ..lineTo(1.6, -2)
  ..cubicTo(7, -2, 12, -6, 12.3, -14)
  ..lineTo(11, -14)
  ..close();

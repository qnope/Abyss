import 'guide_target.dart';

/// What the guide of the tutorial says, and what its halo surrounds.
class GuideAdvice {
  /// Shown in the guide's bubble, in French.
  final String text;

  final GuideTarget target;

  const GuideAdvice(this.text, this.target);

  @override
  bool operator ==(Object other) =>
      other is GuideAdvice && other.text == text && other.target == target;

  @override
  int get hashCode => Object.hash(text, target);

  @override
  String toString() => 'GuideAdvice($text, $target)';
}

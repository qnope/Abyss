import 'guide_message.dart';
import 'guide_target.dart';

/// What the guide of the tutorial says, and what its halo surrounds.
class GuideAdvice {
  final GuideMessage message;

  final GuideTarget target;

  const GuideAdvice(this.message, this.target);

  @override
  bool operator ==(Object other) =>
      other is GuideAdvice &&
      other.message == message &&
      other.target == target;

  @override
  int get hashCode => Object.hash(message, target);

  @override
  String toString() => 'GuideAdvice($message, $target)';
}

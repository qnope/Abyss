import '../vector_file.dart';
import 'math_doubles.dart';
import 'math_integers.dart';

/// The arithmetic of Dart the rules rely on: the port's `DartMath`.
abstract final class MathVectors {
  static final VectorFile file = VectorFile('dart_math', {
    ...MathIntegers.sections,
    ...MathDoubles.sections,
  });
}

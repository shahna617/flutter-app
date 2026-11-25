import 'dart:math' as math;

import 'embeddings_cache_service.dart';

/// A student and how far their face is from the photo's face.
/// A smaller distance means a closer match.
class FaceMatch {
  final StudentEmbedding student;
  final double distance;

  const FaceMatch({required this.student, required this.distance});
}

/// Compares a face embedding against the cached student embeddings.
///
/// Usage:
///   final matcher = FaceMatchService();
///   final match = matcher.findBestMatch(embedding, cache.students);
///   if (match == null) { /* no known student is close enough */ }
class FaceMatchService {
  /// Starting guess only. Tune it with real photos of your classmates.
  static const double defaultThreshold = 1.0;

  /// Scales a vector to length 1, so distances do not depend on its size.
  static List<double> normalize(List<double> v) {
    var sum = 0.0;
    for (final x in v) {
      sum += x * x;
    }
    final norm = math.sqrt(sum);
    if (norm == 0) return List<double>.from(v);
    return v.map((x) => x / norm).toList();
  }

  /// Euclidean distance between two embeddings (both normalized first).
  static double distance(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Embeddings must have the same length.');
    }
    final na = normalize(a);
    final nb = normalize(b);
    var sum = 0.0;
    for (var i = 0; i < na.length; i++) {
      final d = na[i] - nb[i];
      sum += d * d;
    }
    return math.sqrt(sum);
  }

  /// The [count] closest students, closest first (no threshold applied).
  List<FaceMatch> topMatches(
    List<double> embedding,
    List<StudentEmbedding> students, {
    int count = 3,
  }) {
    final matches = students
        .map((s) => FaceMatch(
              student: s,
              distance: distance(embedding, s.embedding),
            ))
        .toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
    return matches.take(count).toList();
  }

  /// The closest student, or null if none is within [threshold].
  FaceMatch? findBestMatch(
    List<double> embedding,
    List<StudentEmbedding> students, {
    double threshold = defaultThreshold,
  }) {
    final best = topMatches(embedding, students, count: 1);
    if (best.isEmpty) return null;
    return best.first.distance <= threshold ? best.first : null;
  }
}
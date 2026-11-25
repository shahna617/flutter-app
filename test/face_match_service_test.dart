import 'package:flutter_test/flutter_test.dart';
import 'package:guardly_app/services/embeddings_cache_service.dart';
import 'package:guardly_app/services/face_match_service.dart';

StudentEmbedding student(int id, List<double> v) => StudentEmbedding(
      id: id,
      name: 'Student',
      registerNumber: 'R',
      embedding: v,
    );

void main() {
  final matcher = FaceMatchService();

  test('same embedding has distance 0', () {
    expect(FaceMatchService.distance([1, 2, 3], [1, 2, 3]), closeTo(0, 1e-9));
  });

  test('different directions have a larger distance', () {
    expect(FaceMatchService.distance([1, 0], [0, 1]), closeTo(1.4142, 1e-3));
  });

  test('size of the vector does not change the distance', () {
    expect(FaceMatchService.distance([1, 0], [10, 0]), closeTo(0, 1e-9));
  });

  test('finds the closest student', () {
    final students = [student(1, [1, 0]), student(2, [0, 1])];
    final match = matcher.findBestMatch([0.1, 1], students);
    expect(match!.student.id, 2);
  });

  test('returns null when nobody is close enough', () {
    final students = [student(1, [1, 0])];
    expect(matcher.findBestMatch([0, 1], students, threshold: 0.5), isNull);
  });

  test('returns null for an empty list', () {
    expect(matcher.findBestMatch([1, 0], []), isNull);
  });

  test('top matches are sorted closest first', () {
    final students = [student(1, [0, 1]), student(2, [1, 0.1]), student(3, [1, 1])];
    final top = matcher.topMatches([1, 0], students, count: 2);
    expect(top.map((m) => m.student.id).toList(), [2, 3]);
  });

  test('different lengths throw', () {
    expect(() => FaceMatchService.distance([1, 2], [1, 2, 3]), throwsArgumentError);
  });
}
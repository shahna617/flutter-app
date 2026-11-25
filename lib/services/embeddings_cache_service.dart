import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/auth/auth_service.dart';
import 'face_recognition_service.dart';

/// One registered student's face, as sent by the server.
class StudentEmbedding {
  final int id;
  final String name;
  final String registerNumber;
  final List<double> embedding;

  const StudentEmbedding({
    required this.id,
    required this.name,
    required this.registerNumber,
    required this.embedding,
  });
}

/// Downloads all registered face embeddings once and keeps them in memory,
/// so matching works without calling the server for every photo.
///
/// The server only allows admin and management accounts.
///
/// Usage (after login):
///   final cache = EmbeddingsCacheService();
///   await cache.fetchAndCache(session.token!);
///   final students = cache.students;
class EmbeddingsCacheService {
  EmbeddingsCacheService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  List<StudentEmbedding> _students = const [];
  bool _loaded = false;

  /// The cached students (empty until fetchAndCache succeeds).
  List<StudentEmbedding> get students => _students;

  bool get isLoaded => _loaded;

  /// Fetches every registered face from the server and caches it.
  /// Throws [AuthException] with a message safe to show.
  Future<List<StudentEmbedding>> fetchAndCache(String token) async {
    final http.Response response;
    try {
      response = await _client.get(
        Uri.parse('${AuthService.baseUrl}/api/students/embeddings/'),
        headers: {'Authorization': 'Token $token'},
      ).timeout(const Duration(seconds: 60));
    } on TimeoutException {
      throw const AuthException('The server took too long to respond.');
    } catch (_) {
      throw const AuthException('Cannot reach the server. Check your internet.');
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AuthException('You do not have access to student face data.');
    }
    if (response.statusCode != 200) {
      throw AuthException('Server error (${response.statusCode}).');
    }

    final List<dynamic> data;
    try {
      data = jsonDecode(response.body) as List<dynamic>;
    } catch (_) {
      throw const AuthException('Unexpected response from the server.');
    }

    final students = <StudentEmbedding>[];
    for (final item in data) {
      final map = item as Map<String, dynamic>;
      final numbers = (map['face_embedding'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList();
      // Skip anything that is not a full 192-number embedding.
      if (numbers.length != FaceRecognitionService.embeddingSize) continue;
      students.add(StudentEmbedding(
        id: map['id'] as int,
        name: map['name'] as String,
        registerNumber: map['register_number'] as String,
        embedding: numbers,
      ));
    }

    _students = students;
    _loaded = true;
    return students;
  }

  /// Empties the cache (call on logout).
  void clear() {
    _students = const [];
    _loaded = false;
  }
}
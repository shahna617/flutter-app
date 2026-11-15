import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/auth/auth_service.dart';

/// Represents a single incident report created in the app or returned by the server.
/// All fields are final to make this object immutable and safe to share across screens.
class Incident {
  final int id;
  final String category;
  final String description;
  final String locationText;
  final String? imageUrl;
  final bool isAnonymous;
  final String status;
  final DateTime createdAt;

  const Incident({
    required this.id,
    required this.category,
    required this.description,
    required this.locationText,
    this.imageUrl,
    required this.isAnonymous,
    required this.status,
    required this.createdAt,
  });

  /// Creates an [Incident] instance from JSON received from the API.
  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: (json['id'] as num).toInt(),
      category: json['category'] as String,
      description: json['description'] as String,
      locationText: json['location_text'] as String,
      imageUrl: json['image_url'] as String?,
      isAnonymous: json['is_anonymous'] as bool,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// An error containing a friendly message that is safe to display to users.
class IncidentException implements Exception {
  final String message;

  const IncidentException(this.message);

  @override
  String toString() => message;
}

/// Communicates with the backend server to create and retrieve incident reports.
class IncidentService {
  IncidentService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// Submits a new incident report to the backend server.
  ///
  /// Sends a POST request with the incident details and user token.
  /// Returns the newly created [Incident] on HTTP 201.
  Future<Incident> createIncident({
    required String token,
    required String category,
    required String description,
    required String locationText,
    required bool isAnonymous,
    String? imageUrl,
  }) async {
    final body = <String, dynamic>{
      'category': category,
      'description': description,
      'location_text': locationText,
      'is_anonymous': isAnonymous,
    };
    if (imageUrl != null) {
      body['image_url'] = imageUrl;
    }

    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('${AuthService.baseUrl}/api/incidents/'),
            headers: {
              'Authorization': 'Token $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));
    } on TimeoutException {
      throw const IncidentException('The server took too long to respond.');
    } catch (_) {
      throw const IncidentException('Cannot reach the server. Check your internet.');
    }

    if (response.statusCode != 201) {
      _handleErrorResponse(response.statusCode);
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Incident.fromJson(data);
    } catch (_) {
      throw const IncidentException('Server error (unexpected response).');
    }
  }

  /// Fetches all incidents reported by the currently authenticated user.
  ///
  /// Handles both a plain JSON list and a paginated object with a "results" array.
  Future<List<Incident>> fetchMyIncidents({required String token}) async {
    final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse('${AuthService.baseUrl}/api/incidents/'),
            headers: {
              'Authorization': 'Token $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 60));
    } on TimeoutException {
      throw const IncidentException('The server took too long to respond.');
    } catch (_) {
      throw const IncidentException('Cannot reach the server. Check your internet.');
    }

    if (response.statusCode != 200) {
      _handleErrorResponse(response.statusCode);
    }

    try {
      final decoded = jsonDecode(response.body);
      final List<dynamic> items;
      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['results'] is List) {
        items = decoded['results'] as List<dynamic>;
      } else {
        items = const [];
      }

      return items
          .map((item) => Incident.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const IncidentException('Server error (unexpected response).');
    }
  }

  /// Maps HTTP error status codes to clear, friendly user error messages.
  Never _handleErrorResponse(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      throw const IncidentException('Your session has expired. Please log in again.');
    }
    if (statusCode == 429) {
      throw const IncidentException(
        'You have reached the limit of 10 reports per hour. Please try again later.',
      );
    }
    if (statusCode == 400) {
      throw const IncidentException('Please check the form and try again.');
    }
    throw IncidentException('Server error ($statusCode).');
  }
}

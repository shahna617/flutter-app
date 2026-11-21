import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  /// Uploads an image or media file for an incident report.
  ///
  /// Sends a multipart POST request with the file to the upload endpoint.
  /// Returns the uploaded file URL string on success (HTTP 201).
  Future<String> uploadMedia({
    required String token,
    required String filePath,
  }) async {
    // Check that the file exists before attempting to upload.
    final file = File(filePath);
    if (!await file.exists()) {
      throw const IncidentException('Could not read the selected file.');
    }

    // Limit file size to a maximum of 50 MB.
    final int fileSize;
    try {
      fileSize = await file.length();
    } catch (_) {
      throw const IncidentException('Could not read the selected file.');
    }
    if (fileSize > 50 * 1024 * 1024) {
      throw const IncidentException('File is too large (50 MB maximum).');
    }

    // Create the multipart file entry from the file path.
    final http.MultipartFile multipartFile;
    try {
      multipartFile = await http.MultipartFile.fromPath('file', filePath);
    } catch (_) {
      throw const IncidentException('Could not read the selected file.');
    }

    // Prepare and send the multipart request.
    final http.Response response;
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AuthService.baseUrl}/api/incidents/upload/'),
      );
      request.headers['Authorization'] = 'Token $token';
      request.files.add(multipartFile);

      // Uploads can be slow, so use a 180-second timeout.
      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: 180));
      response = await http.Response.fromStream(streamedResponse);
    } on TimeoutException {
      throw const IncidentException(
        'The upload took too long. Try a smaller file or a better connection.',
      );
    } catch (_) {
      throw const IncidentException(
        'Cannot reach the server. Check your internet.',
      );
    }

    // HTTP 201 Created indicates successful upload.
    if (response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['url'] is String) {
          return data['url'] as String;
        }
      } catch (_) {
        // Fall through to throw unexpected response exception.
      }
      throw const IncidentException('Server error (unexpected response).');
    }

    // Handle authentication and permission errors.
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const IncidentException('Your session has expired. Please log in again.');
    }

    // Handle bad request errors, preferring server's detail message if present.
    if (response.statusCode == 400) {
      try {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final detail = data['detail'];
          if (detail is String && detail.isNotEmpty) {
            throw IncidentException(detail);
          }
        }
      } on IncidentException {
        rethrow;
      } catch (_) {
        // Fall through to the default message.
      }
      throw const IncidentException('Please check the file and try again.');
    }

    // Handle bad gateway error.
    if (response.statusCode == 502) {
      throw const IncidentException('Upload failed. Please try again.');
    }

    // Handle any other unexpected HTTP status codes.
    throw IncidentException('Server error (${response.statusCode}).');
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

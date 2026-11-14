import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Finds faces in a photo using Google ML Kit. Runs fully on the phone.
///
/// Usage:
///   final service = FaceDetectionService();
///   final face = await service.detectLargestFace(photoPath);
///   if (face == null) { /* no face found */ }
///   service.dispose();
class FaceDetectionService {
  FaceDetectionService()
      : _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.1,
    ),
  );

  final FaceDetector _detector;

  /// Returns every face found in the photo (empty list if none).
  Future<List<Face>> detectFaces(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    return _detector.processImage(inputImage);
  }

  /// Returns the biggest face in the photo, or null if there is none.
  /// The biggest face is usually the main person in an incident photo.
  Future<Face?> detectLargestFace(String imagePath) async {
    final faces = await detectFaces(imagePath);
    if (faces.isEmpty) return null;

    Face largest = faces.first;
    double largestArea = _area(largest);
    for (final face in faces.skip(1)) {
      final area = _area(face);
      if (area > largestArea) {
        largest = face;
        largestArea = area;
      }
    }
    return largest;
  }

  double _area(Face face) =>
      face.boundingBox.width * face.boundingBox.height;

  /// Frees the detector. Call when you are done with the service.
  Future<void> dispose() => _detector.close();
}
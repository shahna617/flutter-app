import 'dart:io';
import 'dart:ui' show Rect;

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Turns a detected face into 192 numbers (a face embedding) on the phone.
///
/// Must use the same preprocessing as the Django side:
/// RGB order, 112x112, (pixel - 128) / 128.
///
/// Usage:
///   final service = FaceRecognitionService();
///   final embedding = await service.getEmbedding(photoPath, face.boundingBox);
///   service.dispose();
class FaceRecognitionService {
  static const String _modelAsset = 'assets/models/mobilefacenet.tflite';
  static const int inputSize = 112;
  static const int embeddingSize = 192;

  Interpreter? _interpreter;

  /// Loads the model once. Called automatically by getEmbedding.
  Future<void> load() async {
    _interpreter ??= await Interpreter.fromAsset(_modelAsset);
  }

  /// Crops the face from the photo and returns its 192 numbers.
  Future<List<double>> getEmbedding(String imagePath, Rect faceBox) async {
    await load();

    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Could not read the photo.');
    }
    // Apply the phone's rotation so the face box matches the pixels.
    final photo = img.bakeOrientation(decoded);

    final left = faceBox.left.floor().clamp(0, photo.width - 1).toInt();
    final top = faceBox.top.floor().clamp(0, photo.height - 1).toInt();
    final right = faceBox.right.ceil().clamp(left + 1, photo.width).toInt();
    final bottom = faceBox.bottom.ceil().clamp(top + 1, photo.height).toInt();

    final crop = img.copyCrop(
      photo,
      x: left,
      y: top,
      width: right - left,
      height: bottom - top,
    );
    final face = img.copyResize(crop, width: inputSize, height: inputSize);

    final input = [
      List.generate(
        inputSize,
        (row) => List.generate(inputSize, (col) {
          final p = face.getPixel(col, row);
          return [
            (p.r - 128) / 128,
            (p.g - 128) / 128,
            (p.b - 128) / 128,
          ];
        }),
      ),
    ];
    final output = [List<double>.filled(embeddingSize, 0.0)];

    _interpreter!.run(input, output);
    return List<double>.from(output[0]);
  }

  /// Frees the model. Call when you are done with the service.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
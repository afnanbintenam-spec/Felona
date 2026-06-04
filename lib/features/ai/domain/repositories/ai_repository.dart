import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/ai/domain/entities/scan_result.dart';

/// Repository interface for AI-powered features.
abstract class AiRepository {
  /// Uploads an image to the backend /ai/scan endpoint.
  /// Returns structured scan analysis and saves eco points to DB.
  Future<Either<Failure, ScanResult>> scanWaste(Uint8List imageBytes);

  /// Chat with the Gemini recycling assistant.
  /// [sessionMessages] is the prior history so the model has context.
  Future<Either<Failure, String>> chat(String message);

  /// Resets the local Gemini chat session.
  void resetChat();
}

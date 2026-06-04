import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/ai/domain/entities/scan_result.dart';
import 'package:felo_na/features/ai/domain/repositories/ai_repository.dart';

/// Scans an image via the backend AI endpoint and returns structured results.
class ScanWasteUseCase extends UseCase<ScanResult, ScanWasteParams> {
  final AiRepository repository;

  ScanWasteUseCase(this.repository);

  @override
  Future<Either<Failure, ScanResult>> call(ScanWasteParams params) =>
      repository.scanWaste(params.imageBytes);
}

class ScanWasteParams extends Equatable {
  final Uint8List imageBytes;

  const ScanWasteParams({required this.imageBytes});

  @override
  List<Object?> get props => [imageBytes];
}

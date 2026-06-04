import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/error_handler.dart';
import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/ai/data/datasources/ai_remote_data_source.dart';
import 'package:felo_na/features/ai/domain/entities/scan_result.dart';
import 'package:felo_na/features/ai/domain/repositories/ai_repository.dart';

/// Concrete implementation of [AiRepository].
class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource _remoteDataSource;

  AiRepositoryImpl({required AiRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, ScanResult>> scanWaste(Uint8List imageBytes) async {
    try {
      final result = await _remoteDataSource.scanWaste(imageBytes);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> chat(String message) async {
    try {
      final reply = await _remoteDataSource.chat(message);
      return Right(reply);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  void resetChat() => _remoteDataSource.resetChat();
}

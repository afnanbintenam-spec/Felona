import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/repositories/auth_repository.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';

/// Use case for uploading a profile picture for the authenticated user.
///
/// Accepts JPEG or PNG images with a maximum size of 5 MB.
/// Returns the URL of the uploaded image on success.
///
/// Requirements: 3.2, 3.3
class UploadProfilePictureUseCase
    extends UseCase<String, UploadProfilePictureParams> {
  final AuthRepository repository;

  UploadProfilePictureUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(
      UploadProfilePictureParams params) async {
    return await repository.uploadProfilePicture(
      userId: params.userId,
      imageFile: params.imageFile,
    );
  }
}

/// Parameters for the [UploadProfilePictureUseCase].
class UploadProfilePictureParams extends Equatable {
  final String userId;
  final File imageFile;

  const UploadProfilePictureParams({
    required this.userId,
    required this.imageFile,
  });

  @override
  List<Object?> get props => [userId, imageFile];
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/notifications/domain/repositories/notifications_repository.dart';

/// Registers the device FCM token with the backend for push notifications.
class RegisterFcmTokenUseCase extends UseCase<void, RegisterFcmTokenParams> {
  final NotificationsRepository repository;

  RegisterFcmTokenUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterFcmTokenParams params) =>
      repository.registerFcmToken(params.token);
}

class RegisterFcmTokenParams extends Equatable {
  final String token;

  const RegisterFcmTokenParams({required this.token});

  @override
  List<Object?> get props => [token];
}

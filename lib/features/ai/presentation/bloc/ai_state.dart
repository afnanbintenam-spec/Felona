import 'package:equatable/equatable.dart';
import 'package:felo_na/features/ai/domain/entities/scan_result.dart';

abstract class AiState extends Equatable {
  const AiState();
  @override
  List<Object?> get props => [];
}

// ──────────────────────────────────────────────
// Scan states
// ──────────────────────────────────────────────

class AiInitial extends AiState {
  const AiInitial();
}

class AiScanning extends AiState {
  const AiScanning();
}

class AiScanSuccess extends AiState {
  final ScanResult result;
  const AiScanSuccess({required this.result});
  @override
  List<Object?> get props => [result];
}

class AiError extends AiState {
  final String message;
  const AiError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ──────────────────────────────────────────────
// Chat states
// ──────────────────────────────────────────────

class ChatInitial extends AiState {
  const ChatInitial();
}

class ChatLoading extends AiState {
  const ChatLoading();
}

class ChatMessageReceived extends AiState {
  final String reply;
  const ChatMessageReceived({required this.reply});
  @override
  List<Object?> get props => [reply];
}

class ChatError extends AiState {
  final String message;
  const ChatError({required this.message});
  @override
  List<Object?> get props => [message];
}

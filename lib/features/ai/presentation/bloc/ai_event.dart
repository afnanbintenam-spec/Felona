import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class AiEvent extends Equatable {
  const AiEvent();
  @override
  List<Object?> get props => [];
}

/// Triggers waste image scanning via the backend AI endpoint.
class ScanWasteRequested extends AiEvent {
  final Uint8List imageBytes;
  const ScanWasteRequested({required this.imageBytes});
  @override
  List<Object?> get props => [imageBytes];
}

/// Sends a chat message to the Gemini recycling assistant.
class ChatMessageSent extends AiEvent {
  final String message;
  const ChatMessageSent({required this.message});
  @override
  List<Object?> get props => [message];
}

/// Resets the Gemini chat session.
class ChatReset extends AiEvent {
  const ChatReset();
}

/// Clears the last scan result to allow a new scan.
class ScanReset extends AiEvent {
  const ScanReset();
}

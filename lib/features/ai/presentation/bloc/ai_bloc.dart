import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/features/ai/domain/usecases/scan_waste_usecase.dart';
import 'package:felo_na/features/ai/domain/usecases/chat_usecase.dart';
import 'package:felo_na/features/ai/domain/repositories/ai_repository.dart';
import 'ai_event.dart';
import 'ai_state.dart';

/// BLoC for AI features — waste scanning and recycling chat.
///
/// Uses [ScanWasteUseCase] for the backend scan endpoint and
/// [ChatUseCase] for the Gemini chat session.
class AiBloc extends Bloc<AiEvent, AiState> {
  final ScanWasteUseCase _scanWasteUseCase;
  final ChatUseCase _chatUseCase;
  final AiRepository _repository;

  AiBloc({
    required ScanWasteUseCase scanWasteUseCase,
    required ChatUseCase chatUseCase,
    required AiRepository repository,
  })  : _scanWasteUseCase = scanWasteUseCase,
        _chatUseCase = chatUseCase,
        _repository = repository,
        super(const AiInitial()) {
    on<ScanWasteRequested>(_onScanWaste);
    on<ChatMessageSent>(_onChatMessage);
    on<ChatReset>(_onChatReset);
    on<ScanReset>(_onScanReset);
  }

  Future<void> _onScanWaste(
    ScanWasteRequested event,
    Emitter<AiState> emit,
  ) async {
    emit(const AiScanning());

    final result = await _scanWasteUseCase(
      ScanWasteParams(imageBytes: event.imageBytes),
    );

    result.fold(
      (failure) => emit(AiError(message: failure.message)),
      (scan) => emit(AiScanSuccess(result: scan)),
    );
  }

  Future<void> _onChatMessage(
    ChatMessageSent event,
    Emitter<AiState> emit,
  ) async {
    emit(const ChatLoading());

    final result = await _chatUseCase(ChatParams(message: event.message));

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (reply) => emit(ChatMessageReceived(reply: reply)),
    );
  }

  void _onChatReset(ChatReset event, Emitter<AiState> emit) {
    _repository.resetChat();
    emit(const ChatInitial());
  }

  void _onScanReset(ScanReset event, Emitter<AiState> emit) {
    emit(const AiInitial());
  }
}

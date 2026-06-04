import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/ai/domain/entities/scan_result.dart';
import 'package:felo_na/features/ai/domain/repositories/ai_repository.dart';
import 'package:felo_na/features/ai/domain/usecases/scan_waste_usecase.dart';
import 'package:felo_na/features/ai/domain/usecases/chat_usecase.dart';
import 'package:felo_na/features/ai/presentation/bloc/ai_bloc.dart';
import 'package:felo_na/features/ai/presentation/bloc/ai_event.dart';
import 'package:felo_na/features/ai/presentation/bloc/ai_state.dart';

import 'ai_bloc_test.mocks.dart';

@GenerateMocks([AiRepository, ScanWasteUseCase, ChatUseCase])
void main() {
  late MockAiRepository mockRepository;
  late MockScanWasteUseCase mockScanUseCase;
  late MockChatUseCase mockChatUseCase;
  late AiBloc bloc;

  // ── test data ───────────────────────────────────────────────────────────
  final tImageBytes = Uint8List.fromList([0, 1, 2, 3]);

  const tScanResult = ScanResult(
    category: 'Plastic',
    itemName: 'PET Water Bottle',
    material: 'PET Plastic',
    isRecyclable: 'yes',
    disposalMethod: 'Place in blue recycling bin',
    dangerLevel: 'low',
    ecoTip: 'Rinse the bottle before recycling!',
    recommendedAction: 'recycle',
    recommendationReason: 'PET plastic is widely recyclable.',
    pointsEarned: 15,
    co2SavedKg: 0.12,
    landfillSavedKg: 0.05,
    estimatedWeightKg: 0.05,
    confidence: 0.93,
  );

  setUp(() {
    mockRepository = MockAiRepository();
    mockScanUseCase = MockScanWasteUseCase();
    mockChatUseCase = MockChatUseCase();
    bloc = AiBloc(
      scanWasteUseCase: mockScanUseCase,
      chatUseCase: mockChatUseCase,
      repository: mockRepository,
    );
  });

  tearDown(() => bloc.close());

  // ── initial state ───────────────────────────────────────────────────────
  test('initial state is AiInitial', () {
    expect(bloc.state, const AiInitial());
  });

  // ── ScanWasteRequested ──────────────────────────────────────────────────
  group('ScanWasteRequested', () {
    blocTest<AiBloc, AiState>(
      'emits [AiScanning, AiScanSuccess] when scan succeeds',
      build: () {
        when(mockScanUseCase(ScanWasteParams(imageBytes: tImageBytes)))
            .thenAnswer((_) async => const Right(tScanResult));
        return bloc;
      },
      act: (b) => b.add(ScanWasteRequested(imageBytes: tImageBytes)),
      expect: () => [
        const AiScanning(),
        const AiScanSuccess(result: tScanResult),
      ],
      verify: (_) => verify(
        mockScanUseCase(ScanWasteParams(imageBytes: tImageBytes)),
      ).called(1),
    );

    blocTest<AiBloc, AiState>(
      'emits [AiScanning, AiError] when scan fails',
      build: () {
        when(mockScanUseCase(ScanWasteParams(imageBytes: tImageBytes)))
            .thenAnswer(
          (_) async => const Left(ServerFailure('AI scan failed')),
        );
        return bloc;
      },
      act: (b) => b.add(ScanWasteRequested(imageBytes: tImageBytes)),
      expect: () => [
        const AiScanning(),
        const AiError(message: 'AI scan failed'),
      ],
    );

    blocTest<AiBloc, AiState>(
      'emits [AiScanning, AiError] on network failure',
      build: () {
        when(mockScanUseCase(ScanWasteParams(imageBytes: tImageBytes)))
            .thenAnswer(
          (_) async => const Left(NetworkFailure('No internet')),
        );
        return bloc;
      },
      act: (b) => b.add(ScanWasteRequested(imageBytes: tImageBytes)),
      expect: () => [
        const AiScanning(),
        const AiError(message: 'No internet'),
      ],
    );
  });

  // ── ChatMessageSent ─────────────────────────────────────────────────────
  group('ChatMessageSent', () {
    blocTest<AiBloc, AiState>(
      'emits [ChatLoading, ChatMessageReceived] when chat succeeds',
      build: () {
        when(mockChatUseCase(const ChatParams(message: 'Can I recycle pizza boxes?')))
            .thenAnswer((_) async =>
                const Right('Yes! As long as they are not heavily soiled.'));
        return bloc;
      },
      act: (b) =>
          b.add(const ChatMessageSent(message: 'Can I recycle pizza boxes?')),
      expect: () => [
        const ChatLoading(),
        const ChatMessageReceived(
          reply: 'Yes! As long as they are not heavily soiled.',
        ),
      ],
    );

    blocTest<AiBloc, AiState>(
      'emits [ChatLoading, ChatError] when chat fails',
      build: () {
        when(mockChatUseCase(const ChatParams(message: 'hi')))
            .thenAnswer(
          (_) async => const Left(ServerFailure('Chat unavailable')),
        );
        return bloc;
      },
      act: (b) => b.add(const ChatMessageSent(message: 'hi')),
      expect: () => [
        const ChatLoading(),
        const ChatError(message: 'Chat unavailable'),
      ],
    );
  });

  // ── ChatReset ───────────────────────────────────────────────────────────
  group('ChatReset', () {
    blocTest<AiBloc, AiState>(
      'emits [ChatInitial] and calls resetChat on repository',
      build: () {
        when(mockRepository.resetChat()).thenReturn(null);
        return bloc;
      },
      act: (b) => b.add(const ChatReset()),
      expect: () => [const ChatInitial()],
      verify: (_) => verify(mockRepository.resetChat()).called(1),
    );
  });

  // ── ScanReset ───────────────────────────────────────────────────────────
  group('ScanReset', () {
    blocTest<AiBloc, AiState>(
      'emits [AiInitial] to allow a fresh scan',
      build: () => bloc,
      act: (b) => b.add(const ScanReset()),
      expect: () => [const AiInitial()],
    );
  });
}

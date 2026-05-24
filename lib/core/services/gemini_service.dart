import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Gemini AI Service — handles waste scanning and recycling chat
class GeminiService {
  static const String _apiKey = 'REDACTED_KEY';

  late final GenerativeModel _visionModel;
  late final GenerativeModel _chatModel;
  ChatSession? _chatSession;

  GeminiService() {
    _visionModel = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: _apiKey,
    );
    _chatModel = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: _apiKey,
      systemInstruction: Content.text(
        'You are FeloNa AI — a friendly, knowledgeable recycling assistant. '
        'You help users understand waste categories, recycling methods, and environmental impact. '
        'Keep responses concise (2-3 sentences max). Use emojis sparingly. '
        'If asked about non-recycling topics, politely redirect to sustainability topics. '
        'Always be encouraging about eco-friendly actions.',
      ),
    );
  }

  /// Scan waste from image bytes — returns structured analysis
  Future<WasteScanResult> scanWaste(Uint8List imageBytes) async {
    final prompt = TextPart(
      'Analyze this image of waste/recyclable material. Respond in this EXACT format:\n'
      'CATEGORY: [one of: Plastic, Paper, Metal, Glass, Electronics, Organic, Textile, Mixed]\n'
      'RECYCLABLE: [Yes/No/Partially]\n'
      'ITEM: [what the item is, e.g. "PET water bottle"]\n'
      'DISPOSAL: [one sentence on how to properly dispose/recycle]\n'
      'DANGER: [None/Low/Medium/High — environmental danger if not recycled]\n'
      'ECO_TIP: [one short encouraging tip]\n'
      'ESTIMATED_POINTS: [number 5-50 based on recycling difficulty]\n\n'
      'If the image does not show waste or recyclable items, respond with:\n'
      'CATEGORY: Unknown\nRECYCLABLE: Unknown\nITEM: Not identifiable as waste\n'
      'DISPOSAL: Please take a clearer photo of the waste item\nDANGER: None\n'
      'ECO_TIP: Try scanning a recyclable item!\nESTIMATED_POINTS: 0',
    );

    final imagePart = DataPart('image/jpeg', imageBytes);

    final response = await _visionModel.generateContent([
      Content.multi([prompt, imagePart]),
    ]);

    final text = response.text ?? '';
    return WasteScanResult.parse(text);
  }

  /// Scan waste from file path
  Future<WasteScanResult> scanWasteFromFile(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return scanWaste(bytes);
  }

  /// Chat with recycling assistant
  Future<String> chat(String message) async {
    _chatSession ??= _chatModel.startChat();

    final response = await _chatSession!.sendMessage(
      Content.text(message),
    );

    return response.text ?? 'Sorry, I could not process that. Try asking about recycling!';
  }

  /// Reset chat session
  void resetChat() {
    _chatSession = null;
  }

  /// Get price suggestion for an item
  Future<String> suggestPrice(String itemName, String condition, String category) async {
    final response = await _chatModel.generateContent([
      Content.text(
        'Suggest a resale price range for this item:\n'
        'Item: $itemName\n'
        'Condition: $condition\n'
        'Category: $category\n\n'
        'Respond in format: "Estimated: \$X - \$Y" followed by one sentence explanation. '
        'Use USD. Be realistic for second-hand items.',
      ),
    ]);

    return response.text ?? 'Unable to estimate price.';
  }
}

/// Parsed result from waste scanning
class WasteScanResult {
  final String category;
  final String recyclable;
  final String item;
  final String disposal;
  final String danger;
  final String ecoTip;
  final int estimatedPoints;

  WasteScanResult({
    required this.category,
    required this.recyclable,
    required this.item,
    required this.disposal,
    required this.danger,
    required this.ecoTip,
    required this.estimatedPoints,
  });

  bool get isRecyclable => recyclable.toLowerCase() == 'yes';
  bool get isPartiallyRecyclable => recyclable.toLowerCase() == 'partially';

  factory WasteScanResult.parse(String text) {
    String extract(String key) {
      final regex = RegExp('$key:\\s*(.+)', caseSensitive: false);
      final match = regex.firstMatch(text);
      return match?.group(1)?.trim() ?? 'Unknown';
    }

    int extractPoints() {
      final regex = RegExp(r'ESTIMATED_POINTS:\s*(\d+)', caseSensitive: false);
      final match = regex.firstMatch(text);
      return int.tryParse(match?.group(1) ?? '10') ?? 10;
    }

    return WasteScanResult(
      category: extract('CATEGORY'),
      recyclable: extract('RECYCLABLE'),
      item: extract('ITEM'),
      disposal: extract('DISPOSAL'),
      danger: extract('DANGER'),
      ecoTip: extract('ECO_TIP'),
      estimatedPoints: extractPoints(),
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/core/services/gemini_service.dart';

/// AI Waste Scanner — Take photo → instant analysis
class WasteScannerScreen extends StatefulWidget {
  const WasteScannerScreen({super.key});

  @override
  State<WasteScannerScreen> createState() => _WasteScannerScreenState();
}

class _WasteScannerScreenState extends State<WasteScannerScreen> {
  final _gemini = GeminiService();
  final _picker = ImagePicker();

  bool _isScanning = false;
  Uint8List? _imageBytes;
  WasteScanResult? _result;
  String? _error;

  Future<void> _pickAndScan(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        _imageBytes = bytes;
        _isScanning = true;
        _result = null;
        _error = null;
      });

      final result = await _gemini.scanWaste(bytes);

      setState(() {
        _result = result;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Scan failed: ${e.toString().split(':').last.trim()}';
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('AI Waste Scanner', style: TextStyle(
          fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Spacing.pagePadding,
          child: Column(
            children: [
              Spacing.gap16,
              // Image preview or placeholder
              _buildImageArea(),
              Spacing.gap24,
              // Scan buttons
              if (_result == null && !_isScanning) _buildScanButtons(),
              // Loading
              if (_isScanning) _buildLoading(),
              // Results
              if (_result != null) _buildResults(),
              // Error
              if (_error != null) _buildError(),
              Spacing.gap32,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageArea() {
    if (_imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.memory(
          _imageBytes!,
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_rounded, size: 56, color: AppColors.primaryGreen.withValues(alpha: 0.5)),
          Spacing.gap16,
          const Text('Take a photo of waste', style: TextStyle(
            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          )),
          Spacing.gap4,
          const Text('AI will identify and categorize it', style: TextStyle(
            fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }

  Widget _buildScanButtons() {
    return Column(
      children: [
        // Gallery button (works on all platforms)
        GestureDetector(
          onTap: () => _pickAndScan(ImageSource.gallery),
          child: Container(
            width: double.infinity, height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 12, offset: const Offset(0, 4),
              )],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_rounded, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Text('Choose Photo', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
              ],
            ),
          ),
        ),
        Spacing.gap12,
        // Camera button (only works on mobile)
        GestureDetector(
          onTap: () => _pickAndScan(ImageSource.camera),
          child: Container(
            width: double.infinity, height: 56,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_rounded, color: AppColors.textSecondary, size: 22),
                SizedBox(width: 12),
                Text('Take Photo (Mobile only)', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 3),
          Spacing.gap16,
          const Text('Analyzing waste...', style: TextStyle(
            fontFamily: 'Inter', fontSize: 15, color: AppColors.textSecondary,
          )),
          Spacing.gap4,
          const Text('AI is identifying the material', style: TextStyle(
            fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final r = _result!;
    return Column(
      children: [
        // Category + Recyclable badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _categoryIcon(r.category),
                  Spacing.hGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.item, style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        )),
                        Text(r.category, style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
                        )),
                      ],
                    ),
                  ),
                  _recyclableBadge(r.recyclable),
                ],
              ),
              Spacing.gap16,
              _infoRow(Icons.delete_outline_rounded, 'Disposal', r.disposal),
              Spacing.gap12,
              _infoRow(Icons.warning_amber_rounded, 'Danger Level', r.danger),
              Spacing.gap12,
              _infoRow(Icons.lightbulb_outline_rounded, 'Eco Tip', r.ecoTip),
              Spacing.gap16,
              // Points badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.primaryGreen, size: 18),
                    const SizedBox(width: 6),
                    Text('+${r.estimatedPoints} eco points if recycled properly', style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500,
                      color: AppColors.primaryGreen,
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
        Spacing.gap16,
        // Scan again
        GestureDetector(
          onTap: () => setState(() { _result = null; _imageBytes = null; }),
          child: Container(
            width: double.infinity, height: 48,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4)),
            ),
            child: const Center(child: Text('Scan Another Item', style: TextStyle(
              fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ))),
          ),
        ),
      ],
    );
  }

  Widget _categoryIcon(String category) {
    IconData icon;
    Color color;
    switch (category.toLowerCase()) {
      case 'plastic': icon = Icons.water_drop_rounded; color = const Color(0xFF42A5F5); break;
      case 'paper': icon = Icons.description_rounded; color = const Color(0xFFFFB74D); break;
      case 'metal': icon = Icons.hardware_rounded; color = const Color(0xFF78909C); break;
      case 'glass': icon = Icons.wine_bar_rounded; color = const Color(0xFF26A69A); break;
      case 'electronics': icon = Icons.devices_rounded; color = const Color(0xFFAB47BC); break;
      case 'organic': icon = Icons.eco_rounded; color = const Color(0xFF66BB6A); break;
      default: icon = Icons.category_rounded; color = AppColors.textTertiary; break;
    }
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _recyclableBadge(String status) {
    Color bg, text;
    if (status.toLowerCase() == 'yes') {
      bg = AppColors.primaryGreen.withValues(alpha: 0.12);
      text = AppColors.primaryGreen;
    } else if (status.toLowerCase() == 'partially') {
      bg = AppColors.warning.withValues(alpha: 0.12);
      text = AppColors.warning;
    } else {
      bg = AppColors.error.withValues(alpha: 0.12);
      text = AppColors.error;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(
        fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: text,
      )),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary,
            )),
            Text(value, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 14, color: AppColors.textPrimary,
            )),
          ],
        )),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 22),
          Spacing.hGap12,
          Expanded(child: Text(_error!, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 14, color: AppColors.error,
          ))),
        ],
      ),
    );
  }
}

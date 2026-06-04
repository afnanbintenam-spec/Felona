import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/core/network/api_client.dart';
import 'package:felo_na/core/network/auth_interceptor.dart';
import 'package:felo_na/core/network/web_storage.dart';

/// Waste Scanner — Scan waste, identify its type, and earn eco points.
///
/// The scanner identifies what type of waste an item is and awards eco points
/// based on how beneficial recycling/reselling it is for the environment.
class WasteScannerScreen extends StatefulWidget {
  const WasteScannerScreen({super.key});

  @override
  State<WasteScannerScreen> createState() => _WasteScannerScreenState();
}

class _WasteScannerScreenState extends State<WasteScannerScreen> {
  final _dio = Dio(BaseOptions(baseUrl: ApiClient.baseUrl));
  final _storage = AppStorage();
  final _picker = ImagePicker();

  bool _isScanning = false;
  Uint8List? _imageBytes;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _pickAndScan(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        _imageBytes = bytes;
        _isScanning = true;
        _result = null;
        _error = null;
      });

      final token = await _storage.read(key: TokenKeys.accessToken);
      if (token == null) {
        setState(() {
          _error = 'Please log in to scan items';
          _isScanning = false;
        });
        return;
      }

      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(bytes, filename: 'scan.jpg'),
      });

      final response = await _dio.post(
        '/ai/scan',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      setState(() {
        _result = response.data['scan'] as Map<String, dynamic>?;
        _isScanning = false;
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?['error']?.toString() ??
            'Scan failed. Please try again.';
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Scan failed: ${e.toString()}';
        _isScanning = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _result = null;
      _imageBytes = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.document_scanner_rounded,
              color: AppColors.primaryGreen,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Waste Scanner',
              style: TextStyle(
                fontFamily: 'Finlandica',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: Spacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacing.gap16,
              _buildImageArea(),
              Spacing.gap24,
              if (_result == null && !_isScanning) _buildScanButtons(),
              if (_isScanning) _buildLoading(),
              if (_result != null) _buildResults(),
              if (_error != null) ...[
                Spacing.gap16,
                _buildError(),
                Spacing.gap12,
                _buildRetryButton(),
              ],
              Spacing.gap32,
            ],
          ),
        ),
      ),
    );
  }

  // ─── IMAGE AREA ────────────────────────────────────────────────────────────

  Widget _buildImageArea() {
    if (_imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.memory(
          _imageBytes!,
          width: double.infinity,
          height: 260,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              size: 32,
              color: AppColors.primaryGreen,
            ),
          ),
          Spacing.gap16,
          const Text(
            'Scan a waste item',
            style: TextStyle(
              fontFamily: 'Finlandica',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Spacing.gap6,
          const Text(
            'AI identifies the waste type\nand rewards you with eco points',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── SCAN BUTTONS ──────────────────────────────────────────────────────────

  Widget _buildScanButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickAndScan(ImageSource.camera),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Text(
                  'Take Photo',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Spacing.gap12,
        GestureDetector(
          onTap: () => _pickAndScan(ImageSource.gallery),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                SizedBox(width: 12),
                Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── LOADING ───────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              color: AppColors.primaryGreen,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Identifying waste...',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Analysing material type',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── RESULTS ───────────────────────────────────────────────────────────────

  Widget _buildResults() {
    final r = _result!;
    final isRecyclable = (r['is_recyclable'] as String? ?? 'no').toLowerCase();
    final rawPoints = (r['points_earned'] as num?)?.toInt() ?? 0;
    // Only award points if item is recyclable or partially recyclable
    final points = (isRecyclable == 'yes' || isRecyclable == 'partially')
        ? rawPoints
        : 0;

    return Column(
      children: [
        // Eco points banner
        _buildPointsBanner(points, rawPoints, isRecyclable),
        Spacing.gap16,

        // Waste type card
        _buildWasteTypeCard(r),
        Spacing.gap24,

        // Scan another
        GestureDetector(
          onTap: _reset,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.4),
              ),
            ),
            child: const Center(
              child: Text(
                'Scan Another Item',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsBanner(int points, int potentialPoints, String isRecyclable) {
    final earned = points > 0;
    final isNotRecyclable = isRecyclable == 'no';
    final isPartial = isRecyclable == 'partially';

    // For non-recyclable items, show potential points (greyed out/muted style)
    if (isNotRecyclable) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.eco_rounded,
              color: AppColors.textTertiary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              potentialPoints > 0 ? '+$potentialPoints' : '0',
              style: const TextStyle(
                fontFamily: 'Finlandica',
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: AppColors.textTertiary,
              ),
            ),
            const Text(
              'Eco Points if properly disposed',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Not recyclable — no points awarded',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Recyclable or partially recyclable
    final bannerColor = isPartial ? AppColors.warning : AppColors.primaryGreen;
    final label = isPartial ? 'Eco Points if fully recycled' : 'Eco Points Earned';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: earned ? bannerColor : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: earned ? null : Border.all(color: AppColors.border, width: 1),
        boxShadow: earned
            ? [
                BoxShadow(
                  color: bannerColor.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Icon(
            earned ? Icons.eco_rounded : Icons.info_outline_rounded,
            color: earned ? Colors.white : AppColors.textSecondary,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            earned ? '+$points' : '0',
            style: TextStyle(
              fontFamily: 'Finlandica',
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: earned ? Colors.white : AppColors.textMuted,
            ),
          ),
          Text(
            earned ? label : 'No points for this item',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: earned
                  ? Colors.white.withValues(alpha: 0.9)
                  : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteTypeCard(Map<String, dynamic> r) {
    final category = (r['category'] as String? ?? 'Unknown');
    final itemName = (r['item_name'] as String? ?? 'Unknown item');
    final material = (r['material'] as String? ?? '');
    final isRecyclable = (r['is_recyclable'] as String? ?? 'no');

    return Container(
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
          // Header label
          const Text(
            'Waste Type',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          Spacing.gap12,

          // Category icon + name
          Row(
            children: [
              _categoryIcon(category),
              Spacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: const TextStyle(
                        fontFamily: 'Finlandica',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      material.isNotEmpty
                          ? '$category · $material'
                          : category,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              _recyclableBadge(isRecyclable),
            ],
          ),
        ],
      ),
    );
  }

  // ─── ERROR ─────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 22),
          Spacing.hGap12,
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: _reset,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'Try Again',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────

  Widget _categoryIcon(String category) {
    final cat = category.toLowerCase();
    final IconData icon;
    final Color color;

    switch (cat) {
      case 'plastic':
        icon = Icons.water_drop_rounded;
        color = const Color(0xFF42A5F5);
        break;
      case 'paper':
        icon = Icons.description_rounded;
        color = const Color(0xFFFFB74D);
        break;
      case 'metal':
        icon = Icons.hardware_rounded;
        color = const Color(0xFF78909C);
        break;
      case 'glass':
        icon = Icons.wine_bar_rounded;
        color = const Color(0xFF26A69A);
        break;
      case 'electronics':
        icon = Icons.devices_rounded;
        color = const Color(0xFFAB47BC);
        break;
      case 'organic':
        icon = Icons.eco_rounded;
        color = const Color(0xFF66BB6A);
        break;
      case 'textile':
        icon = Icons.checkroom_rounded;
        color = const Color(0xFFFF8A65);
        break;
      default:
        icon = Icons.category_rounded;
        color = AppColors.textTertiary;
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }

  Widget _recyclableBadge(String status) {
    final s = status.toLowerCase();
    final Color bg;
    final Color text;
    final String label;

    if (s == 'yes') {
      bg = AppColors.primaryGreen.withValues(alpha: 0.12);
      text = AppColors.primaryGreen;
      label = '♻️ Recyclable';
    } else if (s == 'partially') {
      bg = AppColors.warning.withValues(alpha: 0.12);
      text = AppColors.warning;
      label = '⚠️ Partial';
    } else {
      bg = AppColors.error.withValues(alpha: 0.12);
      text = AppColors.error;
      label = '✕ Not recyclable';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}

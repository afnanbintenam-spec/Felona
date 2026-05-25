import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/core/network/api_client.dart';

/// AI Waste Scanner — Backend-powered with eco impact engine
/// Uses /ai/scan endpoint which returns full analysis + saves to DB
class WasteScannerScreen extends StatefulWidget {
  const WasteScannerScreen({super.key});

  @override
  State<WasteScannerScreen> createState() => _WasteScannerScreenState();
}

class _WasteScannerScreenState extends State<WasteScannerScreen> {
  final _dio = Dio(BaseOptions(baseUrl: ApiClient.baseUrl));
  final _storage = const FlutterSecureStorage();
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

      // Get auth token
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        setState(() {
          _error = 'Please log in to scan items';
          _isScanning = false;
        });
        return;
      }

      // Upload to backend AI scan endpoint
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: 'scan.jpg',
        ),
      });

      final response = await _dio.post(
        '/ai/scan',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      setState(() {
        _result = response.data['scan'];
        _isScanning = false;
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?['error']?.toString() ?? 'Scan failed. Try again.';
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Scan failed: ${e.toString()}';
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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.primaryGreen, size: 18),
            SizedBox(width: 8),
            Text('AI Waste Scanner', style: TextStyle(
              fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            )),
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
              ],
              Spacing.gap32,
            ],
          ),
        ),
      ),
    );
  }

  // ─── IMAGE AREA ─────────────────────────────────────────────
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
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt_rounded, size: 28, color: AppColors.primaryGreen),
          ),
          Spacing.gap16,
          const Text('Scan any waste item', style: TextStyle(
            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          )),
          Spacing.gap4,
          const Text(
            'AI identifies material, calculates impact,\nand earns you eco points',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── SCAN BUTTONS ───────────────────────────────────────────
  Widget _buildScanButtons() {
    return Column(
      children: [
        // Gallery (works on web + mobile)
        GestureDetector(
          onTap: () => _pickAndScan(ImageSource.gallery),
          child: Container(
            width: double.infinity, height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 12, offset: const Offset(0, 4),
                ),
              ],
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
        // Camera (mobile only)
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
                Text('Take Photo', style: TextStyle(
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

  // ─── LOADING ────────────────────────────────────────────────
  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 48, height: 48,
            child: CircularProgressIndicator(
              color: AppColors.primaryGreen, strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text('Analyzing waste...', style: TextStyle(
            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          )),
          SizedBox(height: 4),
          Text('Identifying material & calculating impact', style: TextStyle(
            fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }

  // ─── RESULTS ────────────────────────────────────────────────
  Widget _buildResults() {
    final r = _result!;
    final pointsEarned = r['points_earned'] ?? 0;

    return Column(
      children: [
        // Points Earned Banner (top)
        if (pointsEarned > 0) _buildPointsBanner(pointsEarned, r['co2_saved_kg']),
        Spacing.gap16,

        // Identification Card
        _buildIdentificationCard(r),
        Spacing.gap12,

        // Eco Impact Card
        _buildImpactCard(r),
        Spacing.gap12,

        // Recommended Action Card
        _buildActionCard(r),

        if ((r['estimated_value']?['max'] ?? 0) > 0) ...[
          Spacing.gap12,
          _buildResaleCard(r),
        ],

        Spacing.gap12,
        _buildEcoTipCard(r),

        Spacing.gap24,
        // Scan Another button
        GestureDetector(
          onTap: () => setState(() {
            _result = null;
            _imageBytes = null;
          }),
          child: Container(
            width: double.infinity, height: 48,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4)),
            ),
            child: const Center(
              child: Text('Scan Another Item', style: TextStyle(
                fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsBanner(int points, dynamic co2) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 16, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('+$points', style: const TextStyle(
            fontFamily: 'Inter', fontSize: 36, fontWeight: FontWeight.w800,
            color: Colors.white,
          )),
          const Text('eco points earned', style: TextStyle(
            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
            color: Colors.white,
          )),
          const SizedBox(height: 8),
          if (co2 != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🌍 ${_fmtNum(co2)}kg CO₂ saved from atmosphere',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIdentificationCard(Map<String, dynamic> r) {
    final confidence = ((r['confidence'] ?? 0) is num)
        ? ((r['confidence'] ?? 0) * 100).toInt()
        : 0;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _categoryIcon(r['category']),
              Spacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['item_name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${r['material'] ?? 'Unknown'} • ${r['category'] ?? 'unknown'}',
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              _recyclableBadge(r['is_recyclable']),
            ],
          ),
          Spacing.gap16,
          // Confidence bar
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primaryGreen),
              const SizedBox(width: 6),
              Text('AI Confidence: $confidence%', style: const TextStyle(
                fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary,
              )),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 6,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCard(Map<String, dynamic> r) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.public_rounded, color: AppColors.primaryGreen, size: 18),
              SizedBox(width: 8),
              Text('Environmental Impact', style: TextStyle(
                fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
            ],
          ),
          Spacing.gap16,
          Row(
            children: [
              Expanded(child: _impactStat(
                '${_fmtNum(r['co2_saved_kg'])}kg',
                'CO₂ saved',
                Icons.cloud_outlined,
              )),
              Spacing.hGap12,
              Expanded(child: _impactStat(
                '${_fmtNum(r['landfill_saved_kg'])}kg',
                'From landfill',
                Icons.delete_outline_rounded,
              )),
            ],
          ),
          Spacing.gap8,
          Row(
            children: [
              Expanded(child: _impactStat(
                '${_fmtNum(r['estimated_weight_kg'])}kg',
                'Item weight',
                Icons.scale_rounded,
              )),
              Spacing.hGap12,
              Expanded(child: _dangerStat(r['danger_level'] ?? 'none')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(Map<String, dynamic> r) {
    final action = r['recommended_action'] ?? 'dispose';
    final reason = r['recommendation_reason'] ?? r['disposal_method'] ?? '';
    final actionData = _actionData(action);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: actionData['color'].withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(actionData['icon'], color: actionData['color'], size: 20),
              ),
              Spacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recommended Action', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
                    )),
                    Text(actionData['label'], style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
                  ],
                ),
              ),
            ],
          ),
          Spacing.gap12,
          Text(reason, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary, height: 1.5,
          )),
          if (action == 'pickup' || action == 'sell') ...[
            Spacing.gap16,
            GestureDetector(
              onTap: () {
                if (action == 'pickup') {
                  Navigator.pushNamed(context, '/create-pickup');
                } else {
                  Navigator.pushNamed(context, '/create-listing');
                }
              },
              child: Container(
                width: double.infinity, height: 44,
                decoration: BoxDecoration(
                  color: actionData['color'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    action == 'pickup' ? 'Schedule Pickup' : 'List for Sale',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResaleCard(Map<String, dynamic> r) {
    final value = r['estimated_value'];
    return _card(
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.savings_rounded, color: AppColors.accentYellow, size: 20),
          ),
          Spacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Resale Value', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
                )),
                Text(
                  '\$${_fmtNum(value['min'])} - \$${_fmtNum(value['max'])}',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoTipCard(Map<String, dynamic> r) {
    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primaryGreen, size: 20),
          ),
          Spacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Did you know?', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
                )),
                const SizedBox(height: 2),
                Text(
                  r['eco_tip'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 13, color: AppColors.textPrimary, height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ────────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: child,
    );
  }

  Widget _impactStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          )),
          Text(label, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }

  Widget _dangerStat(String level) {
    Color color;
    switch (level) {
      case 'high': color = AppColors.error; break;
      case 'medium': color = AppColors.warning; break;
      case 'low': color = AppColors.accentYellow; break;
      default: color = AppColors.success;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: color),
          const SizedBox(height: 6),
          Text(level[0].toUpperCase() + level.substring(1), style: TextStyle(
            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: color,
          )),
          const Text('Danger', style: TextStyle(
            fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }

  Widget _categoryIcon(String? category) {
    final cat = (category ?? '').toLowerCase();
    final IconData icon;
    final Color color;
    switch (cat) {
      case 'plastic': icon = Icons.water_drop_rounded; color = const Color(0xFF42A5F5); break;
      case 'paper': icon = Icons.description_rounded; color = const Color(0xFFFFB74D); break;
      case 'metal': icon = Icons.hardware_rounded; color = const Color(0xFF78909C); break;
      case 'glass': icon = Icons.wine_bar_rounded; color = const Color(0xFF26A69A); break;
      case 'electronics': icon = Icons.devices_rounded; color = const Color(0xFFAB47BC); break;
      case 'organic': icon = Icons.eco_rounded; color = const Color(0xFF66BB6A); break;
      case 'textile': icon = Icons.checkroom_rounded; color = const Color(0xFFFF8A65); break;
      default: icon = Icons.category_rounded; color = AppColors.textTertiary;
    }
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _recyclableBadge(String? status) {
    final s = (status ?? 'no').toLowerCase();
    Color bg, text;
    String label;
    if (s == 'yes') {
      bg = AppColors.primaryGreen.withValues(alpha: 0.12);
      text = AppColors.primaryGreen;
      label = '♻️ Yes';
    } else if (s == 'partially') {
      bg = AppColors.warning.withValues(alpha: 0.12);
      text = AppColors.warning;
      label = '⚠️ Partial';
    } else {
      bg = AppColors.error.withValues(alpha: 0.12);
      text = AppColors.error;
      label = '✕ No';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(
        fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: text,
      )),
    );
  }

  Map<String, dynamic> _actionData(String action) {
    switch (action) {
      case 'recycle':
        return {'icon': Icons.recycling_rounded, 'color': AppColors.primaryGreen, 'label': 'Recycle ♻️'};
      case 'reuse':
        return {'icon': Icons.refresh_rounded, 'color': AppColors.tealGreen, 'label': 'Reuse 🔄'};
      case 'sell':
        return {'icon': Icons.storefront_rounded, 'color': AppColors.accentYellow, 'label': 'Sell on Marketplace 💰'};
      case 'pickup':
        return {'icon': Icons.local_shipping_rounded, 'color': AppColors.primaryGreen, 'label': 'Schedule Pickup 🚛'};
      default:
        return {'icon': Icons.delete_outline_rounded, 'color': AppColors.textSecondary, 'label': 'Dispose Properly'};
    }
  }

  String _fmtNum(dynamic value) {
    if (value == null) return '0';
    if (value is num) return value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
    final parsed = double.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return parsed.toStringAsFixed(parsed % 1 == 0 ? 0 : 2);
  }

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
          Expanded(child: Text(_error!, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 13, color: AppColors.error,
          ))),
        ],
      ),
    );
  }
}

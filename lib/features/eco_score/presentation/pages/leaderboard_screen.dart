import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';

/// Leaderboard Screen — top eco warriors
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
  final _storage = const FlutterSecureStorage();

  List<dynamic> _leaderboard = [];
  String? _currentUserId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get('/eco/leaderboard');
      if (response.statusCode == 200) {
        _leaderboard = response.data['leaderboard'] ?? response.data['users'] ?? [];
        _currentUserId = response.data['currentUserId'] ?? response.data['current_user_id'];
      }
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: Spacing.pagePadding,
              child: Column(
                children: [
                  Spacing.gap16,
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textSecondary, size: 18),
                        ),
                      ),
                      Spacing.hGap12,
                      const Expanded(
                        child: Text('Leaderboard', style: TextStyle(
                          fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        )),
                      ),
                      const Icon(Icons.emoji_events_rounded, color: AppColors.accentYellow, size: 24),
                    ],
                  ),
                ],
              ),
            ),
            Spacing.gap24,
            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : _leaderboard.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: AppColors.primaryGreen,
                          backgroundColor: AppColors.card,
                          onRefresh: _loadLeaderboard,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            padding: Spacing.pagePadding,
                            child: Column(
                              children: [
                                if (_leaderboard.length >= 3) _buildPodium(),
                                Spacing.gap24,
                                _buildRemainingList(),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PODIUM (Top 3) ───────────────────────────────────────────
  Widget _buildPodium() {
    final first = _leaderboard[0];
    final second = _leaderboard[1];
    final third = _leaderboard[2];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place
        Expanded(child: _podiumItem(second, 2, const Color(0xFFC0C0C0), 80)),
        Spacing.hGap8,
        // 1st place
        Expanded(child: _podiumItem(first, 1, const Color(0xFFFFD700), 100)),
        Spacing.hGap8,
        // 3rd place
        Expanded(child: _podiumItem(third, 3, const Color(0xFFCD7F32), 64)),
      ],
    );
  }

  Widget _podiumItem(dynamic user, int rank, Color medalColor, double height) {
    final isCurrentUser = user['id']?.toString() == _currentUserId ||
        user['_id']?.toString() == _currentUserId;
    final name = user['name'] ?? user['username'] ?? 'User';
    final points = user['eco_points'] ?? user['points'] ?? 0;

    return Column(
      children: [
        // Medal icon
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: medalColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        Spacing.gap8,
        // Avatar
        Container(
          width: rank == 1 ? 56 : 48,
          height: rank == 1 ? 56 : 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.card,
            border: Border.all(color: medalColor, width: 2.5),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: rank == 1 ? 20 : 16,
                fontWeight: FontWeight.w700,
                color: medalColor,
              ),
            ),
          ),
        ),
        Spacing.gap8,
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600,
            color: isCurrentUser ? AppColors.primaryGreen : AppColors.textPrimary,
          ),
          maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
        ),
        Spacing.gap4,
        Text(
          '$points pts',
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500,
            color: medalColor,
          ),
        ),
        Spacing.gap8,
        // Podium bar
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: medalColor.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: medalColor.withValues(alpha: 0.3), width: 1),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800,
                color: medalColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── REMAINING LIST ───────────────────────────────────────────
  Widget _buildRemainingList() {
    if (_leaderboard.length <= 3) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rankings', style: TextStyle(
          fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        )),
        Spacing.gap12,
        ...List.generate(
          _leaderboard.length - 3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _rankTile(_leaderboard[index + 3], index + 4),
          ),
        ),
      ],
    );
  }

  Widget _rankTile(dynamic user, int rank) {
    final isCurrentUser = user['id']?.toString() == _currentUserId ||
        user['_id']?.toString() == _currentUserId;
    final name = user['name'] ?? user['username'] ?? 'User';
    final points = user['eco_points'] ?? user['points'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.primaryGreen.withValues(alpha: 0.08) : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser ? AppColors.primaryGreen.withValues(alpha: 0.4) : AppColors.border,
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700,
                color: isCurrentUser ? AppColors.primaryGreen : AppColors.textTertiary,
              ),
            ),
          ),
          Spacing.hGap8,
          // Avatar
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrentUser
                  ? AppColors.primaryGreen.withValues(alpha: 0.12)
                  : AppColors.surface,
              border: Border.all(
                color: isCurrentUser ? AppColors.primaryGreen : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                  color: isCurrentUser ? AppColors.primaryGreen : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Spacing.hGap12,
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                          color: isCurrentUser ? AppColors.primaryGreen : AppColors.textPrimary,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('You', style: TextStyle(
                          fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        )),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Points
          Text(
            '$points pts',
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
              color: isCurrentUser ? AppColors.primaryGreen : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.leaderboard_rounded, color: AppColors.textTertiary, size: 36),
          ),
          Spacing.gap16,
          const Text('No data yet', style: TextStyle(
            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          )),
          Spacing.gap8,
          const Text('Start earning eco points to appear here!', style: TextStyle(
            fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }
}

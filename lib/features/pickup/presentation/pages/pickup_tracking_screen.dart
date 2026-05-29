import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_bloc.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_event.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_state.dart';

/// Live Pickup Tracking Screen — Shows real-time status, ETA, and collector info.
///
/// Features:
/// - Real-time status timeline
/// - ETA display with countdown
/// - Collector information card
/// - Map placeholder (Google Maps integration ready)
/// - Auto-refresh every 30 seconds
class PickupTrackingScreen extends StatefulWidget {
  final String pickupId;

  const PickupTrackingScreen({super.key, required this.pickupId});

  @override
  State<PickupTrackingScreen> createState() => _PickupTrackingScreenState();
}

class _PickupTrackingScreenState extends State<PickupTrackingScreen> {
  Timer? _refreshTimer;
  PickupRequest? _pickup;

  @override
  void initState() {
    super.initState();
    _loadTracking();
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadTracking();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadTracking() {
    context
        .read<PickupBloc>()
        .add(RefreshTrackingRequested(pickupId: widget.pickupId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Live Tracking',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary),
            onPressed: _loadTracking,
          ),
        ],
      ),
      body: BlocConsumer<PickupBloc, PickupState>(
        listener: (context, state) {
          if (state is PickupTrackingUpdated) {
            setState(() => _pickup = state.pickup);
          } else if (state is PickupDetailLoaded) {
            setState(() => _pickup = state.pickup);
          }
        },
        builder: (context, state) {
          if (_pickup == null && state is PickupLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (_pickup == null) {
            return const Center(
              child: Text(
                'Loading tracking data...',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.textTertiary,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map Placeholder
                _buildMapPlaceholder(),
                const SizedBox(height: 24),

                // ETA Card
                if (_pickup!.status == PickupStatus.onTheWay ||
                    _pickup!.status == PickupStatus.assigned ||
                    _pickup!.status == PickupStatus.accepted)
                  _buildEtaCard(),
                const SizedBox(height: 20),

                // Status Timeline
                _buildStatusTimeline(),
                const SizedBox(height: 24),

                // Collector Info
                if (_pickup!.collectorName != null) _buildCollectorCard(),
                const SizedBox(height: 24),

                // QR Code Section
                if (_pickup!.status == PickupStatus.arrived)
                  _buildQrSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Stack(
        children: [
          // Map background placeholder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_rounded,
                  size: 48,
                  color: AppColors.primaryGreen.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Live Map Tracking',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_pickup!.collectorLatitude != null &&
                    _pickup!.collectorLongitude != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Collector: ${_pickup!.collectorLatitude!.toStringAsFixed(4)}, ${_pickup!.collectorLongitude!.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Status badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _getStatusColor(_pickup!.status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _pickup!.status.displayName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtaCard() {
    final eta = _pickup!.etaMinutes;
    final isArrivingSoon = eta != null && eta <= 5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isArrivingSoon
              ? [AppColors.success, AppColors.success.withValues(alpha: 0.8)]
              : [
                  AppColors.primaryGreen,
                  AppColors.primaryGreen.withValues(alpha: 0.8)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isArrivingSoon ? AppColors.success : AppColors.primaryGreen)
                .withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                eta != null ? '$eta' : '—',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArrivingSoon ? 'Arriving Soon! 🎉' : 'Estimated Arrival',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  eta != null ? '$eta minutes away' : 'Calculating...',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (isArrivingSoon)
            const Icon(Icons.celebration_rounded,
                color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statuses = [
      PickupStatus.pending,
      PickupStatus.assigned,
      PickupStatus.onTheWay,
      PickupStatus.arrived,
      PickupStatus.completed,
    ];

    final currentIndex =
        statuses.indexOf(_pickup!.status).clamp(0, statuses.length - 1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pickup Progress',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(statuses.length, (index) {
            final status = statuses[index];
            final isCompleted = index < currentIndex;
            final isActive = index == currentIndex;
            final isLast = index == statuses.length - 1;

            return _buildTimelineStep(
              title: status.displayName,
              subtitle: _getStatusSubtitle(status),
              isCompleted: isCompleted,
              isActive: isActive,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
  }) {
    final color = isCompleted || isActive
        ? AppColors.primaryGreen
        : AppColors.textMuted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primaryGreen
                        : isActive
                            ? AppColors.primaryGreen.withValues(alpha: 0.2)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: isActive ? 3 : 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : isActive
                          ? Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isCompleted
                          ? AppColors.primaryGreen.withValues(alpha: 0.5)
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isCompleted || isActive
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: isCompleted || isActive
                          ? AppColors.textSecondary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Collector',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: _pickup!.collectorPhoto != null
                    ? ClipOval(
                        child: Image.network(
                          _pickup!.collectorPhoto!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_rounded,
                            color: AppColors.primaryGreen,
                            size: 28,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryGreen,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pickup!.collectorName ?? 'Collector',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_pickup!.collectorRating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _pickup!.collectorRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Call button
              if (_pickup!.collectorPhone != null)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.phone_rounded,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_2_rounded,
              color: AppColors.primaryGreen, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Collector Has Arrived!',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Show this QR code to the collector to verify pickup',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          // QR Code placeholder — will use qr_flutter
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _pickup!.qrToken ?? 'QR',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending:
        return AppColors.warning;
      case PickupStatus.assigned:
        return const Color(0xFF9B59B6);
      case PickupStatus.accepted:
        return AppColors.info;
      case PickupStatus.onTheWay:
        return AppColors.info;
      case PickupStatus.arrived:
        return AppColors.success;
      case PickupStatus.completed:
        return AppColors.success;
      case PickupStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusSubtitle(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending:
        return 'Waiting for collector';
      case PickupStatus.assigned:
        return 'Collector assigned';
      case PickupStatus.accepted:
        return 'Collector accepted';
      case PickupStatus.onTheWay:
        return 'Collector is on the way';
      case PickupStatus.arrived:
        return 'Collector has arrived';
      case PickupStatus.completed:
        return 'Pickup completed';
      case PickupStatus.cancelled:
        return 'Pickup cancelled';
    }
  }
}

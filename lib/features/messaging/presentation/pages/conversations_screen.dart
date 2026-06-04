import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/features/messaging/domain/entities/conversation.dart';
import 'package:felo_na/features/messaging/presentation/bloc/messaging_bloc.dart';
import 'package:felo_na/features/messaging/presentation/bloc/messaging_event.dart';
import 'package:felo_na/features/messaging/presentation/bloc/messaging_state.dart';
import 'package:felo_na/features/messaging/presentation/pages/chat_screen.dart';
import 'package:intl/intl.dart';

/// Lists all conversations for the current user (buyer or seller).
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MessagingBloc>().add(const LoadConversationsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: Spacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacing.gap16,
                  const Text(
                    'Messages',
                    style: TextStyle(
                      fontFamily: 'Finlandica',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Spacing.gap8,
                  const Text(
                    'Your conversations with buyers & sellers',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Spacing.gap16,
            Expanded(
              child: BlocBuilder<MessagingBloc, MessagingState>(
                builder: (context, state) {
                  if (state is MessagingLoading || state is OpeningConversation) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen),
                    );
                  }

                  if (state is ConversationsLoaded) {
                    if (state.conversations.isEmpty) {
                      return _buildEmptyState();
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<MessagingBloc>()
                            .add(const LoadConversationsRequested());
                      },
                      color: AppColors.primaryGreen,
                      backgroundColor: AppColors.card,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: state.conversations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) =>
                            _buildConversationTile(state.conversations[i]),
                      ),
                    );
                  }

                  if (state is MessagingError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.textTertiary, size: 40),
                          Spacing.gap12,
                          Text(state.message,
                              style: const TextStyle(
                                  color: AppColors.textSecondary)),
                          Spacing.gap16,
                          GestureDetector(
                            onTap: () => context
                                .read<MessagingBloc>()
                                .add(const LoadConversationsRequested()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('Retry',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildEmptyState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(Conversation conv) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<MessagingBloc>(),
              child: ChatScreen(conversation: conv),
            ),
          ),
        ).then((_) {
          // Reload conversations after returning from chat
          context.read<MessagingBloc>().add(const LoadConversationsRequested());
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: conv.unreadCount > 0
                ? AppColors.primaryGreen.withValues(alpha: 0.4)
                : AppColors.border,
            width: conv.unreadCount > 0 ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                  backgroundImage: conv.sellerAvatarUrl != null
                      ? NetworkImage(conv.sellerAvatarUrl!)
                      : null,
                  child: conv.sellerAvatarUrl == null
                      ? Text(
                          conv.sellerName.isNotEmpty
                              ? conv.sellerName[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        )
                      : null,
                ),
                if (conv.unreadCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${conv.unreadCount > 9 ? '9+' : conv.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.sellerName,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: conv.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conv.lastMessageAt != null)
                        Text(
                          _formatTime(conv.lastMessageAt!),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    conv.listingTitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (conv.lastMessage != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      conv.lastMessage!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: conv.unreadCount > 0
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                        fontWeight: conv.unreadCount > 0
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.primaryGreen,
              size: 36,
            ),
          ),
          Spacing.gap16,
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Spacing.gap8,
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'When you message a seller about an item, your conversations will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textTertiary,
                height: 1.5,
              ),
            ),
          ),
          Spacing.gap24,
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/marketplace'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Browse Marketplace',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) return DateFormat('HH:mm').format(time);
    if (diff.inDays < 7) return DateFormat('EEE').format(time);
    return DateFormat('dd/MM').format(time);
  }
}

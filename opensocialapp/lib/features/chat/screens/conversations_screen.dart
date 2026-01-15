/// Conversations List Screen with Material 3 Design
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../cubit/chat_cubit.dart';
import 'chat_screen.dart';
import 'new_conversation_dialog.dart';
import '../../../di/injection_container.dart';
import '../../users/presentation/cubit/users_cubit.dart';
import '../../auth/cubit/auth_cubit.dart';

class ConversationsScreen extends StatefulWidget {
  final String currentUserId;
  
  const ConversationsScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return _buildLoadingShimmer();
          }
          
          if (state is ChatError) {
            return _buildErrorState(state.message);
          }
          
          if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return _buildEmptyState();
            }
            return _buildConversationsList(state.conversations);
          }
          
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _buildFab(),
      drawer: _buildProfileDrawer(context, theme),
    );
  }

  Widget _buildProfileDrawer(BuildContext context, ThemeData theme) {
    return Drawer(
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final user = state.user;
          return Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: user.profileUrl != null
                      ? NetworkImage(user.profileUrl!)
                      : null,
                  child: user.profileUrl == null
                      ? Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : null,
                ),
                accountName: Text(
                  user.fullName,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  user.email, // Displaying email as requested
                  style: GoogleFonts.inter(),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to detail profile if needed
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text(
                  'Logout', 
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthCubit>().logout();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              style: GoogleFonts.inter(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
              onChanged: (value) {
                // TODO: Implement search
              },
            )
          : Text(
              'Messages',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() => _isSearching = !_isSearching);
            if (!_isSearching) {
              _searchController.clear();
            }
          },
          icon: Icon(
            _isSearching ? Icons.close : Icons.search_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        IconButton(
          onPressed: () {
            // TODO: Show settings/profile
          },
          icon: Icon(
            Icons.more_vert_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: ListTile(
            leading: const CircleAvatar(radius: 28),
            title: Container(
              height: 14,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            subtitle: Container(
              height: 10,
              width: 200,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppTheme.errorColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ChatCubit>().loadConversations();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No conversations yet',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new conversation to begin chatting',
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showNewConversationDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Start Chatting'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(List<Conversation> conversations) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChatCubit>().loadConversations();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          return _ConversationTile(
            conversation: conversations[index],
            currentUserId: widget.currentUserId,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ChatCubit>(),
                    child: ChatScreen(
                      conversation: conversations[index],
                      currentUserId: widget.currentUserId,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () => _showNewConversationDialog(),
      backgroundColor: AppTheme.primaryColor,
      elevation: 4,
      child: const Icon(
        Icons.edit_rounded,
        color: Colors.white,
      ),
    );
  }

  void _showNewConversationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => sl<UsersCubit>(),
        child: NewConversationDialog(
          onUserSelected: (user) async {
            // Create a new conversation with the selected user
            final chatCubit = context.read<ChatCubit>();
            await chatCubit.createConversation(
              participantIds: [user.id],
            );
          },
        ),
      ),
    );
  }
}

// ===== Conversation Tile Widget =====

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = conversation.getDisplayName(currentUserId);
    final avatarUrl = conversation.getAvatarUrl(currentUserId);
    final lastMessage = conversation.lastMessage;
    final hasUnread = conversation.unreadCount > 0;
    
    // Get other participant for online status
    final otherParticipant = conversation.getOtherParticipant(currentUserId);
    final isOnline = otherParticipant?.isOnline ?? false;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  backgroundImage: avatarUrl != null
                      ? CachedNetworkImageProvider(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? Text(
                          displayName.isNotEmpty 
                              ? displayName[0].toUpperCase() 
                              : '?',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.onlineIndicator,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: hasUnread 
                                ? FontWeight.w600 
                                : FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastMessage != null)
                        Text(
                          _formatTime(lastMessage.createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: hasUnread
                                ? AppTheme.primaryColor
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Last message and unread count
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage?.content ?? 'Start a conversation',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: hasUnread
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conversation.unreadCount > 99
                                ? '99+'
                                : conversation.unreadCount.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    
    if (messageDate == today) {
      return DateFormat.jm().format(time);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(time).inDays < 7) {
      return DateFormat.E().format(time);
    } else {
      return DateFormat.MMMd().format(time);
    }
  }
}

/// Chat Screen with Messages and Input
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../cubit/chat_cubit.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.conversation,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadMessages(widget.conversation);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    context.read<ChatCubit>().leaveCurrentConversation();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more at the top (older messages)
      final state = context.read<ChatCubit>().state;
      if (state is MessagesLoaded && state.hasMore && !state.isLoadingMore) {
        // TODO: Implement pagination
      }
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    context.read<ChatCubit>().sendMessage(content: content);
    _messageController.clear();
    _updateTypingStatus(false);
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _updateTypingStatus(bool typing) {
    if (_isTyping != typing) {
      _isTyping = typing;
      context.read<ChatCubit>().sendTyping(typing);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = widget.conversation.getDisplayName(widget.currentUserId);
    final avatarUrl = widget.conversation.getAvatarUrl(widget.currentUserId);
    final otherParticipant = widget.conversation.getOtherParticipant(
      widget.currentUserId,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 32,
        title: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
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
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : null,
                ),
                if (otherParticipant?.isOnline ?? false)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
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
            // Name and status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    otherParticipant?.isOnline ?? false
                        ? 'Online'
                        : 'Offline',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: otherParticipant?.isOnline ?? false
                          ? AppTheme.onlineIndicator
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Audio call
          IconButton(
            onPressed: () {
              // TODO: Initiate audio call
            },
            icon: const Icon(Icons.call_rounded),
          ),
          // Video call
          IconButton(
            onPressed: () {
              // TODO: Initiate video call
            },
            icon: const Icon(Icons.videocam_rounded),
          ),
          // More options
          IconButton(
            onPressed: () {
              // TODO: Show more options
            },
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (state is MessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return _buildEmptyMessages();
                  }
                  return _buildMessagesList(state.messages);
                }
                
                if (state is ChatError) {
                  return Center(
                    child: Text(state.message),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
          
          // Input area
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Say hi to start the conversation!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<Message> messages) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final isMe = message.senderId == widget.currentUserId;
        final showDate = _shouldShowDate(
          messages, 
          messages.length - 1 - index,
        );
        
        return Column(
          children: [
            if (showDate) _buildDateDivider(message.createdAt),
            _MessageBubble(
              message: message,
              isMe: isMe,
            ),
          ],
        );
      },
    );
  }

  bool _shouldShowDate(List<Message> messages, int index) {
    if (index == 0) return true;
    
    final currentDate = DateTime(
      messages[index].createdAt.year,
      messages[index].createdAt.month,
      messages[index].createdAt.day,
    );
    final previousDate = DateTime(
      messages[index - 1].createdAt.year,
      messages[index - 1].createdAt.month,
      messages[index - 1].createdAt.day,
    );
    
    return currentDate != previousDate;
  }

  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat.yMMMd().format(date);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment button
          IconButton(
            onPressed: () {
              // TODO: Show attachment options
            },
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 28,
            ),
          ),
          
          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.inter(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
                onChanged: (value) {
                  _updateTypingStatus(value.isNotEmpty);
                },
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Send button
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageController,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: hasText
                    ? IconButton(
                        onPressed: _sendMessage,
                        icon: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: () {
                          // TODO: Voice message
                        },
                        icon: Icon(
                          Icons.mic_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 28,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===== Message Bubble Widget =====

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? AppTheme.sentMessageBubble
              : isDark
                  ? AppTheme.receivedMessageBubbleDark
                  : AppTheme.receivedMessageBubbleLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Message content
            Text(
              message.content,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isMe ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            
            // Time and status
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat.jm().format(message.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    
    switch (message.status) {
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.white.withValues(alpha: 0.7);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.white.withValues(alpha: 0.7);
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.lightBlueAccent;
        break;
    }
    
    return Icon(icon, size: 14, color: color);
  }
}

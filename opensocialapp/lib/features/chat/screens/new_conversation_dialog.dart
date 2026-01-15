/// New Conversation Dialog - Clean Architecture Implementation
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../users/presentation/cubit/users_cubit.dart';

/// Dialog for selecting a user to start a new conversation
class NewConversationDialog extends StatefulWidget {
  final Function(User user) onUserSelected;
  
  const NewConversationDialog({
    super.key,
    required this.onUserSelected,
  });

  @override
  State<NewConversationDialog> createState() => _NewConversationDialogState();
}

class _NewConversationDialogState extends State<NewConversationDialog> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load users when dialog opens
    context.read<UsersCubit>().loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 400,
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchField(theme),
            const SizedBox(height: 16),
            Expanded(child: _buildUsersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'New Conversation',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return TextField(
      controller: _searchController,
      onChanged: (query) => context.read<UsersCubit>().filterUsers(query),
      decoration: InputDecoration(
        hintText: 'Search users...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  context.read<UsersCubit>().clearFilter();
                },
                icon: const Icon(Icons.clear),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildUsersList() {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        if (state is UsersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is UsersError) {
          return _buildErrorState(state.message);
        }
        
        if (state is UsersLoaded) {
          if (state.filteredUsers.isEmpty) {
            return _buildEmptyState(state.searchQuery);
          }
          return _buildUsersListView(state.filteredUsers);
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<UsersCubit>().loadUsers(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String searchQuery) {
    return Center(
      child: Text(
        searchQuery.isEmpty ? 'No users available' : 'No users found',
        style: GoogleFonts.inter(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildUsersListView(List<User> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _UserTile(
          user: user,
          onTap: () {
            widget.onUserSelected(user);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

/// User Tile Widget
class _UserTile extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const _UserTile({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        backgroundImage: user.profileUrl != null
            ? NetworkImage(user.profileUrl!)
            : null,
        child: user.profileUrl == null
            ? Text(
                user.fullName.isNotEmpty 
                    ? user.fullName[0].toUpperCase() 
                    : '?',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              )
            : null,
      ),
      title: Text(
        user.fullName,
        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        user.email,
        style: GoogleFonts.inter(fontSize: 12),
      ),
      trailing: user.isOnline
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppTheme.onlineIndicator,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

/// Users Cubit for managing users list state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../data/models/models.dart';
import '../../domain/usecases/get_users_usecase.dart';

// ===== Users State =====

abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<User> users;
  final List<User> filteredUsers;
  final String searchQuery;

  const UsersLoaded({
    required this.users,
    required this.filteredUsers,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [users, filteredUsers, searchQuery];

  UsersLoaded copyWith({
    List<User>? users,
    List<User>? filteredUsers,
    String? searchQuery,
  }) {
    return UsersLoaded(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class UsersError extends UsersState {
  final String message;

  const UsersError(this.message);

  @override
  List<Object?> get props => [message];
}

// ===== Users Cubit =====

class UsersCubit extends Cubit<UsersState> {
  final GetUsersUseCase _getUsersUseCase;

  UsersCubit({
    required GetUsersUseCase getUsersUseCase,
  })  : _getUsersUseCase = getUsersUseCase,
        super(UsersInitial());

  /// Load all users
  Future<void> loadUsers() async {
    emit(UsersLoading());

    final result = await _getUsersUseCase(const NoParams());

    result.fold(
      (failure) => emit(UsersError(failure.message)),
      (users) => emit(UsersLoaded(
        users: users,
        filteredUsers: users,
      )),
    );
  }

  /// Filter users by search query
  void filterUsers(String query) {
    if (state is UsersLoaded) {
      final currentState = state as UsersLoaded;
      
      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredUsers: currentState.users,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.users.where((user) {
          final name = user.fullName.toLowerCase();
          final email = user.email.toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || email.contains(searchQuery);
        }).toList();
        
        emit(currentState.copyWith(
          filteredUsers: filtered,
          searchQuery: query,
        ));
      }
    }
  }

  /// Clear search filter
  void clearFilter() {
    if (state is UsersLoaded) {
      final currentState = state as UsersLoaded;
      emit(currentState.copyWith(
        filteredUsers: currentState.users,
        searchQuery: '',
      ));
    }
  }
}

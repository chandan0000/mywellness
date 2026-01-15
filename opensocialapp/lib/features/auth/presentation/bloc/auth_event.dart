/// Auth Events - Presentation Layer
/// 
/// Event-based file separation for Bloc pattern.
library;

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user is authenticated on app start
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login with email and password
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Register new user
class AuthRegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;

  const AuthRegisterRequested({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, email, phoneNumber, password];
}

/// Logout current user
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Update user profile
class AuthProfileUpdateRequested extends AuthEvent {
  final String? fullName;
  final String? profileUrl;

  const AuthProfileUpdateRequested({
    this.fullName,
    this.profileUrl,
  });

  @override
  List<Object?> get props => [fullName, profileUrl];
}

/// User Entity - Domain Layer
/// 
/// Pure business entity without any framework dependencies.
library;

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profileUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profileUrl,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phoneNumber,
        profileUrl,
        isOnline,
        lastSeen,
        createdAt,
      ];
}

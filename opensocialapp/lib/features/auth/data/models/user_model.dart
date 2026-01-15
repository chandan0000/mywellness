/// User Model - Data Layer
/// 
/// Extends UserEntity with JSON serialization for API/database.
library;

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phoneNumber,
    super.profileUrl,
    super.isOnline,
    super.lastSeen,
    required super.createdAt,
  });

  /// Create from JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      profileUrl: json['profile_url'] ?? json['profileUrl'],
      isOnline: json['is_online'] == true || json['is_online'] == 1,
      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(json['last_seen'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'profile_url': profileUrl,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      profileUrl: entity.profileUrl,
      isOnline: entity.isOnline,
      lastSeen: entity.lastSeen,
      createdAt: entity.createdAt,
    );
  }
}

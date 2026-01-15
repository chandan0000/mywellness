/// Participant Model - Data Layer
library;

import '../../domain/entities/participant_entity.dart';

class ParticipantModel extends ParticipantEntity {
  const ParticipantModel({
    required super.id,
    required super.conversationId,
    required super.userId,
    super.fullName,
    super.email,
    super.profileUrl,
    super.isAdmin,
    super.isOnline,
    required super.joinedAt,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id']?.toString() ?? '${json['conversation_id']}_${json['user_id']}',
      conversationId: json['conversation_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name'],
      email: json['email'],
      profileUrl: json['profile_url'],
      isAdmin: json['is_admin'] == true,
      isOnline: json['is_online'] == true,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'profile_url': profileUrl,
      'is_admin': isAdmin,
      'is_online': isOnline,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

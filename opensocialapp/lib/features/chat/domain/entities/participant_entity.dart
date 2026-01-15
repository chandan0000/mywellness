/// Participant Entity - Domain Layer
library;

import 'package:equatable/equatable.dart';

class ParticipantEntity extends Equatable {
  final String id;
  final String conversationId;
  final String userId;
  final String? fullName;
  final String? email;
  final String? profileUrl;
  final bool isAdmin;
  final bool isOnline;
  final DateTime joinedAt;

  const ParticipantEntity({
    required this.id,
    required this.conversationId,
    required this.userId,
    this.fullName,
    this.email,
    this.profileUrl,
    this.isAdmin = false,
    this.isOnline = false,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [
        id,
        conversationId,
        userId,
        fullName,
        email,
        profileUrl,
        isAdmin,
        isOnline,
        joinedAt,
      ];
}

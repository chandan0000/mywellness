/// API Constants and Configuration
library;

class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://08cb811be39b.ngrok-free.app';
  static const String apiVersion = '/api/v1';
  static const String apiUrl = '$baseUrl$apiVersion';
  
  // WebSocket URL
  static const String socketUrl = 'https://08cb811be39b.ngrok-free.app/socket.io';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // User endpoints
  static const String users = '/users';
  static const String currentUser = '/users/me';
  static const String updateProfile = '/users/me';
  
  // Conversation endpoints
  static const String conversations = '/conversations';
  static String conversationById(String id) => '/conversations/$id';
  static String conversationMessages(String id) => '/conversations/$id/messages';
  static String markMessagesRead(String id) => '/conversations/$id/messages/read';
  static String conversationParticipants(String id) => '/conversations/$id/participants';
  
  // Call endpoints
  static const String initiateCall = '/calls/initiate';
  static const String acceptCall = '/calls/accept';
  static const String rejectCall = '/calls/reject';
  static const String endCall = '/calls/end';
  static String callById(String id) => '/calls/$id';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': token,
  };
}

/// Socket event names
class SocketEvents {
  // Connection events
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String connectionSuccess = 'connection_success';
  static const String error = 'error';
  
  // Room events
  static const String joinConversation = 'join_conversation';
  static const String leaveConversation = 'leave_conversation';
  static const String joinedConversation = 'joined_conversation';
  
  // Message events
  static const String sendMessage = 'send_message';
  static const String newMessage = 'new_message';
  static const String messageSent = 'message_sent';
  static const String messageNotification = 'message_notification';
  static const String typing = 'typing';
  static const String userTyping = 'user_typing';
  static const String messagesRead = 'messages_read';
  static const String messagesReadReceipt = 'messages_read_receipt';
  static const String messageDelivered = 'message_delivered';
  static const String messagesDelivered = 'messages_delivered';
  
  // Call events
  static const String callOffer = 'call_offer';
  static const String incomingCall = 'incoming_call';
  static const String callAnswer = 'call_answer';
  static const String callAnswered = 'call_answered';
  static const String iceCandidate = 'ice_candidate';
  static const String callReject = 'call_reject';
  static const String callRejected = 'call_rejected';
  static const String callEnd = 'call_end';
  static const String callEnded = 'call_ended';
  static const String callBusy = 'call_busy';
  static const String userBusy = 'user_busy';
  
  // Presence events
  static const String updatePresence = 'update_presence';
  static const String presenceUpdate = 'presence_update';
  static const String getOnlineUsers = 'get_online_users';
  static const String onlineUsers = 'online_users';
}

/// Storage keys for SharedPreferences
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userAvatar = 'user_avatar';
  static const String themeMode = 'theme_mode';
  static const String isOnboarded = 'is_onboarded';
  static const String lastSyncTime = 'last_sync_time';
}

/// Socket.IO Client Service
/// 
/// Manages real-time WebSocket connections for:
/// - Chat messaging
/// - Typing indicators
/// - Read receipts
/// - WebRTC signaling for calls
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/api_constants.dart';

/// Socket connection status
enum SocketStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// Socket service for real-time communication
class SocketService extends ChangeNotifier {
  static SocketService? _instance;
  io.Socket? _socket;
  SocketStatus _status = SocketStatus.disconnected;
  String? _userId;
  
  // Stream controllers for events
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _readReceiptController = StreamController<Map<String, dynamic>>.broadcast();
  final _callController = StreamController<Map<String, dynamic>>.broadcast();
  final _presenceController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<SocketStatus>.broadcast();
  
  SocketService._internal();
  
  /// Get singleton instance
  static SocketService get instance {
    _instance ??= SocketService._internal();
    return _instance!;
  }

  // Getters
  SocketStatus get status => _status;
  bool get isConnected => _status == SocketStatus.connected;
  String? get userId => _userId;
  
  // Streams
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get readReceiptStream => _readReceiptController.stream;
  Stream<Map<String, dynamic>> get callStream => _callController.stream;
  Stream<Map<String, dynamic>> get presenceStream => _presenceController.stream;
  Stream<SocketStatus> get connectionStream => _connectionController.stream;

  /// Connect to socket server
  void connect(String userId) {
    if (_socket != null && _status == SocketStatus.connected) {
      debugPrint('[Socket] Already connected');
      return;
    }

    _userId = userId;
    _updateStatus(SocketStatus.connecting);

    _socket = io.io(
      ApiConstants.baseUrl,
      io.OptionBuilder() 
          .setTransports(['websocket'])
          .setQuery({'id': userId})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(10)
          .build(),
    );

    _setupEventListeners();
    _socket!.connect();
  }

  /// Setup socket event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      debugPrint('[Socket] Connected');
      _updateStatus(SocketStatus.connected);
    });

    _socket!.on(SocketEvents.connectionSuccess, (data) {
      debugPrint('[Socket] Connection confirmed: $data');
    });

    _socket!.onDisconnect((_) {
      debugPrint('[Socket] Disconnected');
      _updateStatus(SocketStatus.disconnected);
    });

    _socket!.onConnectError((error) {
      debugPrint('[Socket] Connection error: $error');
      _updateStatus(SocketStatus.error);
    });

    _socket!.onError((error) {
      debugPrint('[Socket] Error: $error');
      _updateStatus(SocketStatus.error);
    });

    // Message events
    _socket!.on(SocketEvents.newMessage, (data) {
      debugPrint('[Socket] New message: $data');
      _messageController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on(SocketEvents.messageSent, (data) {
      debugPrint('[Socket] Message sent: $data');
      _messageController.add({
        'type': 'sent_confirmation',
        ...Map<String, dynamic>.from(data)
      });
    });

    _socket!.on(SocketEvents.messageNotification, (data) {
      debugPrint('[Socket] Message notification: $data');
      _messageController.add({
        'type': 'notification',
        ...Map<String, dynamic>.from(data)
      });
    });

    // Typing events
    _socket!.on(SocketEvents.userTyping, (data) {
      debugPrint('[Socket] User typing: $data');
      _typingController.add(Map<String, dynamic>.from(data));
    });

    // Read receipt events
    _socket!.on(SocketEvents.messagesReadReceipt, (data) {
      debugPrint('[Socket] Read receipt: $data');
      _readReceiptController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on(SocketEvents.messagesDelivered, (data) {
      debugPrint('[Socket] Messages delivered: $data');
      _readReceiptController.add({
        'type': 'delivered',
        ...Map<String, dynamic>.from(data)
      });
    });

    // Call events
    _socket!.on(SocketEvents.incomingCall, (data) {
      debugPrint('[Socket] Incoming call: $data');
      _callController.add({
        'type': 'incoming',
        ...Map<String, dynamic>.from(data)
      });
    });

    _socket!.on(SocketEvents.callAnswered, (data) {
      debugPrint('[Socket] Call answered: $data');
      _callController.add({
        'type': 'answered',
        ...Map<String, dynamic>.from(data)
      });
    });

    _socket!.on(SocketEvents.callRejected, (data) {
      debugPrint('[Socket] Call rejected: $data');
      _callController.add({
        'type': 'rejected',
        ...Map<String, dynamic>.from(data)
      });
    });

    _socket!.on(SocketEvents.callEnded, (data) {
      debugPrint('[Socket] Call ended: $data');
      _callController.add({
        'type': 'ended',
        ...Map<String, dynamic>.from(data)
      });
    });

    _socket!.on(SocketEvents.iceCandidate, (data) {
      debugPrint('[Socket] ICE candidate: $data');
      _callController.add({
        'type': 'ice_candidate',
        ...Map<String, dynamic>.from(data)
      });
    });

    _socket!.on(SocketEvents.userBusy, (data) {
      debugPrint('[Socket] User busy: $data');
      _callController.add({
        'type': 'busy',
        ...Map<String, dynamic>.from(data)
      });
    });

    // Presence events
    _socket!.on(SocketEvents.presenceUpdate, (data) {
      debugPrint('[Socket] Presence update: $data');
      _presenceController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on(SocketEvents.onlineUsers, (data) {
      debugPrint('[Socket] Online users: $data');
      _presenceController.add({
        'type': 'online_users',
        ...Map<String, dynamic>.from(data)
      });
    });
  }

  /// Update connection status
  void _updateStatus(SocketStatus newStatus) {
    _status = newStatus;
    _connectionController.add(newStatus);
    notifyListeners();
  }

  // ===== Chat Methods =====

  /// Join a conversation room
  void joinConversation(String conversationId) {
    _emit(SocketEvents.joinConversation, {'conversation_id': conversationId});
  }

  /// Leave a conversation room
  void leaveConversation(String conversationId) {
    _emit(SocketEvents.leaveConversation, {'conversation_id': conversationId});
  }

  /// Send a message via socket
  void sendMessage({
    required String conversationId,
    required Map<String, dynamic> message,
    required List<String> participantIds,
  }) {
    _emit(SocketEvents.sendMessage, {
      'conversation_id': conversationId,
      'message': message,
      'participant_ids': participantIds,
    });
  }

  /// Send typing indicator
  void sendTyping(String conversationId, bool isTyping) {
    _emit(SocketEvents.typing, {
      'conversation_id': conversationId,
      'is_typing': isTyping,
    });
  }

  /// Send read receipt
  void sendReadReceipt(String conversationId, List<String> messageIds) {
    _emit(SocketEvents.messagesRead, {
      'conversation_id': conversationId,
      'message_ids': messageIds,
    });
  }

  /// Send delivery confirmation
  void sendDeliveryConfirmation(String conversationId, List<String> messageIds) {
    _emit(SocketEvents.messageDelivered, {
      'conversation_id': conversationId,
      'message_ids': messageIds,
    });
  }

  // ===== Call Methods =====

  /// Send call offer
  void sendCallOffer({
    required String callId,
    required String calleeId,
    required String callerName,
    String? callerAvatar,
    required String callType,
    required String sdp,
  }) {
    _emit(SocketEvents.callOffer, {
      'call_id': callId,
      'callee_id': calleeId,
      'caller_name': callerName,
      'caller_avatar': callerAvatar,
      'call_type': callType,
      'sdp': sdp,
    });
  }

  /// Send call answer
  void sendCallAnswer({
    required String callId,
    required String callerId,
    required String sdp,
  }) {
    _emit(SocketEvents.callAnswer, {
      'call_id': callId,
      'caller_id': callerId,
      'sdp': sdp,
    });
  }

  /// Send ICE candidate
  void sendIceCandidate({
    required String callId,
    required String targetUserId,
    required String candidate,
    String? sdpMid,
    int? sdpMLineIndex,
  }) {
    _emit(SocketEvents.iceCandidate, {
      'call_id': callId,
      'target_user_id': targetUserId,
      'candidate': candidate,
      'sdp_mid': sdpMid,
      'sdp_m_line_index': sdpMLineIndex,
    });
  }

  /// Reject call
  void rejectCall(String callId, String callerId) {
    _emit(SocketEvents.callReject, {
      'call_id': callId,
      'caller_id': callerId,
    });
  }

  /// End call
  void endCall(String callId, String targetUserId) {
    _emit(SocketEvents.callEnd, {
      'call_id': callId,
      'target_user_id': targetUserId,
    });
  }

  /// Send busy signal
  void sendBusySignal(String callId, String callerId) {
    _emit(SocketEvents.callBusy, {
      'call_id': callId,
      'caller_id': callerId,
    });
  }

  // ===== Presence Methods =====

  /// Update presence status
  void updatePresence(String status) {
    _emit(SocketEvents.updatePresence, {'status': status});
  }

  /// Get online users
  void getOnlineUsers(List<String> userIds) {
    _emit(SocketEvents.getOnlineUsers, {'user_ids': userIds});
  }

  // ===== Helper Methods =====

  /// Emit event safely
  void _emit(String event, Map<String, dynamic> data) {
    if (_socket != null && isConnected) {
      _socket!.emit(event, data);
      debugPrint('[Socket] Emitted $event: $data');
    } else {
      debugPrint('[Socket] Cannot emit $event - not connected');
    }
  }

  /// Disconnect from socket server
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _userId = null;
    _updateStatus(SocketStatus.disconnected);
  }

  /// Dispose resources
  @override
  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _readReceiptController.close();
    _callController.close();
    _presenceController.close();
    _connectionController.close();
    super.dispose();
  }
}

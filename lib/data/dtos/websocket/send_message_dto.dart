import 'package:equatable/equatable.dart';

class SendMessageDTO extends Equatable {
  final String message;
  final String userId;
  final String? conversationId;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  const SendMessageDTO({
    required this.message,
    required this.userId,
    this.conversationId,
    this.metadata,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'userId': userId,
      'conversationId': conversationId,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SendMessageDTO.fromJson(Map<String, dynamic> json) {
    return SendMessageDTO(
      message: json['message'] as String,
      userId: json['userId'] as String,
      conversationId: json['conversationId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  List<Object?> get props => [message, userId, conversationId, metadata, timestamp];
}

class SendMessageResponseDTO extends Equatable {
  final String messageId;
  final bool success;
  final String? error;
  final Map<String, dynamic>? metadata;

  const SendMessageResponseDTO({
    required this.messageId,
    required this.success,
    this.error,
    this.metadata,
  });

  factory SendMessageResponseDTO.fromJson(Map<String, dynamic> json) {
    return SendMessageResponseDTO(
      messageId: json['messageId'] as String,
      success: json['success'] as bool,
      error: json['error'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'success': success,
      'error': error,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [messageId, success, error, metadata];
} 
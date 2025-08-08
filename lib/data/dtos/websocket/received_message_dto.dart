import 'package:equatable/equatable.dart';

// Base class for all received message events
abstract class ReceivedMessageEventDTO extends Equatable {
  final String messageId;
  final String conversationId;
  final DateTime timestamp;

  const ReceivedMessageEventDTO({
    required this.messageId,
    required this.conversationId,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [messageId, conversationId, timestamp];
}

// When AI agent starts responding (beginning of stream)
class MessageStartDTO extends ReceivedMessageEventDTO {
  final String type;
  final Map<String, dynamic>? metadata;

  const MessageStartDTO({
    required super.messageId,
    required super.conversationId,
    required super.timestamp,
    required this.type,
    this.metadata,
  });

  factory MessageStartDTO.fromJson(Map<String, dynamic> json) {
    // Generate IDs if not provided by server
    final messageId = json['messageId'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
    final conversationId = json['conversationId'] as String? ?? 'default_conversation';
    
    return MessageStartDTO(
      messageId: messageId,
      conversationId: conversationId,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String? ?? 'assistant',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [...super.props, type, metadata];
}

// Streaming chunks of AI response
class MessageChunkDTO extends ReceivedMessageEventDTO {
  final String content;
  final int chunkIndex;
  final bool isComplete;

  const MessageChunkDTO({
    required super.messageId,
    required super.conversationId,
    required super.timestamp,
    required this.content,
    required this.chunkIndex,
    this.isComplete = false,
  });

  factory MessageChunkDTO.fromJson(Map<String, dynamic> json) {
    // Generate IDs if not provided by server
    final messageId = json['messageId'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
    final conversationId = json['conversationId'] as String? ?? 'default_conversation';
    final timestamp = json['timestamp'] as String? ?? DateTime.now().toIso8601String();
    
    // Extract content from nested structure
    String contentText = '';
    if (json['content'] is Map<String, dynamic>) {
      final contentMap = json['content'] as Map<String, dynamic>;
      contentText = contentMap['raw'] as String? ?? contentMap['html'] as String? ?? '';
    } else if (json['content'] is String) {
      contentText = json['content'] as String;
    }
    
    return MessageChunkDTO(
      messageId: messageId,
      conversationId: conversationId,
      timestamp: DateTime.parse(timestamp),
      content: contentText,
      chunkIndex: json['chunkIndex'] as int? ?? 0,
      isComplete: json['is_complete'] as bool? ?? json['isComplete'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [...super.props, content, chunkIndex, isComplete];
}

// When AI agent completes the response
class MessageCompleteDTO extends ReceivedMessageEventDTO {
  final String fullContent;
  final String agentId;
  final Map<String, dynamic>? metadata;
  final int totalChunks;
  final bool isComplete;

  const MessageCompleteDTO({
    required super.messageId,
    required super.conversationId,
    required super.timestamp,
    required this.fullContent,
    required this.agentId,
    this.metadata,
    required this.totalChunks,
    this.isComplete = true,
  });

  factory MessageCompleteDTO.fromJson(Map<String, dynamic> json) {
    // Generate IDs if not provided by server
    final messageId = json['messageId'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
    final conversationId = json['conversationId'] as String? ?? 'default_conversation';
    final timestamp = json['timestamp'] as String? ?? DateTime.now().toIso8601String();
    
    // Extract content from nested structure
    String contentText = '';
    if (json['content'] is Map<String, dynamic>) {
      final contentMap = json['content'] as Map<String, dynamic>;
      contentText = contentMap['raw'] as String? ?? contentMap['html'] as String? ?? '';
    } else if (json['content'] is String) {
      contentText = json['content'] as String;
    } else if (json['fullContent'] is String) {
      contentText = json['fullContent'] as String;
    }
    
    return MessageCompleteDTO(
      messageId: messageId,
      conversationId: conversationId,
      timestamp: DateTime.parse(timestamp),
      fullContent: contentText,
      agentId: json['agentId'] as String? ?? 'quantu_ai_agent',
      metadata: json['metadata'] as Map<String, dynamic>?,
      totalChunks: json['totalChunks'] as int? ?? 1,
      isComplete: json['is_complete'] as bool? ?? json['isComplete'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [...super.props, fullContent, agentId, metadata, totalChunks, isComplete];
}

// When there's an error in AI response
class MessageErrorDTO extends ReceivedMessageEventDTO {
  final String error;
  final String errorCode;
  final Map<String, dynamic>? errorDetails;

  const MessageErrorDTO({
    required super.messageId,
    required super.conversationId,
    required super.timestamp,
    required this.error,
    required this.errorCode,
    this.errorDetails,
  });

  factory MessageErrorDTO.fromJson(Map<String, dynamic> json) {
    return MessageErrorDTO(
      messageId: json['messageId'] as String,
      conversationId: json['conversationId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      error: json['error'] as String,
      errorCode: json['errorCode'] as String,
      errorDetails: json['errorDetails'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [...super.props, error, errorCode, errorDetails];
}

// Complete received message (non-streaming)
class ReceivedMessageDTO extends ReceivedMessageEventDTO {
  final String content;
  final String agentId;
  final String agentName;
  final String? agentAvatarUrl;
  final Map<String, dynamic>? metadata;
  final String type;

  const ReceivedMessageDTO({
    required super.messageId,
    required super.conversationId,
    required super.timestamp,
    required this.content,
    required this.agentId,
    required this.agentName,
    this.agentAvatarUrl,
    this.metadata,
    required this.type,
  });

  factory ReceivedMessageDTO.fromJson(Map<String, dynamic> json) {
    // Generate IDs if not provided by server
    final messageId = json['messageId'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
    final conversationId = json['conversationId'] as String? ?? 'default_conversation';
    
    // Extract content from nested structure
    String contentText = '';
    if (json['content'] is Map<String, dynamic>) {
      final contentMap = json['content'] as Map<String, dynamic>;
      contentText = contentMap['raw'] as String? ?? contentMap['html'] as String? ?? '';
    } else if (json['content'] is String) {
      contentText = json['content'] as String;
    }
    
    return ReceivedMessageDTO(
      messageId: messageId,
      conversationId: conversationId,
      timestamp: DateTime.parse(json['timestamp'] as String),
      content: contentText,
      agentId: json['agentId'] as String? ?? 'quantu_ai_agent',
      agentName: json['agentName'] as String? ?? 'Quantu AI',
      agentAvatarUrl: json['agentAvatarUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      type: json['type'] as String? ?? 'assistant',
    );
  }

  @override
  List<Object?> get props => [...super.props, content, agentId, agentName, agentAvatarUrl, metadata, type];
} 
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.text,
    required super.author,
    required super.createdAt,
    super.type,
    super.status,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      author: ChatUserModel.fromJson(json['author'] as Map<String, dynamic>),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      type: _parseMessageType(json['type'] as String?),
      status: _parseMessageStatus(json['status'] as String?),
    );
  }

  factory ChatMessageModel.fromFlutterChatType(types.Message message) {
    if (message is types.TextMessage) {
      return ChatMessageModel(
        id: message.id,
        text: message.text,
        author: ChatUserModel.fromFlutterChatType(message.author),
        createdAt: DateTime.fromMillisecondsSinceEpoch(message.createdAt ?? 0),
      );
    }
    throw UnimplementedError('Message type not supported yet');
  }

  factory ChatMessageModel.fromEntity(ChatMessage message) {
    return ChatMessageModel(
      id: message.id,
      text: message.text,
      author: ChatUserModel.fromEntity(message.author),
      createdAt: message.createdAt,
      type: message.type,
      status: message.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': (author as ChatUserModel).toJson(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'type': type.name,
      'status': status.name,
    };
  }

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'audio':
        return MessageType.audio;
      case 'video':
        return MessageType.video;
      default:
        return MessageType.text;
    }
  }

  static MessageStatus _parseMessageStatus(String? status) {
    switch (status) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }
}

class ChatUserModel extends ChatUser {
  const ChatUserModel({
    required super.id,
    required super.firstName,
    super.lastName,
    super.imageUrl,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  factory ChatUserModel.fromFlutterChatType(types.User user) {
    return ChatUserModel(
      id: user.id,
      firstName: user.firstName ?? '',
      lastName: user.lastName,
      imageUrl: user.imageUrl,
    );
  }

  factory ChatUserModel.fromEntity(ChatUser user) {
    return ChatUserModel(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      imageUrl: user.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'imageUrl': imageUrl,
    };
  }
} 
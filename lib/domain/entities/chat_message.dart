import 'package:equatable/equatable.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final ChatUser author;
  final DateTime createdAt;
  final MessageType type;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.author,
    required this.createdAt,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    ChatUser? author,
    DateTime? createdAt,
    MessageType? type,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }

  types.Message toFlutterChatType() {
    return types.TextMessage(
      author: author.toFlutterChatType(),
      createdAt: createdAt.millisecondsSinceEpoch,
      id: id,
      text: text,
    );
  }

  @override
  List<Object?> get props => [id, text, author, createdAt, type, status];
}

class ChatUser extends Equatable {
  final String id;
  final String firstName;
  final String? lastName;
  final String? imageUrl;

  const ChatUser({
    required this.id,
    required this.firstName,
    this.lastName,
    this.imageUrl,
  });

  String get displayName => lastName != null ? '$firstName $lastName' : firstName;

  types.User toFlutterChatType() {
    return types.User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      imageUrl: imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, firstName, lastName, imageUrl];
}

enum MessageType {
  text,
  image,
  file,
  audio,
  video,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
} 
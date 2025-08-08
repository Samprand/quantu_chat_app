import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {
  const LoadMessages();
}

class SendMessageEvent extends ChatEvent {
  final String text;
  final ChatUser author;

  const SendMessageEvent({
    required this.text,
    required this.author,
  });

  @override
  List<Object> get props => [text, author];
}

class DeleteMessageEvent extends ChatEvent {
  final String messageId;

  const DeleteMessageEvent({required this.messageId});

  @override
  List<Object> get props => [messageId];
}

class MarkMessageAsRead extends ChatEvent {
  final String messageId;

  const MarkMessageAsRead({required this.messageId});

  @override
  List<Object> get props => [messageId];
}

class SearchMessages extends ChatEvent {
  final String query;

  const SearchMessages({required this.query});

  @override
  List<Object> get props => [query];
}

class ClearSearch extends ChatEvent {
  const ClearSearch();
}

class MessageReceived extends ChatEvent {
  final ChatMessage message;

  const MessageReceived({required this.message});

  @override
  List<Object> get props => [message];
} 
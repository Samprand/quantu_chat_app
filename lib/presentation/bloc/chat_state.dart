import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isSearching;
  final List<ChatMessage> searchResults;
  final String searchQuery;

  const ChatLoaded({
    required this.messages,
    this.isSearching = false,
    this.searchResults = const [],
    this.searchQuery = '',
  });

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isSearching,
    List<ChatMessage>? searchResults,
    String? searchQuery,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isSearching: isSearching ?? this.isSearching,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [messages, isSearching, searchResults, searchQuery];
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object> get props => [message];
}

class MessageSending extends ChatState {
  final List<ChatMessage> messages;
  final ChatMessage pendingMessage;

  const MessageSending({
    required this.messages,
    required this.pendingMessage,
  });

  @override
  List<Object> get props => [messages, pendingMessage];
}

class MessageSent extends ChatState {
  final List<ChatMessage> messages;

  const MessageSent({required this.messages});

  @override
  List<Object> get props => [messages];
}

class MessageSendError extends ChatState {
  final List<ChatMessage> messages;
  final String error;

  const MessageSendError({
    required this.messages,
    required this.error,
  });

  @override
  List<Object> get props => [messages, error];
} 
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../core/usecases/usecase.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/send_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessages getMessages;
  final SendMessage sendMessage;
  final Uuid _uuid = const Uuid();
  
  late StreamSubscription _messageStreamSubscription;

  ChatBloc({
    required this.getMessages,
    required this.sendMessage,
  }) : super(const ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<MarkMessageAsRead>(_onMarkMessageAsRead);
    on<SearchMessages>(_onSearchMessages);
    on<ClearSearch>(_onClearSearch);
    on<MessageReceived>(_onMessageReceived);
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    final result = await getMessages(NoParams());

    result.fold(
      (failure) => emit(ChatError(message: failure.toString())),
      (messages) => emit(ChatLoaded(messages: messages)),
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      // Create the message
      final message = ChatMessage(
        id: _uuid.v4(),
        text: event.text,
        author: event.author,
        createdAt: DateTime.now(),
        status: MessageStatus.sending,
      );

      // Emit sending state
      emit(MessageSending(
        messages: currentState.messages,
        pendingMessage: message,
      ));

      // Send the message
      final result = await sendMessage(SendMessageParams(message: message));

      result.fold(
        (failure) => emit(MessageSendError(
          messages: currentState.messages,
          error: failure.toString(),
        )),
        (sentMessage) {
          final updatedMessages = [...currentState.messages, sentMessage];
          emit(ChatLoaded(
            messages: updatedMessages,
            isSearching: currentState.isSearching,
            searchResults: currentState.searchResults,
            searchQuery: currentState.searchQuery,
          ));
        },
      );
    }
  }

  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      // Optimistically remove the message
      final updatedMessages = currentState.messages
          .where((message) => message.id != event.messageId)
          .toList();
      
      emit(currentState.copyWith(messages: updatedMessages));
      
      // Note: In a real implementation, you would call a delete use case here
      // and handle potential failures by reverting the optimistic update
    }
  }

  Future<void> _onMarkMessageAsRead(
    MarkMessageAsRead event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      // Update message status to read
      final updatedMessages = currentState.messages.map((message) {
        if (message.id == event.messageId) {
          return message.copyWith(status: MessageStatus.read);
        }
        return message;
      }).toList();
      
      emit(currentState.copyWith(messages: updatedMessages));
      
      // Note: In a real implementation, you would call a mark as read use case here
    }
  }

  Future<void> _onSearchMessages(
    SearchMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      if (event.query.isEmpty) {
        emit(currentState.copyWith(
          isSearching: false,
          searchResults: [],
          searchQuery: '',
        ));
        return;
      }

      // Perform local search (in a real app, you might want a search use case)
      final searchResults = currentState.messages
          .where((message) => 
              message.text.toLowerCase().contains(event.query.toLowerCase()))
          .toList();

      emit(currentState.copyWith(
        isSearching: true,
        searchResults: searchResults,
        searchQuery: event.query,
      ));
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      emit(currentState.copyWith(
        isSearching: false,
        searchResults: [],
        searchQuery: '',
      ));
    }
  }

  Future<void> _onMessageReceived(
    MessageReceived event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      // Check if message already exists to avoid duplicates
      final messageExists = currentState.messages
          .any((message) => message.id == event.message.id);
      
      if (!messageExists) {
        final updatedMessages = [...currentState.messages, event.message];
        emit(currentState.copyWith(messages: updatedMessages));
      }
    }
  }

  @override
  Future<void> close() {
    _messageStreamSubscription.cancel();
    return super.close();
  }
} 
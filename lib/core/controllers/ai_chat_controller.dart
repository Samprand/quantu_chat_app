import 'dart:async';
import 'dart:developer';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

import '../enums/connection_status.dart';
import '../../domain/repositories/websocket_chat_repository.dart';
import '../../data/dtos/websocket/send_message_dto.dart';

class AIChatController {
  final WebSocketChatRepository _repository;
  final String _userId;
  final Uuid _uuid = const Uuid();
  
  final List<types.Message> _messages = [];
  final StreamController<List<types.Message>> _messagesController = 
      StreamController<List<types.Message>>.broadcast();
  
  // Streaming message management
  final Map<String, String> _streamingMessages = {}; // messageId -> accumulated content
  final Map<String, types.Message> _streamingMessageObjects = {}; // messageId -> message object
  String? _currentStreamingMessageId; // Track the current streaming message
  
  String? _currentConversationId;
  bool _disposed = false;
  late StreamSubscription _messageStartSub;
  late StreamSubscription _messageChunkSub;
  late StreamSubscription _messageCompleteSub;
  late StreamSubscription _messageErrorSub;
  late StreamSubscription _receivedMessageSub;

  // AI Agent info
  final types.User _aiAgent = const types.User(
    id: 'quantu_ai_agent',
    firstName: 'Quantu',
    lastName: 'AI',
    imageUrl: 'https://i.pinimg.com/474x/7d/4a/cc/7d4accbe1801b59f281602c475fd2c15.jpg', // Rambo avatar
  );

  AIChatController({
    required WebSocketChatRepository repository,
    required String userId,
  }) : _repository = repository, _userId = userId {
    _setupEventListeners();
  }

  // Getters
  List<types.Message> get messages => List.unmodifiable(_messages);
  Stream<List<types.Message>> get messagesStream => _messagesController.stream;
  Stream<ConnectionStatus> get connectionStatusStream => _repository.connectionStatusStream;
  ConnectionStatus get connectionStatus => _repository.connectionStatus;
  bool get isConnected => _repository.isConnected;
  String? get conversationId => _currentConversationId;

  void _setupEventListeners() {
    // Listen for AI message start (beginning of streaming)
    _messageStartSub = _repository.messageStartStream.listen((messageStart) {
      log('🎧 AI Chat Controller: messageStartStream received!');
      print('🎧 AI Chat Controller: messageStartStream received!');
      
      // Generate a unique messageId for this streaming session
      _currentStreamingMessageId = _uuid.v4();
      log('🚀 AI started responding - Message ID: $_currentStreamingMessageId');
      print('🚀 AI started responding - Message ID: $_currentStreamingMessageId');
      
      // Create a new message with empty content for streaming
      final streamingMessage = types.TextMessage(
        author: _aiAgent,
        createdAt: messageStart.timestamp.millisecondsSinceEpoch,
        id: _currentStreamingMessageId!,
        text: '', // Will be filled as chunks arrive
      );
      
      _streamingMessages[_currentStreamingMessageId!] = '';
      _streamingMessageObjects[_currentStreamingMessageId!] = streamingMessage;
      
      log('📋 AI Chat Controller: Adding empty streaming message to UI');
      print('📋 AI Chat Controller: Adding empty streaming message to UI');
      
      // Add the empty message to the list
      _addMessageToList(streamingMessage);
      
      log('✅ AI Chat Controller: Streaming message added to UI');
      print('✅ AI Chat Controller: Streaming message added to UI');
    });

    // Listen for AI message chunks (streaming content)
    _messageChunkSub = _repository.messageChunkStream.listen((messageChunk) {
      log('📝 AI chunk received: "${messageChunk.content}" (length: ${messageChunk.content.length})');
      
      // Use current streaming message ID
      if (_currentStreamingMessageId != null && _streamingMessages.containsKey(_currentStreamingMessageId!)) {
        // Skip empty content chunks
        if (messageChunk.content.trim().isEmpty) {
          log('⏭️ Skipping empty chunk');
          return;
        }
        
        // Accumulate the content
        final previousLength = _streamingMessages[_currentStreamingMessageId!]!.length;
        _streamingMessages[_currentStreamingMessageId!] = _streamingMessages[_currentStreamingMessageId!]! + messageChunk.content;
        final newLength = _streamingMessages[_currentStreamingMessageId!]!.length;
        
        log('📈 Content accumulated: $previousLength → $newLength chars');
        
        // Update the message object
        final originalMessage = _streamingMessageObjects[_currentStreamingMessageId!];
        if (originalMessage is types.TextMessage) {
          final updatedMessage = types.TextMessage(
            author: originalMessage.author,
            createdAt: originalMessage.createdAt,
            id: originalMessage.id,
            text: _streamingMessages[_currentStreamingMessageId!]!,
          );
          
          _streamingMessageObjects[_currentStreamingMessageId!] = updatedMessage;
          _updateMessageInList(updatedMessage);
          log('🔄 UI updated with streaming content');
        }
      } else {
        log('⚠️ No streaming message in progress to update');
      }
    });

    // Listen for AI message completion
    _messageCompleteSub = _repository.messageCompleteStream.listen((messageComplete) {
      log('✅ AI message completed: "${messageComplete.fullContent}"');
      
      if (_currentStreamingMessageId != null) {
        // Use the accumulated content or the fullContent from server
        final accumulatedContent = _streamingMessages[_currentStreamingMessageId!] ?? '';
        final finalContent = messageComplete.fullContent.isNotEmpty 
            ? messageComplete.fullContent 
            : accumulatedContent;
        
        log('📋 Final content: accumulated=${accumulatedContent.length} chars, server=${messageComplete.fullContent.length} chars');
        
        // Final message with complete content
        final finalMessage = types.TextMessage(
          author: _aiAgent,
          createdAt: messageComplete.timestamp.millisecondsSinceEpoch,
          id: _currentStreamingMessageId!,
          text: finalContent,
        );
        
        // Clean up streaming data
        _streamingMessages.remove(_currentStreamingMessageId!);
        _streamingMessageObjects.remove(_currentStreamingMessageId!);
        _currentStreamingMessageId = null;
        
        // Update with final message
        _updateMessageInList(finalMessage);
        log('🏁 Streaming session completed and cleaned up');
      } else {
        log('⚠️ Message completion received but no streaming session active');
      }
    });

    // Listen for AI message errors
    _messageErrorSub = _repository.messageErrorStream.listen((messageError) {
      log('AI message error: ${messageError.error}');
      
      if (_currentStreamingMessageId != null) {
        // Create error message
        final errorMessage = types.TextMessage(
          author: _aiAgent,
          createdAt: messageError.timestamp.millisecondsSinceEpoch,
          id: _currentStreamingMessageId!,
          text: '⚠️ Error: ${messageError.error}',
        );
        
        // Clean up streaming data
        _streamingMessages.remove(_currentStreamingMessageId!);
        _streamingMessageObjects.remove(_currentStreamingMessageId!);
        _currentStreamingMessageId = null;
        
        // Update with error message
        _updateMessageInList(errorMessage);
      }
    });

    // Listen for complete AI messages (non-streaming)
    _receivedMessageSub = _repository.receivedMessageStream.listen((receivedMessage) {
      log('🎧 AI Chat Controller: receivedMessageStream received!');
      print('🎧 AI Chat Controller: receivedMessageStream received!');
      log('📨 Complete AI message received: ${receivedMessage.content}');
      print('📨 Complete AI message received: ${receivedMessage.content}');
      log('📋 AI Chat Controller: Message type: ${receivedMessage.type}');
      print('📋 AI Chat Controller: Message type: ${receivedMessage.type}');
      
      // Filter out user messages - server echoes back user messages, but we already add them to UI
      if (receivedMessage.type == 'user') {
        log('⏭️ AI Chat Controller: Skipping user message echo from server');
        print('⏭️ AI Chat Controller: Skipping user message echo from server');
        return;
      }
      
      // If we have a streaming message in progress, update it with the complete content
      if (_currentStreamingMessageId != null && _streamingMessageObjects.containsKey(_currentStreamingMessageId!)) {
        log('🔄 AI Chat Controller: Updating existing streaming message');
        print('🔄 AI Chat Controller: Updating existing streaming message');
        
        final finalMessage = types.TextMessage(
          author: _aiAgent,
          createdAt: receivedMessage.timestamp.millisecondsSinceEpoch,
          id: _currentStreamingMessageId!,
          text: receivedMessage.content,
        );
        
        // Clean up streaming data
        _streamingMessages.remove(_currentStreamingMessageId!);
        _streamingMessageObjects.remove(_currentStreamingMessageId!);
        _currentStreamingMessageId = null;
        
        // Update with final message
        _updateMessageInList(finalMessage);
        log('✅ AI Chat Controller: Streaming message updated in UI');
        print('✅ AI Chat Controller: Streaming message updated in UI');
      } else {
        log('🆕 AI Chat Controller: Adding new complete message');
        print('🆕 AI Chat Controller: Adding new complete message');
        
        // No streaming in progress, add as new message
        final aiMessage = types.TextMessage(
          author: _aiAgent,
          createdAt: receivedMessage.timestamp.millisecondsSinceEpoch,
          id: _uuid.v4(),
          text: receivedMessage.content,
        );
        
        _addMessageToList(aiMessage);
        log('✅ AI Chat Controller: Complete message added to UI');
        print('✅ AI Chat Controller: Complete message added to UI');
      }
    });
  }

  Future<void> connect() async {
    log('🎯 AI Chat Controller: Starting connection for user: $_userId');
    print('🎯 AI Chat Controller: Starting connection for user: $_userId');
    
    final result = await _repository.connect(_userId);
    result.fold(
      (failure) {
        log('❌ AI Chat Controller: Failed to connect: $failure');
        print('❌ AI Chat Controller: Failed to connect: $failure');
      },
      (_) {
        log('✅ AI Chat Controller: Connected to AI agent successfully');
        print('✅ AI Chat Controller: Connected to AI agent successfully');
      },
    );
    
    // Create or join a conversation
    log('🏗️ AI Chat Controller: Creating conversation...');
    print('🏗️ AI Chat Controller: Creating conversation...');
    await _createConversation();
  }

  Future<void> _createConversation() async {
    final result = await _repository.createConversation();
    result.fold(
      (failure) => log('Failed to create conversation: $failure'),
      (conversationId) {
        _currentConversationId = conversationId;
        log('Conversation created: $conversationId');
      },
    );
  }

  Future<void> sendMessage(String text) async {
    log('📝 AI Chat Controller: Sending message: "$text"');
    print('📝 AI Chat Controller: Sending message: "$text"');
    
    if (!_repository.isConnected) {
      log('❌ AI Chat Controller: Not connected to AI agent');
      print('❌ AI Chat Controller: Not connected to AI agent');
      return;
    }

    log('✅ AI Chat Controller: Repository is connected, proceeding...');
    print('✅ AI Chat Controller: Repository is connected, proceeding...');

    // Create user message
    final userMessage = types.TextMessage(
      author: types.User(id: _userId, firstName: 'You'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: text,
    );

    log('👤 AI Chat Controller: Adding user message to UI');
    print('👤 AI Chat Controller: Adding user message to UI');
    
    // Add user message to UI immediately
    _addMessageToList(userMessage);

    // Send to AI agent
    final sendMessageDTO = SendMessageDTO(
      message: text,
      userId: _userId,
      conversationId: _currentConversationId,
      timestamp: DateTime.now(),
    );

    log('🚀 AI Chat Controller: Calling repository.sendMessage()');
    print('🚀 AI Chat Controller: Calling repository.sendMessage()');
    
    final result = await _repository.sendMessage(sendMessageDTO);
    result.fold(
      (failure) {
        log('❌ AI Chat Controller: Failed to send message: $failure');
        print('❌ AI Chat Controller: Failed to send message: $failure');
        // Could add error handling here - maybe show a retry button
        _addErrorMessage('Failed to send message. Please try again.');
      },
      (response) {
        log('✅ AI Chat Controller: Message sent successfully: ${response.messageId}');
        print('✅ AI Chat Controller: Message sent successfully: ${response.messageId}');
        // Message sent successfully, AI response will come through streams
      },
    );
  }

  void _addMessageToList(types.Message message) {
    log('📝 AI Chat Controller: _addMessageToList called with message ID: ${message.id}');
    print('📝 AI Chat Controller: _addMessageToList called with message ID: ${message.id}');
    
    _messages.insert(0, message); // Insert at beginning (newest first)
    
    log('📊 AI Chat Controller: Messages list now has ${_messages.length} messages');
    print('📊 AI Chat Controller: Messages list now has ${_messages.length} messages');
    
    _notifyListeners();
    
    log('✅ AI Chat Controller: UI notified of new message');
    print('✅ AI Chat Controller: UI notified of new message');
  }

  void _updateMessageInList(types.Message updatedMessage) {
    log('🔄 AI Chat Controller: _updateMessageInList called with message ID: ${updatedMessage.id}');
    print('🔄 AI Chat Controller: _updateMessageInList called with message ID: ${updatedMessage.id}');
    
    final index = _messages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      log('📍 AI Chat Controller: Found message at index $index, updating...');
      print('📍 AI Chat Controller: Found message at index $index, updating...');
      
      _messages[index] = updatedMessage;
      _notifyListeners();
      
      log('✅ AI Chat Controller: Message updated and UI notified');
      print('✅ AI Chat Controller: Message updated and UI notified');
    } else {
      log('⚠️ AI Chat Controller: Message with ID ${updatedMessage.id} not found in list');
      print('⚠️ AI Chat Controller: Message with ID ${updatedMessage.id} not found in list');
    }
  }

  void _addErrorMessage(String errorText) {
    final errorMessage = types.TextMessage(
      author: _aiAgent,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: '⚠️ $errorText',
    );
    _addMessageToList(errorMessage);
  }

  void removeMessage(String messageId) {
    _messages.removeWhere((message) => message.id == messageId);
    _notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _streamingMessages.clear();
    _streamingMessageObjects.clear();
    _currentStreamingMessageId = null;
    _notifyListeners();
  }

  void _notifyListeners() {
    log('📢 AI Chat Controller: _notifyListeners called');
    print('📢 AI Chat Controller: _notifyListeners called');
    
    if (!_disposed) {
      log('📡 AI Chat Controller: Adding ${_messages.length} messages to stream');
      print('📡 AI Chat Controller: Adding ${_messages.length} messages to stream');
      
      _messagesController.add(List.from(_messages));
      
      log('✅ AI Chat Controller: Messages stream updated');
      print('✅ AI Chat Controller: Messages stream updated');
    } else {
      log('⚠️ AI Chat Controller: Cannot notify - controller is disposed');
      print('⚠️ AI Chat Controller: Cannot notify - controller is disposed');
    }
  }

  Future<void> disconnect() async {
    await _repository.disconnect();
  }

  void dispose() {
    _disposed = true;
    _messageStartSub.cancel();
    _messageChunkSub.cancel();
    _messageCompleteSub.cancel();
    _messageErrorSub.cancel();
    _receivedMessageSub.cancel();
    _messagesController.close();
    
    // Clean up streaming data
    _streamingMessages.clear();
    _streamingMessageObjects.clear();
    _currentStreamingMessageId = null;
  }

  // Additional methods for enhanced functionality
  void sendTyping() {
    if (_currentConversationId != null) {
      _repository.sendTyping(_currentConversationId!);
    }
  }

  void sendStopTyping() {
    if (_currentConversationId != null) {
      _repository.sendStopTyping(_currentConversationId!);
    }
  }

  // Method to reconnect if connection is lost
  Future<void> reconnect() async {
    await disconnect();
    await connect();
  }
} 
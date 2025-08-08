import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/failures.dart';
import '../../core/enums/connection_status.dart';
import '../../core/services/websocket_client.dart';
import '../../core/constants/websocket_events.dart';
import '../../domain/repositories/websocket_chat_repository.dart';
import '../dtos/websocket/send_message_dto.dart';
import '../dtos/websocket/received_message_dto.dart';

class WebSocketChatRepositoryImpl implements WebSocketChatRepository {
  final WebSocketClient _webSocketClient;
  final Uuid _uuid = const Uuid();

  // Stream controllers for different message events
  final StreamController<MessageStartDTO> _messageStartController = 
      StreamController<MessageStartDTO>.broadcast();
  final StreamController<MessageChunkDTO> _messageChunkController = 
      StreamController<MessageChunkDTO>.broadcast();
  final StreamController<MessageCompleteDTO> _messageCompleteController = 
      StreamController<MessageCompleteDTO>.broadcast();
  final StreamController<MessageErrorDTO> _messageErrorController = 
      StreamController<MessageErrorDTO>.broadcast();
  final StreamController<ReceivedMessageDTO> _receivedMessageController = 
      StreamController<ReceivedMessageDTO>.broadcast();
  final StreamController<String> _typingController = 
      StreamController<String>.broadcast();

  // Note: Server processes messages immediately without confirmation responses

  WebSocketChatRepositoryImpl({WebSocketClient? webSocketClient})
      : _webSocketClient = webSocketClient ?? WebSocketClient();

  void _setupEventListeners() {
    // Add catch-all event listener for debugging
    _webSocketClient.on<Map<String, dynamic>>(
      'connected',
      (data) {
        log('🔍 Connection response received:');
        log('📦 Session ID: ${data['session_id']}');
        log('👤 User ID: ${data['user_id']}');
        log('👩‍💼 Seller Name: ${data['seller_name']}');
        log('🏢 Company: ${data['company_description']}');
        log('🎯 Focus Area: ${data['focus_area']}');
        log('⏰ Timestamp: ${data['timestamp']}');
        
        print('🔍 Connection response received:');
        print('📦 Session ID: ${data['session_id']}');
        print('👤 User ID: ${data['user_id']}');
        print('👩‍💼 Seller Name: ${data['seller_name']}');
        print('🏢 Company: ${data['company_description']}');
        print('🎯 Focus Area: ${data['focus_area']}');
        print('⏰ Timestamp: ${data['timestamp']}');
      },
    );

    // Message events
    _webSocketClient.on<Map<String, dynamic>>(
      WebSocketEvents.messageStart,
      (data) {
        log('🔄 Repository: messageStart handler triggered');
        print('🔄 Repository: messageStart handler triggered');
        try {
          log('Raw message_start received: $data');
          print('Raw message_start received: $data');
          final messageStart = MessageStartDTO.fromJson(data);
          _messageStartController.add(messageStart);
          log('✅ Repository: Message start processed: ${messageStart.type}');
          print('✅ Repository: Message start processed: ${messageStart.type}');
        } catch (e) {
          log('❌ Repository: Error parsing message start: $e, data: $data');
          print('❌ Repository: Error parsing message start: $e, data: $data');
        }
      },
    );

    _webSocketClient.on<Map<String, dynamic>>(
      WebSocketEvents.messageChunk,
      (data) {
        log('🔄 Repository: messageChunk handler triggered');
        print('🔄 Repository: messageChunk handler triggered');
        try {
          log('Raw message_chunk received: $data');
          print('Raw message_chunk received: $data');
          final messageChunk = MessageChunkDTO.fromJson(data);
          _messageChunkController.add(messageChunk);
          log('✅ Repository: Message chunk processed: "${messageChunk.content}"');
          print('✅ Repository: Message chunk processed: "${messageChunk.content}"');
        } catch (e) {
          log('❌ Repository: Error parsing message chunk: $e, data: $data');
          print('❌ Repository: Error parsing message chunk: $e, data: $data');
        }
      },
    );

    _webSocketClient.on<Map<String, dynamic>>(
      WebSocketEvents.messageComplete,
      (data) {
        log('🔄 Repository: messageComplete handler triggered');
        print('🔄 Repository: messageComplete handler triggered');
        try {
          log('Raw message_complete received: $data');
          print('Raw message_complete received: $data');
          final messageComplete = MessageCompleteDTO.fromJson(data);
          _messageCompleteController.add(messageComplete);
          log('✅ Repository: Message complete processed: "${messageComplete.fullContent}"');
          print('✅ Repository: Message complete processed: "${messageComplete.fullContent}"');
        } catch (e) {
          log('❌ Repository: Error parsing message complete: $e, data: $data');
          print('❌ Repository: Error parsing message complete: $e, data: $data');
        }
      },
    );

    _webSocketClient.on<Map<String, dynamic>>(
      WebSocketEvents.messageError,
      (data) {
        log('🔄 Repository: messageError handler triggered');
        print('🔄 Repository: messageError handler triggered');
        try {
          log('Raw message_error received: $data');
          print('Raw message_error received: $data');
          final messageError = MessageErrorDTO.fromJson(data);
          _messageErrorController.add(messageError);
          log('✅ Repository: Message error processed: "${messageError.error}"');
          print('✅ Repository: Message error processed: "${messageError.error}"');
        } catch (e) {
          log('❌ Repository: Error parsing message error: $e, data: $data');
          print('❌ Repository: Error parsing message error: $e, data: $data');
        }
      },
    );

    _webSocketClient.on<Map<String, dynamic>>(
      WebSocketEvents.receiveMessage,
      (data) {
        log('🔄 Repository: receiveMessage handler triggered');
        print('🔄 Repository: receiveMessage handler triggered');
        try {
          log('Raw receive_message received: $data');
          print('Raw receive_message received: $data');
          final receivedMessage = ReceivedMessageDTO.fromJson(data);
          log('✅ Repository: Parsed received message successfully');
          print('✅ Repository: Parsed received message successfully');
          log('📝 Repository: Message content: "${receivedMessage.content}"');
          print('📝 Repository: Message content: "${receivedMessage.content}"');
          _receivedMessageController.add(receivedMessage);
          log('✅ Repository: Received message processed: "${receivedMessage.content}"');
          print('✅ Repository: Received message processed: "${receivedMessage.content}"');
        } catch (e) {
          log('❌ Repository: Error parsing received message: $e, data: $data');
          print('❌ Repository: Error parsing received message: $e, data: $data');
        }
      },
    );

    // Note: Server doesn't send send_message_response, it immediately starts processing

    // Typing events
    _webSocketClient.on<Map<String, dynamic>>(
      WebSocketEvents.typing,
      (data) {
        try {
          final userId = data['userId'] as String?;
          if (userId != null) {
            _typingController.add(userId);
          }
        } catch (e) {
          log('Error parsing typing event: $e');
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> connect(String userId) async {
    try {
      await _webSocketClient.connect(
        authData: {
          'userId': userId,
          'timestamp': DateTime.now().toIso8601String(),
        },
        sellerName: 'Sarah Johnson',  // Example seller name
        companyDescription: '''
          TechVision Solutions is a cutting-edge technology consulting firm 
          specializing in digital transformation, AI implementation, and 
          enterprise software solutions. We help businesses leverage modern 
          technology to drive growth and efficiency.
        '''.trim(),
        focusArea: 'Enterprise Digital Transformation and AI Solutions',
      );
      
      if (_webSocketClient.isConnected) {
        _setupEventListeners(); // Setup listeners after connection
        return const Right(null);
      } else {
        return const Left(NetworkFailure('Failed to establish WebSocket connection'));
      }
    } catch (e) {
      log('WebSocket connection error: $e');
      return Left(NetworkFailure('Connection failed: $e'));
    }
  }

  @override
  Future<void> disconnect() async {
    _webSocketClient.disconnect();
  }

  @override
  Stream<ConnectionStatus> get connectionStatusStream => 
      _webSocketClient.connectionStatusStream;

  @override
  ConnectionStatus get connectionStatus => _webSocketClient.connectionStatus;

  @override
  bool get isConnected => _webSocketClient.isConnected;

  @override
  Future<Either<Failure, SendMessageResponseDTO>> sendMessage(SendMessageDTO message) async {
    if (!_webSocketClient.isConnected) {
      return const Left(NetworkFailure('Not connected to WebSocket'));
    }

    try {
      final messageId = _uuid.v4();
      
      // Send message to server (simplified structure to match what server expects)
      final messageData = {
        'message': message.message,
        'userId': message.userId,
        'timestamp': message.timestamp.toIso8601String(),
      };

      log('📤 Sending message: $messageData');

      // Send message
      _webSocketClient.emit(WebSocketEvents.sendMessage, messageData);

      // Return success immediately since server processes messages without confirmation response
      final response = SendMessageResponseDTO(
        messageId: messageId,
        success: true,
        metadata: {'sentAt': DateTime.now().toIso8601String()},
      );

      log('✅ Message sent successfully');
      return Right(response);
    } catch (e) {
      log('❌ Error sending message: $e');
      return Left(ServerFailure('Failed to send message: $e'));
    }
  }

  @override
  Stream<MessageStartDTO> get messageStartStream => _messageStartController.stream;

  @override
  Stream<MessageChunkDTO> get messageChunkStream => _messageChunkController.stream;

  @override
  Stream<MessageCompleteDTO> get messageCompleteStream => _messageCompleteController.stream;

  @override
  Stream<MessageErrorDTO> get messageErrorStream => _messageErrorController.stream;

  @override
  Stream<ReceivedMessageDTO> get receivedMessageStream => _receivedMessageController.stream;

  @override
  void sendTyping(String conversationId) {
    if (_webSocketClient.isConnected) {
      _webSocketClient.emit(WebSocketEvents.typing, {
        'conversationId': conversationId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  @override
  void sendStopTyping(String conversationId) {
    if (_webSocketClient.isConnected) {
      _webSocketClient.emit(WebSocketEvents.stopTyping, {
        'conversationId': conversationId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  @override
  Stream<String> get typingStream => _typingController.stream;

  @override
  Future<Either<Failure, String>> createConversation() async {
    if (!_webSocketClient.isConnected) {
      return const Left(NetworkFailure('Not connected to WebSocket'));
    }

    try {
      final conversationId = _uuid.v4();
      final completer = Completer<String>();

      // Listen for conversation created event
      _webSocketClient.once<Map<String, dynamic>>(
        'conversation_created',
        (data) {
          final createdId = data['conversationId'] as String;
          completer.complete(createdId);
        },
      );

      // Request conversation creation
      _webSocketClient.emit('create_conversation', {
        'conversationId': conversationId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      final result = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw const TimeoutException('Conversation creation timeout', Duration(seconds: 10)),
      );

      return Right(result);
    } catch (e) {
      log('Error creating conversation: $e');
      return Left(ServerFailure('Failed to create conversation: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> joinConversation(String conversationId) async {
    if (!_webSocketClient.isConnected) {
      return const Left(NetworkFailure('Not connected to WebSocket'));
    }

    try {
      _webSocketClient.emit('join_conversation', {
        'conversationId': conversationId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return const Right(null);
    } catch (e) {
      log('Error joining conversation: $e');
      return Left(ServerFailure('Failed to join conversation: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveConversation(String conversationId) async {
    if (!_webSocketClient.isConnected) {
      return const Left(NetworkFailure('Not connected to WebSocket'));
    }

    try {
      _webSocketClient.emit('leave_conversation', {
        'conversationId': conversationId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return const Right(null);
    } catch (e) {
      log('Error leaving conversation: $e');
      return Left(ServerFailure('Failed to leave conversation: $e'));
    }
  }

  void dispose() {
    _messageStartController.close();
    _messageChunkController.close();
    _messageCompleteController.close();
    _messageErrorController.close();
    _receivedMessageController.close();
    _typingController.close();
  }
}

class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (${timeout.inSeconds}s)';
} 
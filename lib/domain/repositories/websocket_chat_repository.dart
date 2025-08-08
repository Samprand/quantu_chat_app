import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/enums/connection_status.dart';
import '../../data/dtos/websocket/send_message_dto.dart';
import '../../data/dtos/websocket/received_message_dto.dart';

abstract class WebSocketChatRepository {
  // Connection management
  Future<Either<Failure, void>> connect(String userId);
  Future<void> disconnect();
  Stream<ConnectionStatus> get connectionStatusStream;
  ConnectionStatus get connectionStatus;
  bool get isConnected;

  // Message sending
  Future<Either<Failure, SendMessageResponseDTO>> sendMessage(SendMessageDTO message);

  // Message receiving (streaming support)
  Stream<MessageStartDTO> get messageStartStream;
  Stream<MessageChunkDTO> get messageChunkStream;
  Stream<MessageCompleteDTO> get messageCompleteStream;
  Stream<MessageErrorDTO> get messageErrorStream;
  Stream<ReceivedMessageDTO> get receivedMessageStream;

  // Typing indicators
  void sendTyping(String conversationId);
  void sendStopTyping(String conversationId);
  Stream<String> get typingStream; // Returns user ID who is typing

  // Conversation management
  Future<Either<Failure, String>> createConversation();
  Future<Either<Failure, void>> joinConversation(String conversationId);
  Future<Either<Failure, void>> leaveConversation(String conversationId);
} 
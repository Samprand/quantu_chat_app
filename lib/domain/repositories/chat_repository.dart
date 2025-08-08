import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatMessage>>> getMessages();
  Future<Either<Failure, ChatMessage>> sendMessage(ChatMessage message);
  Future<Either<Failure, void>> deleteMessage(String messageId);
  Future<Either<Failure, ChatMessage>> updateMessage(ChatMessage message);
  Stream<ChatMessage> getMessageStream();
  Future<Either<Failure, void>> markAsRead(String messageId);
  Future<Either<Failure, List<ChatMessage>>> searchMessages(String query);
} 
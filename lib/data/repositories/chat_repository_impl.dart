import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;
  
  late final StreamController<ChatMessage> _messageStreamController;
  late final StreamSubscription _remoteStreamSubscription;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  }) {
    _messageStreamController = StreamController<ChatMessage>.broadcast();
    _setupRemoteMessageStream();
  }

  void _setupRemoteMessageStream() {
    _remoteStreamSubscription = remoteDataSource.getMessageStream().listen(
      (message) {
        // Cache the new message locally
        localDataSource.cacheMessage(message);
        // Forward to the main stream
        _messageStreamController.add(message);
      },
      onError: (error) {
        // Handle stream errors if needed
      },
    );
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages() async {
    try {
      // Try to get cached messages first for immediate display
      final cachedMessages = await localDataSource.getCachedMessages();
      
      // Attempt to fetch fresh messages from remote
      try {
        final remoteMessages = await remoteDataSource.getMessages();
        
        // Cache the fresh messages
        await localDataSource.cacheMessages(remoteMessages);
        
        return Right(remoteMessages);
      } catch (e) {
        // If remote fails, return cached messages if available
        if (cachedMessages.isNotEmpty) {
          return Right(cachedMessages);
        } else {
          return const Left(NetworkFailure('Failed to fetch messages and no cached data available'));
        }
      }
    } catch (e) {
      return Left(CacheFailure('Failed to access cached messages: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(ChatMessage message) async {
    try {
      final messageModel = ChatMessageModel.fromEntity(message);
      
      // Optimistically add to cache immediately
      await localDataSource.cacheMessage(messageModel);
      
      // Send to remote
      final sentMessage = await remoteDataSource.sendMessage(messageModel);
      
      // Update cache with confirmed message
      await localDataSource.cacheMessage(sentMessage);
      
      return Right(sentMessage);
    } catch (e) {
      return Left(ServerFailure('Failed to send message: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    try {
      // Delete from remote first
      await remoteDataSource.deleteMessage(messageId);
      
      // Then delete from cache
      await localDataSource.deleteCachedMessage(messageId);
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete message: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> updateMessage(ChatMessage message) async {
    try {
      final messageModel = ChatMessageModel.fromEntity(message);
      
      // Update on remote
      final updatedMessage = await remoteDataSource.updateMessage(messageModel);
      
      // Update cache
      await localDataSource.cacheMessage(updatedMessage);
      
      return Right(updatedMessage);
    } catch (e) {
      return Left(ServerFailure('Failed to update message: ${e.toString()}'));
    }
  }

  @override
  Stream<ChatMessage> getMessageStream() {
    return _messageStreamController.stream;
  }

  @override
  Future<Either<Failure, void>> markAsRead(String messageId) async {
    try {
      // In a real implementation, this would make an API call to mark message as read
      // For now, we'll simulate this by updating the message status
      final cachedMessages = await localDataSource.getCachedMessages();
      final messageIndex = cachedMessages.indexWhere((m) => m.id == messageId);
      
      if (messageIndex != -1) {
        final updatedMessage = ChatMessageModel(
          id: cachedMessages[messageIndex].id,
          text: cachedMessages[messageIndex].text,
          author: cachedMessages[messageIndex].author,
          createdAt: cachedMessages[messageIndex].createdAt,
          type: cachedMessages[messageIndex].type,
          status: MessageStatus.read,
        );
        
        await localDataSource.cacheMessage(updatedMessage);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to mark message as read: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> searchMessages(String query) async {
    try {
      final cachedMessages = await localDataSource.getCachedMessages();
      final filteredMessages = cachedMessages
          .where((message) => 
              message.text.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      return Right(filteredMessages);
    } catch (e) {
      return Left(CacheFailure('Failed to search messages: ${e.toString()}'));
    }
  }

  void dispose() {
    _remoteStreamSubscription.cancel();
    _messageStreamController.close();
  }
} 
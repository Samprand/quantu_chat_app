import 'dart:async';
import 'dart:math';

import '../models/chat_message_model.dart';
import '../../domain/entities/chat_message.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatMessageModel>> getMessages();
  Future<ChatMessageModel> sendMessage(ChatMessageModel message);
  Future<void> deleteMessage(String messageId);
  Future<ChatMessageModel> updateMessage(ChatMessageModel message);
  Stream<ChatMessageModel> getMessageStream();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  // Simulated message store
  final List<ChatMessageModel> _messages = [];
  final StreamController<ChatMessageModel> _messageStreamController = 
      StreamController<ChatMessageModel>.broadcast();

  // Mock users
  final ChatUserModel _currentUser = const ChatUserModel(
    id: 'user_1',
    firstName: 'John',
    lastName: 'Doe',
    imageUrl: 'https://via.placeholder.com/150/0000FF/FFFFFF?text=JD',
  );

  final ChatUserModel _otherUser = const ChatUserModel(
    id: 'user_2',
    firstName: 'Jane',
    lastName: 'Smith',
    imageUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=JS',
  );

  ChatRemoteDataSourceImpl() {
    _initializeMockData();
    _startMockMessageSimulation();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    
    _messages.addAll([
      ChatMessageModel(
        id: '1',
        text: 'Hello! How are you?',
        author: _otherUser,
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      ChatMessageModel(
        id: '2',
        text: 'Hi there! I\'m doing great, thanks for asking!',
        author: _currentUser,
        createdAt: now.subtract(const Duration(minutes: 25)),
      ),
      ChatMessageModel(
        id: '3',
        text: 'That\'s wonderful to hear!',
        author: _otherUser,
        createdAt: now.subtract(const Duration(minutes: 20)),
      ),
    ]);
  }

  void _startMockMessageSimulation() {
    // Simulate receiving messages from other user
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (Random().nextBool()) {
        final mockMessages = [
          'How\'s your day going?',
          'What are you working on?',
          'Let\'s catch up soon!',
          'Hope you\'re having a great time!',
          'Any exciting plans for the weekend?',
        ];
        
        final randomMessage = mockMessages[Random().nextInt(mockMessages.length)];
        final newMessage = ChatMessageModel(
          id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
          text: randomMessage,
          author: _otherUser,
          createdAt: DateTime.now(),
        );
        
        _messages.add(newMessage);
        _messageStreamController.add(newMessage);
      }
    });
  }

  @override
  Future<List<ChatMessageModel>> getMessages() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Sort messages by creation time
    _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return List.from(_messages);
  }

  @override
  Future<ChatMessageModel> sendMessage(ChatMessageModel message) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final sentMessage = ChatMessageModel(
      id: message.id,
      text: message.text,
      author: message.author,
      createdAt: DateTime.now(),
      type: message.type,
      status: MessageStatus.sent,
    );
    
    _messages.add(sentMessage);
    _messageStreamController.add(sentMessage);
    
    return sentMessage;
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _messages.removeWhere((message) => message.id == messageId);
  }

  @override
  Future<ChatMessageModel> updateMessage(ChatMessageModel message) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      _messages[index] = message;
      return message;
    }
    throw Exception('Message not found');
  }

  @override
  Stream<ChatMessageModel> getMessageStream() {
    return _messageStreamController.stream;
  }

  void dispose() {
    _messageStreamController.close();
  }
} 
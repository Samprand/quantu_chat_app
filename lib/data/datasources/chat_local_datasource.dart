import 'dart:convert';

import '../models/chat_message_model.dart';

abstract class ChatLocalDataSource {
  Future<List<ChatMessageModel>> getCachedMessages();
  Future<void> cacheMessages(List<ChatMessageModel> messages);
  Future<void> cacheMessage(ChatMessageModel message);
  Future<void> deleteCachedMessage(String messageId);
  Future<void> clearCache();
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  // In a real implementation, you would use SharedPreferences, SQLite, or Hive
  // For now, we'll use in-memory storage
  final Map<String, String> _storage = {};
  static const String _messagesKey = 'cached_messages';

  @override
  Future<List<ChatMessageModel>> getCachedMessages() async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate storage delay
    
    final messagesJson = _storage[_messagesKey];
    if (messagesJson == null) {
      return [];
    }

    try {
      final List<dynamic> messagesList = json.decode(messagesJson);
      return messagesList
          .map((messageJson) => ChatMessageModel.fromJson(messageJson))
          .toList();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  @override
  Future<void> cacheMessages(List<ChatMessageModel> messages) async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate storage delay
    
    final messagesJson = messages.map((message) => message.toJson()).toList();
    _storage[_messagesKey] = json.encode(messagesJson);
  }

  @override
  Future<void> cacheMessage(ChatMessageModel message) async {
    final cachedMessages = await getCachedMessages();
    
    // Remove existing message with same ID if it exists
    cachedMessages.removeWhere((m) => m.id == message.id);
    
    // Add new message
    cachedMessages.add(message);
    
    // Sort by creation time
    cachedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    await cacheMessages(cachedMessages);
  }

  @override
  Future<void> deleteCachedMessage(String messageId) async {
    final cachedMessages = await getCachedMessages();
    cachedMessages.removeWhere((message) => message.id == messageId);
    await cacheMessages(cachedMessages);
  }

  @override
  Future<void> clearCache() async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate storage delay
    _storage.remove(_messagesKey);
  }
} 
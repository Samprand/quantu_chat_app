import 'dart:async';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class SimpleChatController {
  final List<types.Message> _messages = [];
  final StreamController<List<types.Message>> _messagesController = 
      StreamController<List<types.Message>>.broadcast();

  List<types.Message> get messages => List.unmodifiable(_messages);
  Stream<List<types.Message>> get messagesStream => _messagesController.stream;

  void addMessage(types.Message message) {
    _messages.insert(0, message); // Insert at beginning (newest first)
    _messagesController.add(List.from(_messages));
  }

  void removeMessage(String messageId) {
    _messages.removeWhere((message) => message.id == messageId);
    _messagesController.add(List.from(_messages));
  }

  void updateMessage(types.Message updatedMessage) {
    final index = _messages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      _messages[index] = updatedMessage;
      _messagesController.add(List.from(_messages));
    }
  }

  void clearMessages() {
    _messages.clear();
    _messagesController.add([]);
  }

  void dispose() {
    _messagesController.close();
  }
} 
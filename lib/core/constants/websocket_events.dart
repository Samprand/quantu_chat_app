// WebSocket Events for AI Agent Communication
class WebSocketEvents {
  // Basic Socket.IO events
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String connectError = 'connect_error';
  
  // Chat-specific events
  static const String sendMessage = 'send_message';
  static const String receiveMessage = 'receive_message';
  static const String messageStart = 'message_start';
  static const String messageChunk = 'message_chunk';
  static const String messageComplete = 'message_complete';
  static const String messageError = 'message_error';
  
  // Connection management
  static const String userConnected = 'user_connected';
  static const String userDisconnected = 'user_disconnected';
  static const String typing = 'typing';
  static const String stopTyping = 'stop_typing';
} 
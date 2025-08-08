class AppConstants {
  // App Information
  static const String appName = 'Flutter Chat App';
  static const String appVersion = '1.0.0';

  // User Constants
  static const String defaultUserId = 'user_1';
  static const String defaultUserName = 'Current User';
  static const String defaultUserAvatar = 'https://via.placeholder.com/150';

  // Chat Constants
  static const int messagesLimit = 50;
  static const Duration typingTimeout = Duration(seconds: 2);

  // Storage Keys
  static const String userKey = 'user';
  static const String messagesKey = 'messages';
  static const String chatHistoryKey = 'chat_history';

  // Error Messages
  static const String networkError = 'Network connection failed';
  static const String serverError = 'Server error occurred';
  static const String cacheError = 'Cache operation failed';
  static const String unknownError = 'An unknown error occurred';
} 
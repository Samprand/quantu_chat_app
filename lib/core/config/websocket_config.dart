class WebSocketConfig {
  // TODO: Replace with your actual WebSocket server URL
  static const String defaultUrl = 'http://192.168.100.29:8000'; // Development
  // static const String defaultUrl = 'wss://your-ai-agent-server.com'; // Production
  
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration reconnectDelay = Duration(seconds: 5);
  static const int maxReconnectAttempts = 5;

  // Agent Configuration
  static const Map<String, String> defaultAgentConfig = {
    'seller_name': 'John Smith',
    'company_description': 'A leading software solutions provider specializing in AI and machine learning applications.',
    'focus_area': 'Enterprise Software Solutions',
  };
  
  static String get socketUrl {
    // You can add environment-based configuration here
    const String envUrl = String.fromEnvironment('WEBSOCKET_URL');
    return envUrl.isEmpty ? defaultUrl : envUrl;
  }

  static Map<String, String> getAgentConfig({
    String? sellerName,
    String? companyDescription,
    String? focusArea,
  }) {
    return {
      'seller_name': sellerName ?? defaultAgentConfig['seller_name']!,
      'company_description': companyDescription ?? defaultAgentConfig['company_description']!,
      'focus_area': focusArea ?? defaultAgentConfig['focus_area']!,
    };
  }
} 
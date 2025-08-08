# WebSocket AI Agent Integration

This Flutter chat app now includes a complete WebSocket integration for real-time communication with an AI agent. The implementation follows a clean architecture pattern and supports streaming responses.

## 🏗️ Architecture Overview

The WebSocket implementation is organized into the following layers:

### Core Layer
- **WebSocket Client** (`lib/core/services/websocket_client.dart`): Singleton Socket.IO client
- **AI Chat Controller** (`lib/core/controllers/ai_chat_controller.dart`): High-level chat management
- **Configuration** (`lib/core/config/websocket_config.dart`): WebSocket server configuration
- **Events** (`lib/core/constants/websocket_events.dart`): Event constants
- **Enums** (`lib/core/enums/connection_status.dart`): Connection status types

### Data Layer
- **Repository Implementation** (`lib/data/repositories/websocket_chat_repository_impl.dart`): Concrete WebSocket repository
- **DTOs** (`lib/data/dtos/websocket/`): Data transfer objects for messages

### Domain Layer
- **Repository Interface** (`lib/domain/repositories/websocket_chat_repository.dart`): Abstract repository contract

### Presentation Layer
- **AI Chat Page** (`lib/presentation/pages/ai_chat_page.dart`): UI with WebSocket integration

## 🚀 Features

### Real-time Communication
- ✅ Bidirectional messaging with AI agent
- ✅ Connection status tracking with visual indicators
- ✅ Automatic reconnection with exponential backoff
- ✅ Connection timeout handling (10 seconds)
- ✅ Typing indicators support

### AI Streaming Support
- ✅ **Message Start**: AI begins responding
- ✅ **Message Chunks**: Streaming content in real-time
- ✅ **Message Complete**: Final assembled message
- ✅ **Error Handling**: Graceful error display

### User Experience
- ✅ Beautiful connection status animations
- ✅ Real-time message updates
- ✅ Message actions (copy, delete, reply)
- ✅ Dark/light theme support
- ✅ Haptic feedback

## 🔧 Configuration

### 1. WebSocket Server URL

Update the server URL in `lib/core/config/websocket_config.dart`:

```dart
class WebSocketConfig {
  // Development
  static const String defaultUrl = 'ws://localhost:3001';
  
  // Production
  // static const String defaultUrl = 'wss://your-ai-agent-server.com';
}
```

Or set via environment variable:
```bash
flutter run --dart-define=WEBSOCKET_URL=wss://your-server.com
```

### 2. Connection Parameters

Adjust timeouts and retry settings:

```dart
static const Duration connectionTimeout = Duration(seconds: 10);
static const Duration reconnectDelay = Duration(seconds: 5);
static const int maxReconnectAttempts = 5;
```

## 📡 WebSocket Events

### Outgoing Events (Client → Server)
- `send_message`: Send user message to AI
- `typing`: User is typing
- `stop_typing`: User stopped typing
- `create_conversation`: Create new conversation
- `join_conversation`: Join existing conversation
- `leave_conversation`: Leave conversation

### Incoming Events (Server → Client)
- `message_start`: AI starts responding
- `message_chunk`: Streaming content chunk
- `message_complete`: AI finished responding
- `message_error`: Error in AI response
- `receive_message`: Complete message (non-streaming)

## 📊 Message Flow

### Sending a Message
```
User types message
     ↓
AIChatController.sendMessage()
     ↓
WebSocketChatRepository.sendMessage()
     ↓
WebSocketClient.emit('send_message')
     ↓
Server processes message
     ↓
AI generates response (streaming)
```

### Receiving AI Response (Streaming)
```
Server: 'message_start' → Empty message created in UI
     ↓
Server: 'message_chunk' → Content accumulates in real-time
     ↓
Server: 'message_chunk' → UI updates with each chunk
     ↓
Server: 'message_complete' → Final message assembled
```

## 🔌 Server Requirements

Your WebSocket server should implement the following event handlers:

### Authentication
```javascript
io.on('connection', (socket) => {
  const { userId } = socket.handshake.auth;
  // Authenticate user
});
```

### Message Handling
```javascript
socket.on('send_message', async (data) => {
  const { message, userId, conversationId } = data;
  
  // Send confirmation
  socket.emit('send_message_response', {
    messageId: generateId(),
    success: true
  });
  
  // Start AI response
  socket.emit('message_start', {
    messageId: generateId(),
    conversationId,
    agentId: 'quantu_ai_agent',
    timestamp: new Date().toISOString()
  });
  
  // Stream AI response
  for (const chunk of aiResponse) {
    socket.emit('message_chunk', {
      messageId,
      conversationId,
      content: chunk,
      chunkIndex: index,
      timestamp: new Date().toISOString()
    });
  }
  
  // Complete response
  socket.emit('message_complete', {
    messageId,
    conversationId,
    fullContent: completeResponse,
    agentId: 'quantu_ai_agent',
    totalChunks: chunkCount,
    timestamp: new Date().toISOString()
  });
});
```

## 🎯 Usage

### Basic Setup
```dart
// Initialize dependency injection
await di.init();

// Create AI chat controller
final aiChatController = di.sl<AIChatController>(param1: userId);

// Connect to AI agent
await aiChatController.connect();

// Send message
await aiChatController.sendMessage('Hello AI!');

// Listen to messages
aiChatController.messagesStream.listen((messages) {
  // Update UI with new messages
});
```

### Connection Status Monitoring
```dart
aiChatController.connectionStatusStream.listen((status) {
  switch (status) {
    case ConnectionStatus.connected:
      // Show connected state
      break;
    case ConnectionStatus.connecting:
      // Show loading state
      break;
    case ConnectionStatus.error:
      // Show error state with retry button
      break;
  }
});
```

## 🔧 Development & Testing

### Running the App
```bash
# Install dependencies
flutter pub get

# Run with custom WebSocket URL
flutter run --dart-define=WEBSOCKET_URL=ws://localhost:3001

# Build for production
flutter build apk --dart-define=WEBSOCKET_URL=wss://your-production-server.com
```

### Testing Without Server
The app gracefully handles connection failures and provides UI feedback. You can test the interface even without a running WebSocket server.

## 🚨 Error Handling

The implementation includes comprehensive error handling:

- **Connection Failures**: Automatic retry with exponential backoff
- **Message Send Failures**: User feedback with retry options
- **Streaming Errors**: Error messages displayed in chat
- **Network Timeouts**: 30-second timeout for message sending
- **Server Disconnection**: Automatic reconnection attempts

## 🎨 UI Features

### Connection Status Indicator
- **Connected**: Green indicator, "Connected • Online"
- **Connecting**: Animated orange indicator, "Connecting..."
- **Reconnecting**: Pulsing animation, "Reconnecting..."
- **Error**: Red indicator with retry button

### AI Assistant Branding
- **Name**: "Quantu AI Assistant"
- **Icon**: Smart toy robot icon
- **Avatar**: AI-themed profile image
- **Color Scheme**: Your custom orange theme

### Real-time Features
- **Streaming Text**: Messages appear as they're generated
- **Typing Indicators**: Show when AI is processing
- **Message Actions**: Copy, delete, reply (long press)
- **Theme Switching**: Dark/light mode support

## 📚 Dependencies

```yaml
dependencies:
  socket_io_client: ^2.0.3+1  # WebSocket communication
  flutter_chat_ui: ^1.6.15    # Chat UI components
  flutter_chat_types: ^3.6.2  # Message types
  get_it: ^7.6.4              # Dependency injection
  dartz: ^0.10.1              # Functional programming
  uuid: ^4.2.1                # ID generation
```

## 🔄 Migration Guide

To switch from the simple chat to AI-powered chat:

1. **Update main.dart**: Use `AIChatPage` instead of `ModernChatPage`
2. **Configure server URL**: Update `WebSocketConfig.defaultUrl`
3. **Initialize DI**: Ensure `di.init()` is called in main()
4. **Test connection**: Verify WebSocket server is running

The app automatically handles the transition and provides fallback UI for connection issues.

## 🎯 Next Steps

### Potential Enhancements
- **File Upload**: Support for images/documents
- **Voice Messages**: Audio recording and playback
- **Message Reactions**: Emoji reactions to messages
- **Conversation History**: Persistent chat history
- **Multiple AI Agents**: Switch between different agents
- **Custom Commands**: Special AI commands and shortcuts

### Server Integration
- **Authentication**: JWT token validation
- **Rate Limiting**: Prevent spam and abuse
- **Conversation Persistence**: Store chat history
- **AI Provider Integration**: Connect to OpenAI, Claude, etc.
- **Analytics**: Track usage and performance

---

Your Flutter chat app is now ready for real-time AI agent communication! 🚀 
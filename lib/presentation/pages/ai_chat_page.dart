import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../core/theme/chat_theme.dart';
import '../../core/controllers/ai_chat_controller.dart';
import '../../core/enums/connection_status.dart';
import '../../core/di/service_locator.dart' as di;

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> with TickerProviderStateMixin {
  late AIChatController _aiChatController;
  late TextEditingController _textController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late AnimationController _connectionAnimationController;
  late Animation<Color?> _connectionColorAnimation;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  
  // Current user
  final _currentUser = const types.User(
    id: 'user1',
    firstName: 'John',
    lastName: 'Doe',
    imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
  );

  @override
  void initState() {
    super.initState();
    
    print('🏁 AI Chat Page: initState() called');
    
    // Initialize controllers
    print('🔧 AI Chat Page: Getting AIChatController from DI...');
    _aiChatController = di.sl<AIChatController>(param1: _currentUser.id);
    print('✅ AI Chat Page: AIChatController created for user: ${_currentUser.id}');
    
    // Initialize text controller
    _textController = TextEditingController();
    
    // Setup animations
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    
    _connectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _connectionColorAnimation = ColorTween(
      begin: Colors.red,
      end: CustomChatTheme.primaryColor,
    ).animate(_connectionAnimationController);

    print('🎧 AI Chat Page: Setting up connection status listener...');
    // Listen to connection status
    _aiChatController.connectionStatusStream.listen((status) {
      print('📡 AI Chat Page: Connection status changed to: $status');
      setState(() {
        _connectionStatus = status;
      });
      _updateConnectionAnimation(status);
    });

    print('🔌 AI Chat Page: Starting AI connection...');
    // Connect to AI agent
    _connectToAI();
  }

  Future<void> _connectToAI() async {
    print('🔌 AI Chat Page: _connectToAI() called');
    try {
      await _aiChatController.connect();
      print('✅ AI Chat Page: _connectToAI() completed successfully');
    } catch (e) {
      print('❌ AI Chat Page: _connectToAI() failed: $e');
    }
  }

  void _updateConnectionAnimation(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        _connectionAnimationController.forward();
        break;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        _connectionAnimationController.repeat(reverse: true);
        break;
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
        _connectionAnimationController.reverse();
        break;
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _connectionAnimationController.dispose();
    _textController.dispose();
    _aiChatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D22),
      body: Column(
        children: [
          _buildCustomAppBar(),
          _buildConnectionStatus(),
          Expanded(
            child: StreamBuilder<List<types.Message>>(
              stream: _aiChatController.messagesStream,
              initialData: _aiChatController.messages,
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                return Column(
                  children: [
                    // Custom message list without input
                    Expanded(
                      child: Container(
                        color: const Color(0xFF1A1D22), // Same as input and app bar background
                        child: messages.isEmpty
                            ? const Center(
                                child: Text(
                                  'No hay mensajes aquí todavía',
                                  style: TextStyle(
                                    color: Color(0xFF8A8A8A),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              )
                            : ListView.builder(
                                reverse: true,
                                padding: const EdgeInsets.all(16),
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final message = messages[index];
                                  final isUser = message.author.id == _currentUser.id;
                                  
                                  if (message is types.TextMessage) {
                                    return _buildMessageBubble(message, isUser);
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                      ),
                    ),
                    // Our custom input widget
                    _buildCustomInput(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: _scrollToBottom,
          child: const Icon(Icons.keyboard_arrow_down),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        bottom: 0,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1D22), // Same as input background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF292D30), // Thin border to separate from body
            width: 1,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Back button
            IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            // Profile picture with online status
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black, 
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo-icon-2.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),                // Online status indicator
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quantu AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const Text(
                    'En linea',
                    style: TextStyle(
                      color: Color(0xFFB0B0B0), // Light gray
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            // Menu button
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'reconnect',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 12),
                      Text('Reconectar AI'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, size: 20),
                      SizedBox(width: 12),
                      Text('Limpiar Chat'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    if (_connectionStatus == ConnectionStatus.connected) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _getConnectionStatusColor().withOpacity(0.1),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(_getConnectionStatusColor()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getConnectionStatusText(),
              style: TextStyle(
                color: _getConnectionStatusColor(),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_connectionStatus == ConnectionStatus.error)
            TextButton(
              onPressed: _reconnectToAI,
              child: Text(
                'Retry',
                style: TextStyle(
                  color: _getConnectionStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getConnectionStatusText() {
    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        return 'Conectado • En Linea';
      case ConnectionStatus.connecting:
        return 'Conectando...';
      case ConnectionStatus.reconnecting:
        return 'Reconectando...';
      case ConnectionStatus.disconnected:
        return 'Desconectado';
      case ConnectionStatus.error:
        return 'Error de conexión';
    }
  }

  String _getConnectionStatusMessage() {
    switch (_connectionStatus) {
      case ConnectionStatus.connecting:
        return 'Connecting to Quantu AI Assistant...';
      case ConnectionStatus.reconnecting:
        return 'Reconnecting to AI Assistant...';
      case ConnectionStatus.disconnected:
        return 'Disconnected from AI Assistant';
      case ConnectionStatus.error:
        return 'Failed to connect to AI Assistant';
      case ConnectionStatus.connected:
        return '';
    }
  }

  Color _getConnectionStatusColor() {
    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        return CustomChatTheme.primaryColor;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return CustomChatTheme.secondaryColor;
      case ConnectionStatus.disconnected:
        return CustomChatTheme.textSecondary;
      case ConnectionStatus.error:
        return CustomChatTheme.tertiaryColor;
    }
  }

  void _handleSendPressed(types.PartialText message) {
    print('📝 AI Chat Page: _handleSendPressed() called with: "${message.text}"');
    try {
      _aiChatController.sendMessage(message.text);
      print('✅ AI Chat Page: sendMessage() called successfully');
      HapticFeedback.lightImpact();
    } catch (e) {
      print('❌ AI Chat Page: sendMessage() failed: $e');
    }
  }

  void _handleMessageTap(BuildContext context, types.Message message) {
    HapticFeedback.selectionClick();
  }

  void _handleMessageLongPress(BuildContext context, types.Message message) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: CustomChatTheme.darkBgWidget,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CustomChatTheme.darkBorderBase,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _buildActionTile(Icons.reply, 'Reply', () {}),
            _buildActionTile(Icons.content_copy, 'Copy', () {
              if (message is types.TextMessage) {
                Clipboard.setData(ClipboardData(text: message.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied to clipboard')),
                );
              }
            }),
            _buildActionTile(Icons.forward, 'Forward', () {}),
            if (message.author.id == _currentUser.id)
              _buildActionTile(Icons.delete, 'Delete', () {
                _aiChatController.removeMessage(message.id);
              }, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
                    color: isDestructive 
                ? CustomChatTheme.tertiaryColor 
                : CustomChatTheme.darkTextDefault,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive 
              ? CustomChatTheme.tertiaryColor 
              : CustomChatTheme.darkTextDefault,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'reconnect':
        _reconnectToAI();
        break;
      case 'clear':
        _showClearChatDialog();
        break;
    }
  }

  Future<void> _reconnectToAI() async {
    await _aiChatController.reconnect();
    HapticFeedback.lightImpact();
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CustomChatTheme.darkBgWidget,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Chat',
          style: TextStyle(
            color: CustomChatTheme.darkTextDefault,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all messages? This action cannot be undone.',
          style: TextStyle(
            color: CustomChatTheme.darkTextDefault,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: CustomChatTheme.primaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              _aiChatController.clearMessages();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat cleared successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomChatTheme.tertiaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    _fabAnimationController.reverse();
  }

  Widget _buildCustomInput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1D22),
        boxShadow: [
          BoxShadow(
            color: Color(0x14FFFFFF),
            blurRadius: 0,
            offset: Offset(0, -1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Input field with logo icon
          Expanded(
            child: Container(
              height: 40,
              decoration: ShapeDecoration(
                color: const Color(0xFF22252A),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFF292D30),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // Logo icon
                  Container(
                    margin: const EdgeInsets.all(3),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x8EFB4601),
                          blurRadius: 15.30,
                          offset: Offset(0, 4),
                          spreadRadius: -10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: Image.asset(
                        'assets/images/logo-icon.png',
                        width: 34,
                        height: 34,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Haz una pregunta',
                        hintStyle: TextStyle(
                          color: Color(0x80AFAFAF), // 50% opacity
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      style: const TextStyle(
                        color: Color(0xFFAFAFAF),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: _handleSendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send button
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.50, 0.00),
                end: Alignment(1.28, 1.00),
                colors: [Color(0xFFFB4601), Color(0xFFFF8C1F)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _handleSendMessage(_textController.text),
                child: Center(
                  child: const Icon(
                    Icons.send,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(types.TextMessage message, bool isUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: CustomChatTheme.primaryColor,
              child: const Text(
                'Q',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser 
                    ? const Color(0xFF101418) // Dark gray for user messages
                    : const Color(0xFFFB4601).withOpacity(0.85), // Orange with 85% opacity for AI messages
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white, // White text for both
                  fontSize: 14, // 14px as specified
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400, // Regular weight
                  height: null, // Auto line height
                  letterSpacing: 0, // 0% letter spacing
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF22252A),
              child: const Text(
                'Tu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleSendMessage(String text) {
    if (text.trim().isNotEmpty) {
      _aiChatController.sendMessage(text.trim());
      _textController.clear();
    }
  }
} 
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
  bool _isDarkMode = false;
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
    _aiChatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? CustomChatTheme.darkBgMain : CustomChatTheme.bgMain,
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
                return Chat(
                  messages: messages,
                  onSendPressed: _handleSendPressed,
                  user: _currentUser,
                  theme: _isDarkMode 
                      ? CustomChatTheme.getDarkTheme()
                      : CustomChatTheme.getLightTheme(),
                  showUserAvatars: true,
                  showUserNames: false,
                  onMessageTap: _handleMessageTap,
                  onMessageLongPress: _handleMessageLongPress,
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
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: _isDarkMode ? CustomChatTheme.darkBgWidget : CustomChatTheme.bgWidget,
        border: Border(
          bottom: BorderSide(
            color: _isDarkMode ? CustomChatTheme.darkBorderBase : CustomChatTheme.borderBase,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: CustomChatTheme.primaryColor,
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantu AI Assistant',
                  style: TextStyle(
                    color: _isDarkMode ? CustomChatTheme.darkTextDefault : CustomChatTheme.textDefault,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AnimatedBuilder(
                  animation: _connectionColorAnimation,
                  builder: (context, child) {
                    return Text(
                      _getConnectionStatusText(),
                      style: TextStyle(
                        color: _connectionColorAnimation.value,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.phone_outlined,
              color: _isDarkMode ? CustomChatTheme.darkPlaceholder : CustomChatTheme.textSecondary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Voice call feature coming soon! 📞'),
                  backgroundColor: CustomChatTheme.secondaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: _isDarkMode ? CustomChatTheme.darkTextDefault : CustomChatTheme.textDefault,
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(
                      _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      size: 20,
                      color: _isDarkMode ? CustomChatTheme.darkTextDefault : CustomChatTheme.textDefault,
                    ),
                    const SizedBox(width: 12),
                    Text(_isDarkMode ? 'Light Mode' : 'Dark Mode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reconnect',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 12),
                    Text('Reconnect AI'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    SizedBox(width: 12),
                    Text('Clear Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
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
              _getConnectionStatusMessage(),
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
        return 'Connected • Online';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.reconnecting:
        return 'Reconnecting...';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.error:
        return 'Connection Error';
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
      backgroundColor: _isDarkMode ? CustomChatTheme.darkBgWidget : CustomChatTheme.bgWidget,
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
                color: _isDarkMode ? CustomChatTheme.darkBorderBase : CustomChatTheme.borderBase,
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
            : (_isDarkMode ? CustomChatTheme.darkTextDefault : CustomChatTheme.textDefault),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive 
              ? CustomChatTheme.tertiaryColor 
              : (_isDarkMode ? CustomChatTheme.darkTextDefault : CustomChatTheme.textDefault),
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
      case 'theme':
        setState(() {
          _isDarkMode = !_isDarkMode;
        });
        HapticFeedback.lightImpact();
        break;
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
        backgroundColor: _isDarkMode ? CustomChatTheme.darkBgWidget : CustomChatTheme.bgWidget,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Chat',
          style: TextStyle(
            color: _isDarkMode ? CustomChatTheme.darkTextDefault : CustomChatTheme.textDefault,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all messages? This action cannot be undone.',
          style: TextStyle(
            color: _isDarkMode ? CustomChatTheme.darkTextDefault : CustomChatTheme.textDefault,
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
} 
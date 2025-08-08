import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';

import '../../core/theme/chat_theme.dart';
import '../../core/controllers/ai_chat_controller.dart';
import '../../core/di/service_locator.dart';
import '../../core/enums/connection_status.dart';

class ModernChatPage extends StatefulWidget {
  const ModernChatPage({super.key});

  @override
  State<ModernChatPage> createState() => _ModernChatPageState();
}

class _ModernChatPageState extends State<ModernChatPage> with TickerProviderStateMixin {
  late final AIChatController _chatController;
  bool _isDarkMode = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Current user
  final _currentUser = const types.User(
    id: 'user1',
    firstName: 'John',
    lastName: 'Doe',
    imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
  );

  // Mock users for the chat
  final Map<String, types.User> _users = {
    'user1': const types.User(
      id: 'user1',
      firstName: 'John',
      lastName: 'Doe',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
    ),
    'user2': const types.User(
      id: 'user2',
      firstName: 'Jane',
      lastName: 'Smith',
      imageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
    ),
    'user3': const types.User(
      id: 'user3',
      firstName: 'Alex',
      lastName: 'Johnson',
      imageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    ),
  };

  @override
  void initState() {
    super.initState();
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    
    _initializeChat();
  }

  void _initializeChat() {
    // Initialize AI chat controller with user ID
    _chatController = sl<AIChatController>(param1: _currentUser.id);
    
    // Connect to the websocket server
    _chatController.connect();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? CustomChatTheme.darkBgMain : CustomChatTheme.bgMain,
      appBar: _buildModernAppBar(),
      body: Column(
        children: [
          _buildStatusBar(),
          Expanded(
            child: StreamBuilder<List<types.Message>>(
              stream: _chatController.messagesStream,
              initialData: _chatController.messages,
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
          backgroundColor: CustomChatTheme.primaryColor,
          child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: _isDarkMode ? CustomChatTheme.darkBgWidget : CustomChatTheme.bgWidget,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: CustomChatTheme.primaryColor, width: 2),
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150&h=150&fit=crop&crop=face',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantu AI',
                  style: TextStyle(
                    color: _isDarkMode ? CustomChatTheme.darkTextDefault : CustomChatTheme.textDefault,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                StreamBuilder<ConnectionStatus>(
                  stream: _chatController.connectionStatusStream,
                  initialData: _chatController.connectionStatus,
                  builder: (context, snapshot) {
                    final status = snapshot.data ?? ConnectionStatus.disconnected;
                    String statusText;
                    Color statusColor;
                    
                    switch (status) {
                      case ConnectionStatus.connected:
                        statusText = 'Online';
                        statusColor = Colors.green;
                        break;
                      case ConnectionStatus.connecting:
                        statusText = 'Connecting...';
                        statusColor = Colors.orange;
                        break;
                      case ConnectionStatus.reconnecting:
                        statusText = 'Reconnecting...';
                        statusColor = Colors.orange;
                        break;
                      case ConnectionStatus.error:
                        statusText = 'Connection Error';
                        statusColor = Colors.red;
                        break;
                      case ConnectionStatus.disconnected:
                      default:
                        statusText = 'Offline';
                        statusColor = Colors.grey;
                        break;
                    }
                    
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: _isDarkMode ? CustomChatTheme.darkPlaceholder : CustomChatTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: _isDarkMode ? CustomChatTheme.darkPlaceholder : CustomChatTheme.textSecondary,
          ),
          onPressed: () {
            _chatController.reconnect();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Reconnecting to server...'),
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
            color: _isDarkMode ? CustomChatTheme.darkPlaceholder : CustomChatTheme.textSecondary,
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
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomChatTheme.primaryColor,
            CustomChatTheme.secondaryColor,
            CustomChatTheme.tertiaryColor,
          ],
        ),
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    // Send message through AI chat controller
    _chatController.sendMessage(message.text);
    
    // Haptic feedback for modern feel
    HapticFeedback.lightImpact();
  }

  void _handleMessageTap(BuildContext context, types.Message message) {
    HapticFeedback.selectionClick();
    // Could implement message reactions or details here
  }

  void _handleMessageLongPress(BuildContext context, types.Message message) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDarkMode ? CustomChatTheme.darkBgWidget : CustomChatTheme.bgWidget,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _isDarkMode ? CustomChatTheme.darkPlaceholder : CustomChatTheme.borderBase,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
                _chatController.removeMessage(message.id);
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
      case 'clear':
        _showClearChatDialog();
        break;
    }
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
              _chatController.clearMessages();
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
    // Implementation for scrolling to bottom would go here
    // The SimpleChatController doesn't expose scroll control directly
  }
} 
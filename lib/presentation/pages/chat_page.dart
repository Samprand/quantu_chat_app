import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat_ui;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../core/constants/app_constants.dart';
import '../../domain/entities/chat_message.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Current user for the chat
  final _currentUser = const ChatUser(
    id: AppConstants.defaultUserId,
    firstName: AppConstants.defaultUserName,
  );

  @override
  void initState() {
    super.initState();
    // Load messages when the page initializes
    context.read<ChatBloc>().add(const LoadMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _showClearChatDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear Chat'),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MessageSendError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send message: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ChatInitial || state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ChatError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatBloc>().add(const LoadMessages());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<ChatMessage> messages = [];
          if (state is ChatLoaded) {
            messages = state.isSearching ? state.searchResults : state.messages;
          } else if (state is MessageSending) {
            messages = [...state.messages, state.pendingMessage];
          } else if (state is MessageSent) {
            messages = state.messages;
          } else if (state is MessageSendError) {
            messages = state.messages;
          }

          // Convert domain messages to flutter_chat_ui types
          final chatMessages = messages
              .map((message) => message.toFlutterChatType())
              .toList();

          return chat_ui.Chat(
            messages: chatMessages,
            onSendPressed: _handleSendPressed,
            user: _currentUser.toFlutterChatType(),
            theme: const chat_ui.DefaultChatTheme(
              primaryColor: Colors.blue,
              secondaryColor: Colors.grey,
              backgroundColor: Colors.white,
            ),
            showUserAvatars: true,
            showUserNames: true,
            onMessageTap: _handleMessageTap,
            onMessageLongPress: _handleMessageLongPress,
          );
        },
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    context.read<ChatBloc>().add(
      SendMessageEvent(
        text: message.text,
        author: _currentUser,
      ),
    );
  }

  void _handleMessageTap(BuildContext context, types.Message message) {
    // Mark message as read when tapped
    context.read<ChatBloc>().add(
      MarkMessageAsRead(messageId: message.id),
    );
  }

  void _handleMessageLongPress(BuildContext context, types.Message message) {
    // Show options menu for message actions
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement copy functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message copied')),
                  );
                },
              ),
              if (message.author.id == _currentUser.id)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<ChatBloc>().add(
                      DeleteMessageEvent(messageId: message.id),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return AlertDialog(
          title: const Text('Search Messages'),
          content: TextField(
            onChanged: (value) => searchQuery = value,
            decoration: const InputDecoration(
              hintText: 'Enter search term...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<ChatBloc>().add(const ClearSearch());
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (searchQuery.isNotEmpty) {
                  context.read<ChatBloc>().add(
                    SearchMessages(query: searchQuery),
                  );
                }
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Chat'),
          content: const Text('Are you sure you want to clear all messages?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement clear chat functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat cleared')),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
} 
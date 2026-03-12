import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constant/app_constant.dart';
import '../../domain/entities/message.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // Small delay so the new bubble is laid out before we scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSend(BuildContext context, String text) {
    context.read<ChatBloc>().add(SendMessageEvent(text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          // Clear button — wired to Hive clear in Phase 7
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear chat',
            onPressed: () => _confirmClear(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              // Scroll down whenever a new message or chunk arrives
              listener: (context, state) {
                if (state is ChatLoaded) _scrollToBottom();
                if (state is ChatError) _showErrorSnack(context, state.message);
              },
              builder: (context, state) {
                final messages = switch (state) {
                  ChatLoaded s => s.messages,
                  ChatError s => s.previousMessages,
                  _ => <Message>[],
                };

                if (messages.isEmpty) return const _EmptyChat();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, i) =>
                      MessageBubble(message: messages[i]),
                );
              },
            ),
          ),

          // Input bar — disabled while streaming so user can't double-send
          BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (prev, curr) {
              // only rebuild input when streaming status changes
              if (prev is ChatLoaded && curr is ChatLoaded) {
                return prev.isStreaming != curr.isStreaming;
              }
              return true;
            },
            builder: (context, state) {
              final isStreaming = state is ChatLoaded && state.isStreaming;
              return ChatInput(
                enabled: !isStreaming,
                onSend: (text) => _onSend(context, text),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear chat?'),
        content: const Text('This will delete all messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ChatBloc>().add(const ClearHistoryEvent());
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnack(BuildContext context, String message) {
    print("---------------- the error is ${message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Shown when there are no messages yet
class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 56, color: colors.primary),
          const SizedBox(height: 16),
          Text(
            'How can I help you today?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

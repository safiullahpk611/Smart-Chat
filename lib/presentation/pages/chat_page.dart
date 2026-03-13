import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constant/app_constant.dart';
import '../../domain/entities/message.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../bloc/theme_cubit.dart';
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
  void initState() {
    super.initState();
    // scroll to bottom after history loads on app open
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
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
          // Dark mode toggle
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) => IconButton(
              icon: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              tooltip: 'Toggle theme',
              onPressed: () => context.read<ThemeCubit>().toggle(),
            ),
          ),
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
                if (state is Loading ||
                    state is ChatStreaming ||
                    state is ChatCompleted) {
                  _scrollToBottom();
                }
                if (state is ChatError) {
                  _showErrorSnack(context, state.message);
                }
              },
              builder: (context, state) {
                List<Message> messages = [];
                if (state is Loading) {
                  messages = state.messages;
                } else if (state is ChatStreaming) {
                  messages = state.messages;
                } else if (state is ChatCompleted) {
                  messages = state.messages;
                } else if (state is ChatError) {
                  messages = state.previousMessages;
                }

                if (messages.isEmpty) {
                  return const _EmptyChat();
                }

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
            builder: (context, state) {
              final isStreaming = state is Loading || state is ChatStreaming;
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
    print("---------------- the error is $message");
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => context.read<ChatBloc>().add(const RetryEvent()),
        ),
      ),
    );
  }
}

//  there are no messages yet
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

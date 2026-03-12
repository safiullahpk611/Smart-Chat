import 'package:flutter/material.dart';

import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI avatar — only shown on left side
          if (!isUser) _AiAvatar(colors: colors),
          if (!isUser) const SizedBox(width: 8),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? colors.primary : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: message.isStreaming && message.content.isEmpty
                  // Still waiting for first chunk — show typing dots
                  ? const _TypingDots()
                  : Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? colors.onPrimary : colors.onSurface,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
            ),
          ),

          if (isUser) const SizedBox(width: 8),
          // Small spacer on the right so user bubble doesn't touch the edge
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _AiAvatar extends StatelessWidget {
  final ColorScheme colors;
  const _AiAvatar({required this.colors});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: colors.primaryContainer,
      child: Icon(Icons.auto_awesome, size: 14, color: colors.primary),
    );
  }
}

// Simple 3-dot typing indicator — animated in Phase 6
class _TypingDots extends StatelessWidget {
  const _TypingDots();

  @override
  Widget build(BuildContext context) {
    // TODO: replace with animated version in Phase 6
    return const Text(
      '•  •  •',
      style: TextStyle(fontSize: 18, letterSpacing: 2),
    );
  }
}

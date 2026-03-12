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
          if (!isUser) _AiAvatar(colors: colors),
          if (!isUser) const SizedBox(width: 8),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? colors.primary
                    : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: _buildContent(colors, isUser),
            ),
          ),

          if (isUser) const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme colors, bool isUser) {
    // Waiting for first chunk — show bouncing dots
    if (message.isStreaming && message.content.isEmpty) {
      return const _BouncingDots();
    }

    // Text is coming in — show it with a blinking cursor at the end
    if (message.isStreaming && message.content.isNotEmpty) {
      return _StreamingText(
        content: message.content,
        textColor: isUser ? colors.onPrimary : colors.onSurface,
      );
    }

    // Fully received — plain text (markdown in Phase 7)
    return Text(
      message.content,
      style: TextStyle(
        color: isUser ? colors.onPrimary : colors.onSurface,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }
}

// --- Bouncing dots (shown while waiting for first chunk) ---

class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Each dot gets a staggered interval so they bounce in a wave
  late final List<Animation<double>> _dotAnims;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    // Stagger: dot 0 leads, dot 2 trails by ~200ms each
    _dotAnims = List.generate(3, (i) {
      final start = i * 0.2; // 0.0, 0.2, 0.4
      final end = start + 0.4; // 0.4, 0.6, 0.8
      return Tween<double>(begin: 0, end: -7).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.translate(
                offset: Offset(0, _dotAnims[i].value),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// --- Streaming text with blinking cursor ---

class _StreamingText extends StatefulWidget {
  final String content;
  final Color textColor;

  const _StreamingText({required this.content, required this.textColor});

  @override
  State<_StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<_StreamingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cursorController;
  late final Animation<double> _cursorOpacity;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true); // fades in and out

    _cursorOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cursorController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cursorOpacity,
      builder: (context, _) {
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: widget.content),
              // Blinking cursor at the end
              TextSpan(
                text: '▋',
                style: TextStyle(
                  color: widget.textColor.withValues(alpha: _cursorOpacity.value),
                  fontSize: 13,
                ),
              ),
            ],
            style: TextStyle(
              color: widget.textColor,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        );
      },
    );
  }
}

// ---

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

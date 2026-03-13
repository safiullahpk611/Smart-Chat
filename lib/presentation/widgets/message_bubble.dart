import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
            child: GestureDetector(
              onLongPress: () {
                if (message.isStreaming) return;
                Clipboard.setData(ClipboardData(text: message.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message copied'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
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
                child: _buildContent(context, colors, isUser),
              ),
            ),
          ),

          if (isUser) const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colors, bool isUser) {
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


    if (isUser) {
      return Text(
        message.content,
        style: TextStyle(color: colors.onPrimary, fontSize: 15, height: 1.4),
      );
    }

    // AI messages rendered 
    return MarkdownBody(
      data: message.content,
      shrinkWrap: true,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: TextStyle(color: colors.onSurface, fontSize: 15, height: 1.4),
        code: TextStyle(
          backgroundColor: colors.surfaceContainerHighest,
          color: colors.primary,
          fontSize: 13,
        ),
        codeblockDecoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.outlineVariant),
        ),
      ),
    );
  }
}

// --- Bouncing dots 

class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _anims = _controllers
        .map(
          (c) => Tween<double>(begin: 0, end: -7).animate(
            CurvedAnimation(parent: c, curve: Curves.easeInOut),
          ),
        )
        .toList();

    // start each dot a bit later so they wave instead of bouncing together
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Transform.translate(
              offset: Offset(0, _anims[i].value),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
        );
      }),
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
    )..repeat(reverse: true); 

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

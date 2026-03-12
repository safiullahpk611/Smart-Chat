import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final bool enabled;
  final void Function(String text) onSend;

  const ChatInput({
    super.key,
    required this.onSend,
    this.enabled = true,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canSend = _hasText && widget.enabled;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: colors.outlineVariant, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                minLines: 1,
                maxLines: 5, // grows with content, up to 5 lines
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: widget.enabled ? 'Message SmartChat...' : 'Waiting for response...',
                  hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.4)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedScale(
              scale: canSend ? 1.0 : 0.8,
              duration: const Duration(milliseconds: 150),
              child: IconButton.filled(
                onPressed: canSend ? _submit : null,
                icon: const Icon(Icons.arrow_upward_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: canSend ? colors.primary : colors.surfaceContainerHighest,
                  foregroundColor: canSend ? colors.onPrimary : colors.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

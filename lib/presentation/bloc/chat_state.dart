import 'package:equatable/equatable.dart';

import '../../domain/entities/message.dart';

sealed class ChatState extends Equatable {
  const ChatState();
}

// Nothing loaded yet — shows the empty/welcome screen
class ChatInitial extends ChatState {
  const ChatInitial();

  @override
  List<Object> get props => [];
}

// Normal state — carries the full message list.
// isStreaming = true while Gemini is still sending chunks.
// The UI uses this flag to show/hide the send button and typing indicator.
class ChatLoaded extends ChatState {
  final List<Message> messages;
  final bool isStreaming;

  const ChatLoaded({
    required this.messages,
    this.isStreaming = false,
  });

  // Convenience so the BLoC doesn't have to reconstruct the whole object
  ChatLoaded copyWith({List<Message>? messages, bool? isStreaming}) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  @override
  List<Object> get props => [messages, isStreaming];
}

// Something went wrong — still shows the previous messages so the user
// doesn't lose the conversation context
class ChatError extends ChatState {
  final String message;
  final List<Message> previousMessages;

  const ChatError({required this.message, required this.previousMessages});

  @override
  List<Object> get props => [message, previousMessages];
}

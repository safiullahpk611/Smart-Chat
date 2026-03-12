import 'package:equatable/equatable.dart';

import '../../domain/entities/message.dart';

abstract class ChatState extends Equatable {
  const ChatState();
}

class Initial extends ChatState {
  const Initial();

  @override
  List<Object> get props => [];
}


class Loading extends ChatState {
  final List<Message> messages;

  const Loading({required this.messages});

  @override
  List<Object> get props => [messages];
}


class ChatStreaming extends ChatState {
  final List<Message> messages;
  final String streamingContent;

  const ChatStreaming({required this.messages, required this.streamingContent});

  @override
  List<Object> get props => [messages, streamingContent];
}


class ChatCompleted extends ChatState {
  final List<Message> messages;

  const ChatCompleted({required this.messages});

  @override
  List<Object> get props => [messages];
}

class ChatError extends ChatState {
  final String message;
  final List<Message> previousMessages;
  // keeping the original text so the UI can offer a retry button
  final String failedText;

  const ChatError({
    required this.message,
    required this.previousMessages,
    required this.failedText,
  });

  @override
  List<Object> get props => [message, previousMessages, failedText];
}

import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
}

// User hits send
class SendMessageEvent extends ChatEvent {
  final String text;
  const SendMessageEvent(this.text);

  @override
  List<Object> get props => [text];
}


class ReceiveStreamChunkEvent extends ChatEvent {
  final String chunk;
  const ReceiveStreamChunkEvent(this.chunk);

  @override
  List<Object> get props => [chunk];
}

// Fired on app launch to restore Hive messages
class LoadHistoryEvent extends ChatEvent {
  const LoadHistoryEvent();

  @override
  List<Object> get props => [];
}

// Clear button in the app bar
class ClearHistoryEvent extends ChatEvent {
  const ClearHistoryEvent();

  @override
  List<Object> get props => [];
}

// Retry the last failed message
class RetryEvent extends ChatEvent {
  const RetryEvent();

  @override
  List<Object> get props => [];
}

import 'package:equatable/equatable.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();
}

// User hit send
class SendMessageEvent extends ChatEvent {
  final String text;
  const SendMessageEvent(this.text);

  @override
  List<Object> get props => [text];
}

// Fired on app launch to restore Hive messages (Phase 7)
class LoadHistoryEvent extends ChatEvent {
  const LoadHistoryEvent();

  @override
  List<Object> get props => [];
}

// Clear button in the app bar (Phase 7)
class ClearHistoryEvent extends ChatEvent {
  const ClearHistoryEvent();

  @override
  List<Object> get props => [];
}

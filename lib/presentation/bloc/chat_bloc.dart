import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/message.dart';
import '../../domain/usecases/clear_history.dart';
import '../../domain/usecases/get_chat_history.dart';
import '../../domain/usecases/send_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

final _uuid = Uuid();

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessage _sendMessage;
  final GetChatHistory _getHistory;
  final ClearHistory _clearHistory;

  ChatBloc({
    required SendMessage sendMessage,
    required GetChatHistory getHistory,
    required ClearHistory clearHistory,
  })  : _sendMessage = sendMessage,
        _getHistory = getHistory,
        _clearHistory = clearHistory,
        super(const ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<LoadHistoryEvent>(_onLoadHistory);
    on<ClearHistoryEvent>(_onClearHistory);
  }

  // Helper to grab the current message list regardless of state
  List<Message> get _currentMessages => switch (state) {
        ChatLoaded s => s.messages,
        ChatError s => s.previousMessages,
        _ => [],
      };

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;

    final history = _currentMessages;

    // 1. Optimistically add the user bubble right away
    final userMsg = Message(
      id: _uuid.v4(),
      content: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    final withUser = [...history, userMsg];
    emit(ChatLoaded(messages: withUser, isStreaming: true));

    // 2. Placeholder AI bubble — empty content, isStreaming=true so the
    //    UI shows the typing dots while we wait for the first chunk
    final aiMsgId = _uuid.v4();
    final aiPlaceholder = Message(
      id: aiMsgId,
      content: '',
      role: MessageRole.aiModel,
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    var messagesWithAi = [...withUser, aiPlaceholder];
    emit(ChatLoaded(messages: messagesWithAi, isStreaming: true));

    // 3. Stream chunks from Gemini and accumulate into the AI bubble.
    //    emit.forEach handles stream subscription + cancellation automatically.
    String accumulated = '';

    try {
      await emit.forEach<String>(
        // Pass history BEFORE the user message — Gemini receives the
        // new message separately via sendMessageStream inside the datasource
        _sendMessage(history, text),
        onData: (chunk) {
          accumulated += chunk;
          final updated = aiPlaceholder.copyWith(
            content: accumulated,
            isStreaming: true,
          );
          messagesWithAi = [...withUser, updated];
          return ChatLoaded(messages: messagesWithAi, isStreaming: true);
        },
        onError: (error, _) {
          return ChatError(
            message: error.toString().replaceFirst('Exception: ', ''),
            previousMessages: withUser, // keep the user's message visible
          );
        },
      );

      // 4. Stream finished — mark the AI bubble as done
      final finalAiMsg = aiPlaceholder.copyWith(
        content: accumulated,
        isStreaming: false,
      );
      emit(ChatLoaded(
        messages: [...withUser, finalAiMsg],
        isStreaming: false,
      ));

      // TODO: save both messages to Hive here in Phase 7
    } catch (e) {
      emit(ChatError(
        message: e.toString(),
        previousMessages: withUser,
      ));
    }
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final messages = await _getHistory();
      emit(ChatLoaded(messages: messages));
    } catch (e) {
      // If Hive fails on load, just start fresh — not fatal
      emit(const ChatLoaded(messages: []));
    }
  }

  Future<void> _onClearHistory(
    ClearHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    await _clearHistory();
    emit(const ChatLoaded(messages: []));
  }
}

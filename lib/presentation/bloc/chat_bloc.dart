import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/message.dart';
import '../../domain/usecases/clear_history.dart';
import '../../domain/usecases/get_chat_history.dart';
import '../../domain/usecases/save_message.dart';
import '../../domain/usecases/send_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

final _uuid = Uuid();

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessage _sendMessage;
  final GetChatHistory _getHistory;
  final ClearHistory _clearHistory;
  final SaveMessage _saveMessage;

  ChatBloc({
    required SendMessage sendMessage,
    required GetChatHistory getHistory,
    required ClearHistory clearHistory,
    required SaveMessage saveMessage,
  }) : _sendMessage = sendMessage,
       _getHistory = getHistory,
       _clearHistory = clearHistory,
       _saveMessage = saveMessage,
       super(const Initial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<ReceiveStreamChunkEvent>(_onReceiveStreamChunk);
    on<RetryEvent>(_onRetry);
    on<LoadHistoryEvent>(_onLoadHistory);
    on<ClearHistoryEvent>(_onClearHistory);
  }


  List<Message> get _currentMessages {
    if (state is ChatCompleted) return (state as ChatCompleted).messages;
    if (state is ChatError) return (state as ChatError).previousMessages;
    return [];
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;


    final history = _currentMessages;
    print('sending msg, history length: ${history.length}');

    final userMsg = Message(
      id: _uuid.v4(),
      content: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
    final withUser = [...history, userMsg];

    // placeholder AI bubble so user sees a loading dot right away
    final aiPlaceholder = Message(
      id: _uuid.v4(),
      content: '',
      role: MessageRole.aiModel,
      timestamp: DateTime.now(),
      isStreaming: true,
    );


    emit(Loading(messages: [...withUser, aiPlaceholder]));
    print('emited loading state, wating for response...');

    String accumulated = '';

    try {

      await for (final chunk in _sendMessage(history, text)) {
        accumulated += chunk;
        print('chunk recieved >> $chunk');

        final streamingAi = aiPlaceholder.copyWith(
          content: accumulated,
          isStreaming: true,
        );
        emit(ChatStreaming(
          messages: [...withUser, streamingAi],
          streamingContent: accumulated,
        ));
      }

      // Stream complete — seal the AI message and persist both turns to Hive
      final finalAiMsg = aiPlaceholder.copyWith(
        content: accumulated,
        isStreaming: false,
      );
      print('stream done, total chars: ${accumulated.length}');
      await _saveMessage(userMsg);
      await _saveMessage(finalAiMsg);
      print('mesages saved to hive succesfuly');

      emit(ChatCompleted(messages: [...withUser, finalAiMsg]));
    } catch (e) {
      print('error in send messge: $e');
      emit(ChatError(
        message: e.toString().replaceFirst('Exception: ', ''),
        previousMessages: withUser,
        failedText: text,
      ));
    }
  }


  Future<void> _onRetry(RetryEvent event, Emitter<ChatState> emit) async {
    if (state is ChatError) {
      final failedText = (state as ChatError).failedText;
      print('retrying last msg: "$failedText"');
      add(SendMessageEvent(failedText));
    }
  }

  Future<void> _onReceiveStreamChunk(
    ReceiveStreamChunkEvent event,
    Emitter<ChatState> emit,
  ) async {
   
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final messages = await _getHistory();
      print('loaded ${messages.length} mesages from hive');
      emit(ChatCompleted(messages: messages));
    } catch (e) {
      print('hive load faild: $e');
      emit(const ChatCompleted(messages: []));
    }
  }

  Future<void> _onClearHistory(
    ClearHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    await _clearHistory();
    emit(const ChatCompleted(messages: []));
  }
}

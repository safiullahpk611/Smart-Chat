import 'package:hive/hive.dart';

import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/ai_remote_datasource.dart';
import '../models/message_model.dart';

const _hiveBoxName = 'chat_history';

class ChatRepositoryImpl implements ChatRepository {
  final AiRemoteDatasource _datasource;

  ChatRepositoryImpl(this._datasource);

  @override
  Stream<String> sendMessage(List<Message> history, String userMessage) {
    print('forwarding to datasource, msg="${userMessage.substring(0, userMessage.length.clamp(0, 30))}..."');
    return _datasource.streamResponse(history, userMessage);
  }

  // --- Hive  ---

  @override
  Future<List<Message>> loadChatHistory() async {
    final box = await _openBox();
    final messages = box.values
        .map((raw) => MessageModel.fromMap(raw as Map))
        .toList();
    
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  @override
  Future<void> saveMessage(Message message) async {
    final box = await _openBox();
    final model = MessageModel.fromEntity(message);
    await box.put(model.id, model.toMap());
    print('saved msg to hive, role: ${message.role.name}, id: ${message.id}');
  }

  @override
  Future<void> clearHistory() async {
    print('clearing all chat histroy from hive...');
    final box = await _openBox();
    await box.clear();
    print('hive box cleard ');
  }

  // Lazy-open
  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_hiveBoxName)) {
      return Hive.box(_hiveBoxName);
    }
    return Hive.openBox(_hiveBoxName);
  }
}

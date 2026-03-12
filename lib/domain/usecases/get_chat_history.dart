import '../entities/message.dart';
import '../repositories/chat_repository.dart';

// restore the conversation from Hive on app launch
class GetChatHistory {
  final ChatRepository _repo;

  GetChatHistory(this._repo);

  Future<List<Message>> call() => _repo.loadChatHistory();
}

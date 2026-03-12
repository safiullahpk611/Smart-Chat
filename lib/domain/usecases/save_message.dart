import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SaveMessage {
  final ChatRepository _repo;

  SaveMessage(this._repo);

  Future<void> call(Message message) => _repo.saveMessage(message);
}

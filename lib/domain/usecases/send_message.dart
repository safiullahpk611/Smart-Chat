import '../entities/message.dart';
import '../repositories/chat_repository.dart';


class SendMessage {
  final ChatRepository _repo;

  SendMessage(this._repo);


  Stream<String> call(List<Message> history, String userMessage) {
    return _repo.sendMessage(history, userMessage);
  }
}

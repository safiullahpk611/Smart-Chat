import '../entities/message.dart';


abstract class ChatRepository {
  
  Stream<String> sendMessage(List<Message> history, String userMessage);

 
  Future<List<Message>> loadChatHistory();
  Future<void> saveMessage(Message message);
  Future<void> clearHistory();
}

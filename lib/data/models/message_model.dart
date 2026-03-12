import '../../domain/entities/message.dart';

// serialization to/from Map for Hive storage.
// storing as Map<String, dynamic> in a Box<Map>

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.content,
    required super.role,
    required super.timestamp,
    super.isStreaming,
  });

  // Convert a plain Message  into a storable model
  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      content: message.content,
      role: message.role,
      timestamp: message.timestamp,
      isStreaming: message.isStreaming,
    );
  }

  factory MessageModel.fromMap(Map<dynamic, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      content: map['content'] as String,

      role: map['role'] == 'user' ? MessageRole.user : MessageRole.aiModel,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isStreaming: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'role': isUser ? 'user' : 'model',
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

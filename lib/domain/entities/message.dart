import 'package:equatable/equatable.dart';

// Which side of the conversation this message belongs to.

enum MessageRole { user, aiModel }

class Message extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;


  final bool isStreaming;

  const Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isStreaming = false,
  });

 
  Message copyWith({
    String? content,
    bool? isStreaming,
  }) {
    return Message(
      id: id,
      content: content ?? this.content,
      role: role,
      timestamp: timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  bool get isUser => role == MessageRole.user;

  @override
  List<Object?> get props => [id, content, role, timestamp, isStreaming];
}

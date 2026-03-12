import 'package:google_generative_ai/google_generative_ai.dart';

import '../../domain/entities/message.dart';


class GeminiRemoteDatasource {
  late final GenerativeModel _model;

  GeminiRemoteDatasource(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
 
      systemInstruction: Content.system(
        'You are SmartChat, a helpful and concise AI assistant. '
        'Format your answers with Markdown when it helps clarity.',
      ),
    );
  }

  // Converts  domain Message list into the format Gemini expects.
  
  List<Content> _toGeminiHistory(List<Message> messages) {
    return messages.map((m) {
      final role = m.isUser ? 'user' : 'model';
      return Content(role, [TextPart(m.content)]);
    }).toList();
  }

  // Returns a stream of text  — each  is a partial chunk.
  
  Stream<String> streamResponse(
    List<Message> history,
    String userMessage,
  ) async* {
    try {
      final chat = _model.startChat(history: _toGeminiHistory(history));

      final responseStream = chat.sendMessageStream(
        Content.text(userMessage),
      );

      await for (final chunk in responseStream) {
        final text = chunk.text;
        if (text != null && text.isNotEmpty) {
          yield text;
        }
      }
    } on GenerativeAIException catch (e) {
      // Re-throw with a cleaner message — the repo will catch this
      throw Exception('Gemini error: ${e.message}');
    }
  }
}

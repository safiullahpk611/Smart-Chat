import 'dart:convert';

import 'package:dio/dio.dart';
import '../../core/constant/app_constant.dart';


import '../../domain/entities/message.dart';

class AiRemoteDatasource {
  final Dio _dio;

  AiRemoteDatasource(String apiKey)
      : _dio = Dio(
          BaseOptions(
            // groqBaseUrl is /v1 — append the endpoint path in the post() call
            baseUrl: AppConstants.groqBaseUrl,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            // ResponseType.stream so we can read SSE chunks as they arrive
            responseType: ResponseType.stream,
          ),
        );

  // Converts our domain messages to the OpenAI messages format Groq expects
  List<Map<String, String>> _toGroqMessages(
    List<Message> history,
    String userMessage,
  ) {
    final groqMessages = <Map<String, String>>[
      {'role': 'system', 'content': AppConstants.systemPrompt},
      // previous conversation turns
      ...history.map((m) => {
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.content,
          }),
      // the new user message
      {'role': 'user', 'content': userMessage},
    ];
    return groqMessages;
  }

  Stream<String> streamResponse(
    List<Message> history,
    String userMessage,
  ) async* {
    try {
      final response = await _dio.post<ResponseBody>(
        '/chat/completions',
        data: {
          'model': AppConstants.groqModel,
          'messages': _toGroqMessages(history, userMessage),
          'stream': true,
        },
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data!.stream;

      // Buffer because a single TCP chunk can contain multiple SSE lines
      final buffer = StringBuffer();

      await for (final bytes in stream) {
        buffer.write(utf8.decode(bytes));
        final raw = buffer.toString();
        buffer.clear();

        // Each SSE event is separated by \n\n; split and process lines
        for (final line in raw.split('\n')) {
          final trimmed = line.trim();
          if (!trimmed.startsWith('data: ')) continue;

          final payload = trimmed.substring(6); // strip 'data: '
          if (payload == '[DONE]') return;

          try {
            final json = jsonDecode(payload) as Map<String, dynamic>;
            final content =
                json['choices']?[0]?['delta']?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              yield content;
            }
          } catch (_) {
            // malformed chunk — skip and keep going
          }
        }
      }
    } on DioException catch (e) {
      final msg = e.response?.statusMessage ?? e.message ?? 'Unknown error';
      throw Exception('Groq error: $msg');
    }
  }
}

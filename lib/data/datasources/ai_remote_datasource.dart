import 'dart:convert';

import 'package:dio/dio.dart';
import '../../core/constant/app_constant.dart';

import '../../domain/entities/message.dart';

class AiRemoteDatasource {
  final Dio _dio;

  AiRemoteDatasource(String apiKey)
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.groqBaseUrl,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
          connectTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          // receive timeout is longer because streaming takes time
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

  List<Map<String, String>> _toGroqMessages(
    List<Message> history,
    String userMessage,
  ) {
    final groqMessages = <Map<String, String>>[
      {'role': 'system', 'content': AppConstants.systemPrompt},
      // previous conversation turns
      ...history.map(
        (m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.content},
      ),
      // the new user message
      {'role': 'user', 'content': userMessage},
    ];
    return groqMessages;
  }

  Stream<String> streamResponse(
    List<Message> history,
    String userMessage,
  ) async* {
    print('calling groq api with model: ${AppConstants.groqModel}');
    print('history count befor sending: ${history.length}');
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

      print('got response, status: ${response.statusCode}');
      final stream = response.data!.stream;

      await for (final bytes in stream) {
        final text = utf8.decode(bytes);

        for (final line in text.split('\n')) {
          final trimmed = line.trim();
          if (!trimmed.startsWith('data: ')) continue;

          final payload = trimmed.substring(6); // remove the 'data: ' prefix
          if (payload == '[DONE]') return;

          try {
            final json = jsonDecode(payload) as Map<String, dynamic>;
            final content = json['choices']?[0]?['delta']?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              yield content;
            }
          } catch (_) {
            // skip malformed lines
          }
        }
      }
    } on DioException catch (e) {
      final msg = _friendlyError(e);
      print('dio error occured: $msg'); 
      throw Exception(msg);
    }
  }

  //  error types to messages a normal user can understand
  String _friendlyError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network and try again.';
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Your internet might be slow, please retry.';
      case DioExceptionType.receiveTimeout:
        return 'Server is taking too long to respond. Try again in a moment.';
      default:
        // for things like 401, 429 etc — show status message if available
        final status = e.response?.statusCode;
        if (status == 401) return 'Invalid API key. Check your Groq key.';
        if (status == 429) return 'Too many requests. Please wait a moment and retry.';
        return e.response?.statusMessage ?? e.message ?? 'Something went wrong.';
    }
  }
}

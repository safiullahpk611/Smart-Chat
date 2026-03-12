

class AppConstants {
  AppConstants._(); // prevent instantiation

  static const appName = 'SmartChat';


  static const groqApiKey =
      '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'; 
  static const groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const groqModel = 'llama-3.1-8b-instant';

  // Chat config
  static const maxStoredMessages = 100;
  static const systemPrompt =
      'You are a helpful AI assistant. Be concise, friendly and informative.';
}

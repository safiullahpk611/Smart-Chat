# SmartChat

SmartChat is a Flutter AI chat app built for a technical assignment.
It lets you chat with an AI and the response streams word by word, 
similar to how ChatGPT shows messages.

The app uses the Groq API with the llama model, structured using 
Clean Architecture with BLoC.

---

## What the app does

- Chat with an AI assistant
- AI response streams word by word instead of coming all at once
- Shows animated dots while waiting for response
- Shows a blinking cursor while text is still streaming
- Supports Markdown — code blocks and bold text render properly
- Dark / Light mode toggle
- Chat history saved locally with Hive — messages stay after restart
- Splash screen on app launch with fade animation
- Long press any message to copy it to clipboard

---

## Tech used

- Flutter + Dart
- flutter_bloc for state managment
- Dio for API calls and SSE streaming
- Groq API — llama-3.1-8b-instant model
- Hive for local storage
- flutter_markdown for rendering markdown

---

## Project Structure

Follows Clean Architecture.
Each layer only depends on the layer below it.
```
lib/
├── core/         # constants, theme, error classes
├── domain/       # pure dart — entities, repo interfaces, usecases
├── data/         # api calls, hive, implements domain repos
└── presentation/ # flutter UI + bloc
```

---

## Layers explained

### domain
Core logic of the app — no Flutter imports, pure Dart.
Contains the Message entity, ChatRepository interface and use cases:
- SendMessage
- SaveMessage  
- GetChatHistory
- ClearHistory

### data
Implements the logic defined in domain.
- AiRemoteDatasource handles Groq API and streaming chunks
- ChatRepositoryImpl connects datasource with Hive storage

### presentation
Flutter UI layer with widgets and BLoC.
ChatBloc listens for events and emits states.
UI simply reacts to those states.

---

## BLoC Events

| Event | When it happens |
|---|---|
| SendMessageEvent | user presses send |
| ReceiveStreamChunkEvent | new chunk arrives from API |
| LoadHistoryEvent | app starts, loads Hive data |
| ClearHistoryEvent | user clears the chat |

## BLoC States

| State | Meaning |
|---|---|
| ChatInitial | app just opened |
| ChatLoading | waiting for first chunk, shows dots |
| ChatStreaming | response coming chunk by chunk |
| ChatCompleted | response finished, saved to Hive |
| ChatError | something went wrong |

---

## How streaming works
```
User sends message
↓
emit ChatLoading (shows dots animation)
↓
Groq stream connection opens
↓
chunk arrives → ReceiveStreamChunkEvent
↓
emit ChatStreaming (message bubble updates)
↓
more chunks arrive...
↓
stream ends
↓
save message to Hive
↓
emit ChatCompleted
```

---

## How to run the project

1. Clone the repo
2. Run:
```bash
flutter pub get
```

3. Get a free Groq API key from: https://console.groq.com

4. Add key to `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "smart_chat",
      "request": "launch", 
      "type": "dart",
      "args": ["--dart-define=GROQ_API_KEY=your_key_here"]
    }
  ]
}
```

5. Run the app:
```bash
flutter run --dart-define=GROQ_API_KEY=your_key_here
```

---

## Notes

- Groq free tier is generous, normal usage should be fine
- To change AI model update `groqModel` in `app_constants.dart`
- Theme toggle doesnt persist after restart — could add 
  shared_preferences later
- Long press any message bubble to copy text to clipboard
- Clear chat button wipes the Hive box completely
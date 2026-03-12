# SmartChat

A Flutter AI chat app that streams responses in real time, built for a technical assignment. Uses Groq API under the hood with clean architecture and BLoC.

---

## What it does

- Chat with an AI (llama model via Groq)
- Responses stream word by word like chatgpt
- Animated dots while waiting for response
- Blinking cursor while text is comming in
- Markdown support so code blocks and bold text render properly
- Dark/light mode toggle
- Chat history saved localy with Hive so messages dont dissapear on restart

---

## Tech used

- Flutter + Dart
- flutter_bloc for state managment
- Dio for API calls + SSE streaming
- Groq API (llama-3.1-8b-instant model)
- Hive for local storage
- flutter_markdown

---

## Project Structure

Follows Clean Architecture. Each layer only depends on the layer below it, never the other way around.

```
lib/
├── core/               # constants, theme, error classes
├── domain/             # pure dart — entities, repo interfaces, usecases
├── data/               # api calls, hive, implements domain repos
└── presentation/       # flutter UI + bloc
```

### Layers explained

**domain** — the heart of the app. Has the `Message` entity, abstract `ChatRepository`, and usecases like `SendMessage`, `SaveMessage` etc. Zero flutter imports here.

**data** — implements everything from domain. `AiRemoteDatasource` handles the Groq API call and parses the SSE stream chunks. `ChatRepositoryImpl` wires the datasource with Hive storage.

**presentation** — Flutter widgets and BLoC. The `ChatBloc` listens to events and emits states. UI just reacts to states.

### BLoC Events

| Event                     | When                        |
| ------------------------- | --------------------------- |
| `SendMessageEvent`        | user hits send              |
| `ReceiveStreamChunkEvent` | each chunk arrives from api |
| `LoadHistoryEvent`        | app starts, loads hive data |
| `ClearHistoryEvent`       | user clears the chat        |

### BLoC States

| State           | Meaning                                      |
| --------------- | -------------------------------------------- |
| `Initial`       | app just opened                              |
| `Loading`       | waiting for first chunk, shows bouncing dots |
| `ChatStreaming` | chunks arriving, bubble filling up           |
| `ChatCompleted` | done, saved to hive                          |
| `ChatError`     | something went wrong                         |

### How streaming works

```
user sends msg
     ↓
emit Loading  (dots animation shows)
     ↓
Groq stream opens
     ↓
chunk → ReceiveStreamChunkEvent → emit ChatStreaming  (bubble updates)
chunk → ReceiveStreamChunkEvent → emit ChatStreaming
     ↓
stream ends → save to Hive → emit ChatCompleted
```

---

## How to run

1. Clone the repo and run `flutter pub get`

2. Get a free Groq API key from https://console.groq.com

3. Open `lib/core/constant/app_constant.dart` and paste your key:

   ```dart
   static const groqApiKey = 'your_key_here';
   ```

   > this file is in .gitignore so the key wont get pushed to github

4. Run with `flutter run`

---

## Notes

- Groq free tier is pretty generous, shouldnt hit limits easily with normal usage
- If you want to swap the AI model just change `groqModel` in app_constant.dart
- Theme toggle doesnt persist across restarts (would use shared_preferences for that, maybe later)
- Hive box gets wiped when you press clear chat

SmartChat

SmartChat is a small Flutter AI chat app I built for a technical assignment.
It lets you chat with an AI and the response comes streaming word by word, similar to how ChatGPT shows messages.

The app uses the Groq API with the llama model, and the project is structured using Clean Architecture with BLoC.

What the app does

You can chat with an AI assistant

AI response streams word by word instead of coming all at once

Shows animated dots while waiting for response

Shows a blinking cursor while text is still coming

Supports Markdown, so code blocks and bold text render properly

Dark / Light mode toggle in the UI

Chat history saved locally using Hive, so messages stay even after app restart

Tech used

The app is built using:

Flutter + Dart

flutter_bloc for state managment

Dio for API calls and SSE streaming

Groq API using llama-3.1-8b-instant model

Hive for local storage

flutter_markdown for rendering markdown text

Project Structure

The project follows Clean Architecture.
Each layer only depends on the layer below it, not the other way around.

lib/
├── core/ # constants, theme, error classes
├── domain/ # pure dart — entities, repo interfaces, usecases
├── data/ # api calls, hive, implements domain repos
└── presentation/ # flutter UI + bloc
Layers explained
domain

This is the core logic of the app.
It contains the Message entity, the ChatRepository interface, and use cases like:

SendMessage

SaveMessage

GetChatHistory

ClearHistory

There are no Flutter imports here, just pure Dart.

data

This layer implements the logic defined in domain.

AiRemoteDatasource is responsible for calling the Groq API and handling the streaming response chunks.

ChatRepositoryImpl connects the remote datasource with Hive local storage.

presentation

This is the Flutter UI layer.

It contains the widgets and the BLoC.
The ChatBloc listens for events and emits states.
The UI simply reacts to those states.

BLoC Events
Event When it happens
SendMessageEvent when user presses send
ReceiveStreamChunkEvent whenever a new chunk arrives from API
LoadHistoryEvent when the app starts and loads Hive data
ClearHistoryEvent when user clears the chat
BLoC States
State Meaning
Initial app just opened
Loading waiting for first chunk, shows animated dots
ChatStreaming response is coming chunk by chunk
ChatCompleted response finished and saved to Hive
ChatError something went wrong
How streaming works

Basically the flow looks like this:

User sends message
↓
emit Loading (shows dots animation)
↓
Groq stream connection opens
↓
chunk arrives → ReceiveStreamChunkEvent
↓
emit ChatStreaming (message bubble updates)
↓
more chunks arrive
↓
stream ends
↓
save message to Hive
↓
emit ChatCompleted
How to run the project

Clone the repo

Run

flutter pub get

Start the app

flutter run

The Groq API key is already added in:

lib/core/constant/app_constant.dart

so it should work directly for testing.

Notes

Groq free tier is quite generous so normal usage should be fine

If you want to change the AI model, just update groqModel in app_constant.dart

Theme toggle currently doesnt persist after restart (could be done using shared_preferences later)

When you press clear chat, the Hive box gets wiped

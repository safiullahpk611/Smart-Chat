import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/ai_remote_datasource.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'domain/usecases/clear_history.dart';
import 'domain/usecases/get_chat_history.dart';
import 'domain/usecases/send_message.dart';
import 'presentation/bloc/chat_bloc.dart';
import 'presentation/bloc/chat_event.dart';
import 'presentation/pages/chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // TODO: register Hive type adapters in Phase 7

  runApp(const SmartChatApp());
}

class SmartChatApp extends StatelessWidget {
  const SmartChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Manual DI — good enough for this project, no need for get_it here
    final datasource = AiRemoteDatasource(AppConstants.groqApiKey);
    final repo = ChatRepositoryImpl(datasource);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // toggle added in Phase 7
      home: BlocProvider(
        create: (_) => ChatBloc(
          sendMessage: SendMessage(repo),
          getHistory: GetChatHistory(repo),
          clearHistory: ClearHistory(repo),
        )..add(const LoadHistoryEvent()), // load Hive history on start
        child: const ChatPage(),
      ),
    );
  }
}

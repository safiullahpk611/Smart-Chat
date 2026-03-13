import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constant/app_constant.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/ai_remote_datasource.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'domain/usecases/clear_history.dart';
import 'domain/usecases/get_chat_history.dart';
import 'domain/usecases/save_message.dart';
import 'domain/usecases/send_message.dart';
import 'presentation/bloc/chat_bloc.dart';
import 'presentation/bloc/chat_event.dart';
import 'presentation/bloc/theme_cubit.dart';
import 'presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(const SmartChatApp());
}

class SmartChatApp extends StatelessWidget {
  const SmartChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final datasource = AiRemoteDatasource(AppConstants.groqApiKey);
    final repo = ChatRepositoryImpl(datasource);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => ChatBloc(
            sendMessage: SendMessage(repo),
            getHistory: GetChatHistory(repo),
            clearHistory: ClearHistory(repo),
            saveMessage: SaveMessage(repo),
          )..add(const LoadHistoryEvent()),
        ),
      ],
     
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: const SplashPage(),
        ),
      ),
    );
  }
}

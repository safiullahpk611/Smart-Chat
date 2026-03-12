import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Hive.initFlutter();

  runApp(const SmartChatApp());
}

class SmartChatApp extends StatelessWidget {
  const SmartChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    
      themeMode: ThemeMode.system,
    
      home: const _PlaceholderHome(),
    );
  }
}


class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 72, color: colors.primary),
            const SizedBox(height: 16),
            Text(
              'smart chat app',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Folder structure  dependencies set up.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

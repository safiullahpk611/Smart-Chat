import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

const _themeKey = 'isDark';

// change the app theme and persist it in hive
class ThemeCubit extends Cubit<ThemeMode> {
  final Box _box;

  ThemeCubit(Box settingsBox)
      : _box = settingsBox,
        super(
          settingsBox.get(_themeKey, defaultValue: false) as bool
              ? ThemeMode.dark
              : ThemeMode.light,
        );

  void toggle() {
    final goingDark = state == ThemeMode.light;
    _box.put(_themeKey, goingDark);
    emit(goingDark ? ThemeMode.dark : ThemeMode.light);
  }

  bool get isDark => state == ThemeMode.dark;
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/theme.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(_darkTheme);

  static final ThemeData _lightTheme = AppTheme.lightTheme;

  static final ThemeData _darkTheme = AppTheme.darkTheme;

  void toggleTheme() {
    emit(state == _darkTheme ? _lightTheme : _darkTheme);
  }
}
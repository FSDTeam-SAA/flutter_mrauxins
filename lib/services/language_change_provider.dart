import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

extension LanguageExtension on Languages {
  String get code {
    switch (this) {
      case Languages.dutch:
        return Languages.dutch.code;
      case Languages.german:
        return Languages.german.code;
      case Languages.spanish:
        return Languages.spanish.code;
      case Languages.english:
        return Languages.english.code;
      default:
        return 'en'; // Default to Czech
    }
  }
}

class LanguageChangeProvider with ChangeNotifier {
  Locale _currentLocal = Locale(AppPreference.getLanguage());
  Languages languagesType = Languages.english;

  LanguageChangeProvider() {
    initLanguageType();
  }

  Locale get currentLocal => _currentLocal;

  void initLanguageType() {
    switch (_currentLocal.languageCode) {
      case 'en':
        languagesType = Languages.english;
        break;
      case 'es':
        languagesType = Languages.spanish;
        break;
      case 'de':
        languagesType = Languages.german;
        break;
      case 'nl':
        languagesType = Languages.dutch;
        break;
      // default:
      //   languagesType = Languages.czech;
      //   break;
    }
  }

  void selectLanguagesType(Languages languagesTypeValue) {
    languagesType = languagesTypeValue;
    log("Selected language type: ${languagesType.code}");
    notifyListeners();
    // changeLocale();
  }

  void selectAndSetLanguages(Languages languagesTypeValue) {
    languagesType = languagesTypeValue;
    log("Selected language type: ${languagesType.code}");
    notifyListeners();
    changeLocale();
  }

  Future<void> changeLocale() async {
    log("Change locale: ${languagesType.code}");
    if (!S.delegate.supportedLocales.contains(Locale(languagesType.code))) {
      return;
    }
    _currentLocal = Locale(languagesType.code);
    await AppPreference.setLanguage(_currentLocal.languageCode);
    // Get.updateLocale(_currentLocal);
    notifyListeners();
  }
}

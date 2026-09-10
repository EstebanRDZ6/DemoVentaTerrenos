import 'package:flutter/foundation.dart';

enum AppLanguage { es, en, pt }

class AppLocale {
  AppLocale._();
  static final AppLocale instance = AppLocale._();

  final ValueNotifier<AppLanguage> language = ValueNotifier<AppLanguage>(AppLanguage.es);

  void setLanguage(AppLanguage value) => language.value = value;

  String text(String es, String en, String pt) {
    switch (language.value) {
      case AppLanguage.es:
        return es;
      case AppLanguage.en:
        return en;
      case AppLanguage.pt:
        return pt;
    }
  }

  String get languageLabel {
    switch (language.value) {
      case AppLanguage.es:
        return 'Español';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.pt:
        return 'Português';
    }
  }
}

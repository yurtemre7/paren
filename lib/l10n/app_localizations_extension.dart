import 'package:flutter/widgets.dart';
import 'package:paren/l10n/app_localizations.dart';

extension AppLocaleExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension FullName on Locale {
  String fullName() {
    return switch (languageCode) {
      'en' => 'English',
      'ja' => '日本語',
      'de' => 'Deutsch',
      'tr' => 'Türkçe',
      _ => '',
    };
  }
}

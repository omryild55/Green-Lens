// lib/l10n/app_localizations.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = {};

  Future<void> load() async {
    // JSON'dan okuyabilirsin veya buradan manuel ekle
    _localizedStrings = {
      'app_name': 'GreenLens Pro',
      'camera': 'Kamera',
      'gallery': 'Galeri',
      'identify': 'Bitkiyi Tanı',
      'history': 'Geçmiş',
      'profile': 'Profil',
      'species': 'Türler',
      'dark_mode': 'Koyu Tema',
      'notifications': 'Bildirimler',
      'save_history': 'Geçmiş Kaydet',
      'language': 'Dil Seçeneği',
      'about': 'Hakkında',
      'logout': 'Çıkış Yap',
      'scan_plant': 'Bitki Tara',
      'scientific_name': 'Bilimsel Ad',
      'common_name': 'Türkçe Karşılığı',
      'about_plant': 'Bitki Hakkında',
      'confidence': 'Tanıma Güveni',
      'new_scan': 'Yeni Tarama',
      'empty_history': 'Henüz bir keşif yapılmadı',
      'scan_hint': 'Bir bitki fotoğraflayarak keşfetmeye başla!',
    };
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['tr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
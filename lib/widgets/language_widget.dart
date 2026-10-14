import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/main_provider.dart';
import 'flag_widget.dart';
import 'language.dart';

class LanguageWidget extends StatelessWidget {
  const LanguageWidget({super.key});

  String _getCountryCode(String lang) {
    if (lang.contains('English')) return 'GB';
    if (lang.contains('Polski')) return 'PL';
    if (lang.contains('Russian')) return 'RU';
    return 'GB';
  }

  String _getNativeName(String lang) {
    if (lang.contains('English')) return 'English';
    if (lang.contains('Polski')) return 'Polski';
    if (lang.contains('Russian')) return 'Русский';
    return lang;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, data, _) {
        return PopupMenuButton<AppLanguage>(
          constraints: const BoxConstraints(maxWidth: 150),
          color: kBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: kLine, width: kLineWidth),
          ),
          child: FlagWidget(
            country: context.locale.toString() == 'en_US'
                ? 'GB'
                : context.locale.toString() == 'pl_PL'
                ? 'PL'
                : 'RU',
          ),
          onSelected: (value) async {
            final Locale locale;
            if (value.language.contains('Polski')) {
              locale = const Locale('pl', 'PL');
            } else if (value.language.contains('Russian')) {
              locale = const Locale('ru', 'RU');
            } else {
              locale = const Locale('en', 'US');
            }
            await context.setLocale(locale);
            if (!context.mounted) return;
            data.setLanguage(value, context);
          },
          itemBuilder: (context) {
            return languageList.map<PopupMenuEntry<AppLanguage>>((
              valueLanguage,
            ) {
              return PopupMenuItem<AppLanguage>(
                value: valueLanguage,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlagWidget(
                      country: _getCountryCode(valueLanguage.language),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getNativeName(valueLanguage.language),
                      style: kTextStyle,
                    ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}

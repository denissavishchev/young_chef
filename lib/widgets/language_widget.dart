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
          constraints: const BoxConstraints(
            maxWidth: 150,
          ),
          color: kWhite,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: kGrey.withValues(alpha: 0.2), width: 1),
          ),
          child: FlagWidget(
            country: context.locale.toString() == 'en_US'
                ? 'GB'
                : context.locale.toString() == 'pl_PL'
                ? 'PL'
                : 'RU',
          ),
          onSelected: (value) {
            data.setLanguage(value, context);

            if (value.language.contains('English')) {
              context.setLocale(const Locale('en', 'US'));
            } else if (value.language.contains('Polski')) {
              context.setLocale(const Locale('pl', 'PL'));
            } else if (value.language.contains('Russian')) {
              context.setLocale(const Locale('ru', 'RU'));
            }
          },
          itemBuilder: (context) {
            return languageList.map<PopupMenuEntry<AppLanguage>>((valueLanguage) {
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
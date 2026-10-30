import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final kTextStyle = TextStyle(
  color: kLine,
  fontWeight: FontWeight.bold,
  fontSize: 12.sp,
);

final kBigTextStyle = TextStyle(
  color: kLine,
  fontWeight: FontWeight.bold,
  fontSize: 15.sp,
);

/// Screen title shared by every top-level screen.
final kHeaderStyle = kBigTextStyle.copyWith(
  fontSize: 24.sp,
  shadows: kIconShadow,
);

// Outline UI palette (recipe screen + bottom bar).
const kBg = Color(0xFFDCE4EC);
const kLine = Color(0xFF16171B);
const kGlow = Color(0xFFB4C2E0);
const kShadow = Color(
  0xFF9EA2AB,
); // neutral gray under tiles, icons and the bar
const kLineWidth = 2.5;

/// Tile with a thick dark outline and a soft glow, the base of this UI
/// (same look as the bottom bar). Fill defaults to the screen background.
BoxDecoration outlineDecoration({
  double radius = 28,
  Color color = kBg,
  bool circle = false,
}) => BoxDecoration(
  color: color,
  shape: circle ? BoxShape.circle : BoxShape.rectangle,
  borderRadius: circle ? null : BorderRadius.circular(radius),
  border: Border.all(color: kLine, width: kLineWidth),
  boxShadow: [
    BoxShadow(
      color: kShadow.withValues(alpha: 0.8),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ],
);

final textFieldDecoration = InputDecoration(
  hintStyle: kTextStyle,
  enabledBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
  ),
  focusedBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
  ),
  focusedErrorBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
  ),
  errorBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
  ),
);

/// Black-on-glow slider look shared by the screens.
SliderThemeData outlineSliderTheme() => SliderThemeData(
  trackHeight: 8,
  thumbColor: kLine,
  rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 11),
  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
  activeTrackColor: kLine,
  inactiveTrackColor: kGlow,
  rangeTickMarkShape: const RoundRangeSliderTickMarkShape(tickMarkRadius: 0),
  tickMarkShape: SliderTickMarkShape.noTickMark,
  activeTickMarkColor: Colors.transparent,
  inactiveTickMarkColor: Colors.transparent,
  valueIndicatorColor: kLine,
  showValueIndicator: ShowValueIndicator.onDrag,
  overlayColor: kLine.withValues(alpha: 0.12),
);

/// Soft glow under icons, same as the bottom bar's.
const kIconShadow = [
  Shadow(color: kShadow, blurRadius: 6, offset: Offset(2, 4)),
];

final _kcalUnit = RegExp(r'\b(kcal|ккал)\b', caseSensitive: false);
final _gramUnit = RegExp(r'(?<=\d)\s*(g|gr|г)\b', caseSensitive: false);

/// Model output carries units in whatever language it picked; show them in the
/// app language.
String localizeUnits(String value) => value
    .replaceAll(_kcalUnit, 'kcalUnit'.tr())
    .replaceAllMapped(_gramUnit, (_) => ' ${'gramUnit'.tr()}');

/// Full English name of the app language, for model prompts (a bare code like
/// "pl" is easily overridden by a prompt written in another language).
String promptLanguage(BuildContext context) =>
    switch (context.locale.languageCode) {
      'pl' => 'Polish (polski)',
      'ru' => 'Russian (русский)',
      _ => 'English',
    };

/// Release date shown under the version in settings (iOS and Android).
/// Update together with `version:` in pubspec.yaml.
final kReleaseDate = DateTime(2026, 10, 30);

/// Dietary restrictions the user can switch on in settings: id -> prompt rule.
const kDietPrompts = <String, String>{
  'vegan':
      'Dieta wegańska: przepis w 100% wegański — żadnych produktów pochodzenia zwierzęcego (mięso, ryby, nabiał, jajka, miód itp.).',
  'vegetarian':
      'Dieta wegetariańska: bez mięsa, drobiu, ryb i owoców morza (nabiał i jajka są dozwolone).',
  'glutenFree':
      'Bez glutenu: żadnej pszenicy, żyta, jęczmienia, owsa niecertyfikowanego ani produktów je zawierających (zwykły makaron, chleb, mąka, bułka tarta, sos sojowy).',
  'lactoseFree':
      'Bez laktozy: żadnego mleka, śmietany, jogurtu, sera, masła ani innych produktów z laktozą (dozwolone zamienniki roślinne lub produkty bezlaktozowe).',
  'sugarFree':
      'Bez cukru: żadnego dodanego cukru, miodu, syropów ani słodzików cukrowych.',
  'lowCarb':
      'Niskowęglowodanowa / keto: minimum węglowodanów, bez makaronu, ryżu, ziemniaków, chleba i cukru.',
  'halal': 'Halal: bez wieprzowiny, alkoholu i produktów niezgodnych z halal.',
  'kosher':
      'Koszerne: bez wieprzowiny i owoców morza, bez łączenia mięsa z nabiałem.',
};

/// Meal types the user can pick: id -> prompt rule (what the meal consists of).
const kMealPrompts = <String, String>{
  'dish':
      'Danie: dowolne danie, niezwiązane z porą dnia — dobierz je do podanych produktów.',
  'breakfast':
      'Śniadanie: lekki, energetyczny posiłek poranny (np. jajka, owsianka, naleśniki, kanapki, jogurt z owocami).',
  'lunch':
      'Obiad: główny, sycący posiłek dnia (np. zupa lub danie główne z mięsa, ryby albo warzyw z dodatkiem ryżu, makaronu lub ziemniaków).',
  'dinner':
      'Kolacja: lekki, łatwo strawny posiłek wieczorny (np. sałatka, kanapki, ciepłe warzywa, lekka zupa).',
  'snack':
      'Przekąska: mała porcja między posiłkami (np. owoce, słupki warzyw, hummus, małe kanapki, kulki mocy).',
  'dessert':
      'Deser: słodki akcent po posiłku (np. deser owocowy, budyń, mus, naleśniki, pieczone owoce), bez nadmiaru cukru.',
};

/// Dish types available when the meal type is plain "dish": id -> prompt rule.
const kDishTypePrompts = <String, String>{
  'soup': 'Typ dania: zupa (płynne danie podawane na ciepło lub zimno).',
  'salad': 'Typ dania: sałatka.',
  'main': 'Typ dania: danie główne (mięso, ryba lub warzywa z dodatkiem).',
  'pasta': 'Typ dania: danie na bazie makaronu.',
  'sandwich': 'Typ dania: kanapka lub wrap.',
  'smoothie': 'Typ dania: koktajl / smoothie do wypicia.',
  'bowl': 'Typ dania: miska (bowl) — baza zbożowa lub warzywna z dodatkami.',
};

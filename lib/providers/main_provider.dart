import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../constants.dart';
import '../models/answer_model.dart';
import '../screens/recipe_screen.dart';
import '../widgets/language.dart';

class MainProvider with ChangeNotifier {
  TextEditingController questionController = TextEditingController();
  TextEditingController allergiesController = TextEditingController();
  TextEditingController notLikeController = TextEditingController();

  final SpeechToText speech = SpeechToText();
  bool isListening = false;
  bool isScanning = false;
  String baseText = '';

  String selectedLanguage = 'English - UK';

  bool isLoading = false;
  RecipeResponse answer = RecipeResponse(
    recipeName: '',
    ingredients: [],
    instructions: [],
    calories: '',
    protein: '',
    carbohydrates: '',
    fat: '',
  );

  /// Key of the current [answer] in the favorites box, null if not saved.
  String? favoriteId;

  /// True when a recipe is stored (also across app restarts) that can be
  /// continued from the main screen.
  bool hasCurrentRecipe = false;

  String answerError = '';

  bool onlyUserIngredients = true;
  RangeValues caloriesRange = const RangeValues(100, 1000);
  bool isRegularDiet = true;
  bool isKids = false;
  double kidsAge = 3;
  bool isMale = false;
  bool isFemale = false;
  double timeForCooking = 10;
  double cookingSkillLevel = 1;
  final Set<String> diets = {};
  String mealType = 'dish';

  /// Chosen only when [mealType] is 'dish'; null means any dish.
  String? dishType;

  bool get isVegan => diets.contains('vegan');

  final aiModel = GenerativeModel(
    model: 'gemini-2.5-flash-lite',
    apiKey: dotenv.env['GOOGLE_AI_STUDIO_KEY'].toString(),
  );

  String get _sourceRule => onlyUserIngredients
      ? "Użyj WYŁĄCZNIE podanych produktów. Nie dodawaj żadnych innych składników, łącznie z solą, pieprzem czy oliwą, jeśli nie zostały wymienione."
      : "Bazuj przede wszystkim na podanych produktach. Możesz dodać podstawowe składniki uzupełniające typu sól, pieprz, oliwa, przyprawy, jeśli są potrzebne — ale nie dodawaj nowych głównych składników (np. dodatkowego mięsa, nabiału czy warzyw, których nie ma na liście).";

  String get _mealRule {
    final dish = mealType == 'dish' && dishType != null
        ? '\n              ${kDishTypePrompts[dishType]}'
        : '';
    return '${kMealPrompts[mealType]}$dish';
  }

  String get _dietsRule => diets.isEmpty
      ? "Brak ograniczeń żywieniowych."
      : "Przepis MUSI spełniać WSZYSTKIE poniższe wymagania:\n${diets.map((d) => '              * ${kDietPrompts[d]}').join('\n')}";

  String get _dislikedRule => notLikeController.text.isEmpty
      ? "Brak ograniczeń."
      : "NIE używaj w przepisie następujących składników: ${notLikeController.text}.";

  String get _allergiesRule => allergiesController.text.isEmpty
      ? "Brak alergii do uwzględnienia."
      : "Osoba jest uczulona na: ${allergiesController.text}. Pod żadnym pozorem nie używaj tych składników ani produktów je zawierających, nawet jeśli zostały podane jako dostępne produkty.";

  String _adultPrompt(String language) =>
      '''
          LANGUAGE RULE (highest priority): write EVERY text value of the JSON (recipeName, ingredients, instructions, units) in $language, no matter in which language the products below are given or this prompt is written. Translate the products' names if needed. JSON keys stay exactly as in the structure.

          Jesteś doświadczonym doradcą kulinarnym, który tworzy przepisy dla dorosłych.

            Na podstawie podanych produktów: ${questionController.text}

            WAŻNE — priorytet składników: Podane powyżej produkty (${questionController.text}) są PRIORYTETEM i podstawą przepisu. W razie jakiegokolwiek konfliktu między nimi a poniższymi parametrami (np. typem diety czy poziomem umiejętności), to one decydują o kierunku przepisu. Jedynym wyjątkiem są alergie — jeśli któryś z podanych produktów znajduje się na liście alergii, NIE używaj go, nawet jeśli został podany przez użytkownika.

            Dodatkowe parametry, które MUSISZ uwzględnić:

            - Źródło składników: $_sourceRule

            - Rodzaj posiłku: $_mealRule

            - Kaloryczność: Całe danie powinno mieścić się w zakresie od ${caloriesRange.start} do ${caloriesRange.end} kcal.

            - Typ diety: ${isRegularDiet ? "Standardowa, zbalansowana dieta." : "Dieta dopasowana do potrzeb sportowca / dnia treningowego — uwzględnij odpowiednią podaż białka i węglowodanów wspierających regenerację i energię."}

            - Płeć osoby, dla której przygotowywany jest przepis: ${isMale == isFemale
          ? "nieokreślona / dowolna — nie uwzględniaj płci, przepis ma być odpowiedni zarówno dla kobiet, jak i mężczyzn."
          : isMale
          ? "mężczyzna (dostosuj orientacyjne potrzeby kaloryczne/makroskładnikowe, jeśli ma to znaczenie)."
          : "kobieta (dostosuj orientacyjne potrzeby kaloryczne/makroskładnikowe, jeśli ma to znaczenie)."}

            - Czas przygotowania: Przepis musi być możliwy do wykonania w maksymalnie $timeForCooking minut.

            - Poziom umiejętności kulinarnych (skala 1–5, gdzie 1 = brak doświadczenia, tylko podstawowe czynności, 5 = zaawansowany, swobodne użycie noża, kuchenki i innych narzędzi): $cookingSkillLevel.
              Dostosuj złożoność technik kulinarnych i liczbę kroków do tego poziomu.

            - Ograniczenia żywieniowe: $_dietsRule

            - Składniki, których NIE lubi/nie chce: $_dislikedRule

            - Alergie: $_allergiesRule

            Wygeneruj jeden przepis kulinarny, który spełnia następujące wymagania:
            - Jest zrozumiały, a jego trudność i złożoność technik kulinarnych są dopasowane do podanego poziomu umiejętności
            - Da się go przygotować w podanym limicie czasu, przy użyciu podstawowych narzędzi kuchennych
            - Jest zdrowy (zbalansowany, bez nadmiaru cukru, soli i tłuszczu)
            - Spełnia wszystkie powyższe parametry (źródło składników, kaloryczność, typ diety, ograniczenia żywieniowe, niechciane składniki, alergie)
            - Pole "instructions" MUSI być tablicą stringów: każdy element to JEDEN osobny krok przygotowania.

            Odpowiedz WYŁĄCZNIE w formacie czystego JSON (bez markdown, bez ```json, bez żadnego tekstu przed/po), o następującej strukturze:

            {
              "recipeName": "Nazwa przepisu",
              "ingredients": ["składnik 1 z ilością", "składnik 2 z ilością"],
              "instructions": ["krok 1", "krok 2"],
              "calories": "Wartość kaloryczna całego dania w kcal (tylko liczba + jednostka)",
              "protein": "ilość białka w gramach (tylko liczba + jednostka, bez słów typu 'około' i bez znaku ~)",
              "carbohydrates": "ilość węglowodanów w gramach (tylko liczba + jednostka, bez słów typu 'około' i bez znaku ~)",
              "fat": "ilość tłuszczu w gramach (tylko liczba + jednostka, bez słów typu 'około' i bez znaku ~)",
              "isVegan": false (true tylko jeśli przepis jest w pełni wegański)
            }

            Wszystkie wartości tekstowe (nazwa, składniki, kroki, jednostki) MUSZĄ być w języku: $language. Nie używaj polskiego, jeśli to nie jest ten język.
            Nie dodawaj żadnego tekstu poza samym obiektem JSON.
          ''';

  String _kidsPrompt(String language) =>
      '''
          LANGUAGE RULE (highest priority): write EVERY text value of the JSON (recipeName, ingredients, instructions, units) in $language, no matter in which language the products below are given or this prompt is written. Translate the products' names if needed. JSON keys stay exactly as in the structure.

          Jesteś doświadczonym dietetykiem dziecięcym i doradcą kulinarnym, który tworzy bezpieczne przepisy dla dzieci.

            Na podstawie podanych produktów: ${questionController.text}

            Przepis jest przygotowywany dla dziecka w wieku ${kidsAge.toInt()} lat (skala 0–5 lat; 0 = niemowlę poniżej 1. roku życia).

            WAŻNE — priorytet składników: Podane powyżej produkty (${questionController.text}) są podstawą przepisu. Jedynym wyjątkiem są alergie i zasady bezpieczeństwa dla dziecka — jeśli któryś z podanych produktów jest na liście alergii lub jest niebezpieczny dla dziecka w tym wieku, NIE używaj go.

            Zasady dla dziecka (mają pierwszeństwo nad wszystkim innym):
              * Dopasuj konsystencję i formę dania do wieku: 0 lat — wyłącznie gładkie purée lub bardzo miękkie, rozgniecione papki, bez kawałków; 1 rok — miękkie, drobno posiekane lub rozgniecione kawałki; 2–3 lata — małe, miękkie kawałki łatwe do gryzienia; 4–5 lat — normalne, ale pokrojone na małe kawałki, bez twardych elementów.
              * Bezpieczeństwo: ZERO ryzyka zadławienia (żadnych całych orzechów, całych winogron, twardych surowych warzyw, popcornu, pestek, ości); bez soli, bez cukru, bez miodu (dla dzieci poniżej 1. roku życia miód jest zakazany), bez ostrych przypraw, bez surowych jaj, surowego mięsa i ryb, bez alkoholu i kofeiny.
              * Odżywianie: łagodny smak, wartościowe składniki (żelazo, wapń, zdrowe tłuszcze, błonnik), porcja dopasowana do wieku dziecka (dużo mniejsza niż dla dorosłego). Pola kalorii i makroskładników podaj dla tej dziecięcej porcji.
              * Metody obróbki: ZAKAZ smażenia (także na głębokim tłuszczu i na patelni) oraz pieczenia (piekarnik, grill, opiekanie, zapiekanie). Dozwolone wyłącznie gotowanie, gotowanie na parze, duszenie w wodzie/bulionie lub podanie na surowo (tylko produkty bezpieczne w takiej formie, np. dojrzały owoc w formie purée).
              * Adresat instrukcji: przepis przygotowuje RODZIC lub opiekun, nie dziecko. Pisz kroki bezpośrednio do rodzica (np. "Ugotuj...", "Rozgnieć...") i NIE dodawaj uwag w stylu "to robi dorosły" ani "dziecko może pomóc". Na końcu dodaj krok, by potrawę ostudzić i sprawdzić jej temperaturę przed podaniem dziecku.
              * Nazwa przepisu (pole "recipeName") MUSI być bajkowa i zabawna, z nawiązaniem do postaci z bajek, np. "Zupka Kubusia Puchatka", "Marchewkowe puree Krecika", "Magiczna owsianka Elsy", "Papka Świnki Peppy". Wybierz bohatera bajkowego pasującego do głównego składnika i dostosowanego do wieku dziecka, nazwa ma być krótka i radosna.

            Dodatkowe parametry, które MUSISZ uwzględnić:

            - Źródło składników: $_sourceRule

            - Rodzaj posiłku (dla dziecka): $_mealRule Dostosuj go do zasad dla dziecka powyżej — one mają pierwszeństwo (np. deser bez cukru i miodu, oparty na owocach; zakaz pieczenia i smażenia obowiązuje także tutaj; koktajl tylko gładki, dla dzieci od 1. roku życia).

            - Czas przygotowania: Przepis musi być możliwy do wykonania w maksymalnie $timeForCooking minut.

            - Poziom umiejętności kulinarnych rodzica (skala 1–5, gdzie 1 = brak doświadczenia, 5 = zaawansowany): $cookingSkillLevel.
              Dostosuj złożoność technik kulinarnych i liczbę kroków do tego poziomu.

            - Ograniczenia żywieniowe: $_dietsRule

            - Składniki, których dziecko NIE lubi/nie chce: $_dislikedRule

            - Alergie: $_allergiesRule

            Pole "instructions" MUSI być tablicą stringów: każdy element to JEDEN osobny krok przygotowania.

            Odpowiedz WYŁĄCZNIE w formacie czystego JSON (bez markdown, bez ```json, bez żadnego tekstu przed/po), o następującej strukturze:

            {
              "recipeName": "Bajkowa nazwa przepisu",
              "ingredients": ["składnik 1 z ilością", "składnik 2 z ilością"],
              "instructions": ["krok 1", "krok 2"],
              "calories": "Wartość kaloryczna dziecięcej porcji w kcal (tylko liczba + jednostka)",
              "protein": "ilość białka w gramach (tylko liczba + jednostka, bez słów typu 'około' i bez znaku ~)",
              "carbohydrates": "ilość węglowodanów w gramach (tylko liczba + jednostka, bez słów typu 'około' i bez znaku ~)",
              "fat": "ilość tłuszczu w gramach (tylko liczba + jednostka, bez słów typu 'około' i bez znaku ~)",
              "isVegan": false (true tylko jeśli przepis jest w pełni wegański)
            }

            Wszystkie wartości tekstowe (nazwa, składniki, kroki, jednostki) MUSZĄ być w języku: $language. Nie używaj polskiego, jeśli to nie jest ten język.
            Nie dodawaj żadnego tekstu poza samym obiektem JSON.
          ''';

  Future<void> getRecipe(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    final language = promptLanguage(context);
    final prompt = [
      Content.multi([
        TextPart(isKids ? _kidsPrompt(language) : _adultPrompt(language)),
      ]),
    ];
    try {
      final response = await aiModel.generateContent(prompt);

      if (response.text != null) {
        final rawAnswer = response.text ?? '';
        final cleaned = rawAnswer
            .replaceAll(RegExp(r'^```json', multiLine: true), '')
            .replaceAll('```', '')
            .trim();

        final Map<String, dynamic> jsonMap = jsonDecode(cleaned);
        answer = RecipeResponse.fromJson(
          jsonMap,
          fallbackTime: timeForCooking.toInt(),
          fallbackVegan: isVegan,
        );
        favoriteId = null;
        await _saveCurrentRecipe();
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RecipeScreen()),
        );
      } else {
        throw Exception('empty response');
      }
    } catch (e) {
      log('Gemini error: $e');
      if (e.toString().contains('503') ||
          e.toString().contains('UNAVAILABLE')) {
        answerError = 'Spróbuj ponownie';
      } else {
        answerError = 'Spróbuj ponownie';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Takes a photo, lets the model recognize the food products on it and
  /// appends them to the ingredients field. Returns false if nothing was added.
  Future<bool> scanIngredients(BuildContext context) async {
    final language = promptLanguage(context);
    final photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      imageQuality: 80,
    );
    if (photo == null) return true;
    isScanning = true;
    notifyListeners();
    try {
      final bytes = await photo.readAsBytes();
      final response = await aiModel.generateContent([
        Content.multi([
          TextPart(
            'List the food products and ingredients visible in this photo '
            '(e.g. from a fridge or a table). Answer ONLY with a short '
            'comma-separated list in the language: $language. No other text. '
            'If there is no food, answer with an empty string.',
          ),
          DataPart('image/jpeg', bytes),
        ]),
      ]);
      final products = (response.text ?? '').trim().replaceAll('\n', ', ');
      if (products.isEmpty) return false;
      final current = questionController.text.trim();
      questionController.text = current.isEmpty
          ? products
          : '$current, $products';
      return true;
    } catch (e) {
      log('Scan error: $e');
      return false;
    } finally {
      isScanning = false;
      notifyListeners();
    }
  }

  void setFavoriteId(String? id) {
    favoriteId = id;
    _saveCurrentRecipe();
    notifyListeners();
  }

  /// Makes [recipe] the current one (e.g. opened from favorites).
  void openRecipe(RecipeResponse recipe, {String? id}) {
    answer = recipe;
    favoriteId = id;
    _saveCurrentRecipe();
    notifyListeners();
  }

  Future<void> _saveCurrentRecipe() async {
    hasCurrentRecipe = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentRecipe', jsonEncode(answer.toMap()));
    if (favoriteId == null) {
      await prefs.remove('currentFavoriteId');
    } else {
      await prefs.setString('currentFavoriteId', favoriteId!);
    }
  }

  void setLanguage(AppLanguage value, context) {
    selectedLanguage = value.toString();
    notifyListeners();
  }

  void setOnlyUserIngredients(bool? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    onlyUserIngredients = value ?? false;
    await prefs.setBool('onlyUserIngredients', onlyUserIngredients);
    notifyListeners();
  }

  void setCaloriesRange(RangeValues value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    caloriesRange = value;
    await prefs.setDouble('caloriesRangeStart', value.start);
    await prefs.setDouble('caloriesRangeEnd', value.end);
    notifyListeners();
  }

  void setRegularOrSportDiet(bool? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isRegularDiet = value ?? false;
    await prefs.setBool('isRegularDiet', isRegularDiet);
    notifyListeners();
  }

  void setIsKids(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isKids = value;
    await prefs.setBool('isKids', isKids);
    notifyListeners();
  }

  void setKidsAge(double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    kidsAge = value;
    await prefs.setDouble('kidsAge', kidsAge);
    notifyListeners();
  }

  void toggleMale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isMale = !isMale;
    await prefs.setBool('isMale', isMale);
    notifyListeners();
  }

  void toggleFemale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isFemale = !isFemale;
    await prefs.setBool('isFemale', isFemale);
    notifyListeners();
  }

  void setTimeForCooking(double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    timeForCooking = value;
    await prefs.setDouble('timeForCooking', timeForCooking);
    notifyListeners();
  }

  void setCookingSkillLevel(double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    cookingSkillLevel = value;
    await prefs.setDouble('cookingSkillLevel', cookingSkillLevel);
    notifyListeners();
  }

  void setAllergies(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('allergies', value);
    notifyListeners();
  }

  void setNotLikes(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('notLikes', value);
    notifyListeners();
  }

  void setMealType(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    mealType = value;
    if (value != 'dish') dishType = null;
    await prefs.setString('mealType', mealType);
    await prefs.remove('dishType');
    notifyListeners();
  }

  /// Tapping the selected dish type again clears it (any dish).
  void setDishType(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dishType = dishType == value ? null : value;
    if (dishType == null) {
      await prefs.remove('dishType');
    } else {
      await prefs.setString('dishType', dishType!);
    }
    notifyListeners();
  }

  void setDiet(String diet, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    value ? diets.add(diet) : diets.remove(diet);
    await prefs.setStringList('diets', diets.toList());
    notifyListeners();
  }

  void getValuesFromMemory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    onlyUserIngredients = prefs.getBool('onlyUserIngredients') ?? true;
    isMale = prefs.getBool('isMale') ?? false;
    isFemale = prefs.getBool('isFemale') ?? false;
    cookingSkillLevel = prefs.getDouble('cookingSkillLevel') ?? 1;
    allergiesController.text = prefs.getString('allergies') ?? '';
    notLikeController.text = prefs.getString('notLikes') ?? '';
    caloriesRange = RangeValues(
      prefs.getDouble('caloriesRangeStart') ?? 100,
      prefs.getDouble('caloriesRangeEnd') ?? 1000,
    );
    isRegularDiet = prefs.getBool('isRegularDiet') ?? true;
    isKids = prefs.getBool('isKids') ?? false;
    kidsAge = prefs.getDouble('kidsAge') ?? 3;
    timeForCooking = prefs.getDouble('timeForCooking') ?? 10;
    final savedMeal = prefs.getString('mealType');
    mealType = kMealPrompts.containsKey(savedMeal) ? savedMeal! : 'dish';
    final savedDish = prefs.getString('dishType');
    dishType = mealType == 'dish' && kDishTypePrompts.containsKey(savedDish)
        ? savedDish
        : null;
    final savedRecipe = prefs.getString('currentRecipe');
    if (savedRecipe != null) {
      try {
        answer = RecipeResponse.fromMap(jsonDecode(savedRecipe) as Map);
        favoriteId = prefs.getString('currentFavoriteId');
        hasCurrentRecipe = answer.recipeName.isNotEmpty;
      } catch (_) {
        hasCurrentRecipe = false;
      }
    }
    diets
      ..clear()
      ..addAll(
        (prefs.getStringList('diets') ?? []).where(kDietPrompts.containsKey),
      );
    if (prefs.getBool('isVegan') == true) diets.add('vegan');
    notifyListeners();
  }

  Future<void> initSpeech() async {
    bool available = await speech.initialize(
      onStatus: (status) {
        log('Status: $status');
        if (status == 'done' || status == 'notListening') {
          if (_wantListening) {
            _listen();
          } else {
            isListening = false;
            notifyListeners();
          }
        }
      },
      onError: (error) => log('Błąd: $error'),
    );
    if (!available) {
      log('Speech recognition niedostępny na tym urządzeniu');
    }
    notifyListeners();
  }

  bool _wantListening = false;
  int _sessionStart = 0;

  /// Words dictated since the pop-up was opened (the field keeps older text).
  String get voiceText {
    final t = questionController.text;
    return t.length > _sessionStart ? t.substring(_sessionStart).trim() : '';
  }

  String _localeId = '';

  void startListening(BuildContext context) {
    _localeId = context.locale.toString();
    _wantListening = true;
    _sessionStart = questionController.text.length;
    isListening = true;
    notifyListeners();
    _listen();
  }

  /// The plugin stops after a few seconds of silence, so it is restarted for as
  /// long as the user has not finished recording; text already dictated stays.
  Future<void> _listen() async {
    baseText = questionController.text;
    if (baseText.isNotEmpty && !baseText.endsWith(' ')) baseText += ' ';
    await speech.listen(
      onResult: (result) {
        questionController.text = baseText + result.recognizedWords;
        questionController.selection = TextSelection.fromPosition(
          TextPosition(offset: questionController.text.length),
        );
        notifyListeners();
      },
      listenOptions: SpeechListenOptions(
        localeId: _localeId,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 30),
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  void stopListening() async {
    _wantListening = false;
    await speech.stop();
    isListening = false;
    notifyListeners();
    log('Zapisany tekst: ${questionController.text}');
  }
}

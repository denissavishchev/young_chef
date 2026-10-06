import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
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
      developerInfo: '');
  
  /// Key of the current [answer] in the favorites box, null if not saved.
  String? favoriteId;

  String answerError = '';

  bool onlyUserIngredients = true;
  RangeValues caloriesRange = const RangeValues(100, 1000);
  bool isRegularDiet = true;
  bool isBoy = true;
  double timeForCooking = 10;
  double cookingSkillLevel = 1;
  bool isVegan = false;

  final aiModel = GenerativeModel(
    model: 'gemini-2.5-flash-lite',
    apiKey: dotenv.env['GOOGLE_AI_STUDIO_KEY'].toString(),
  );

  Future<void> getRecipe(BuildContext context)async {
    isLoading = true;
    notifyListeners();
    Locale myLocale = Localizations.localeOf(context);
    String language = myLocale.languageCode;
    final prompt = [
      Content.multi([
        TextPart(
          '''
          Jesteś doświadczonym doradcą kulinarnym, który tworzy przepisy specjalnie dla nastolatków.

            Na podstawie podanych produktów: ${questionController.text}
          
            WAŻNE — priorytet składników: Podane powyżej produkty (${questionController.text}) są PRIORYTETEM i podstawą przepisu. W razie jakiegokolwiek konfliktu między nimi a poniższymi parametrami (np. typem diety czy poziomem umiejętności), to one decydują o kierunku przepisu. Jedynym wyjątkiem są alergie — jeśli któryś z podanych produktów znajduje się na liście alergii, NIE używaj go, nawet jeśli został podany przez użytkownika.
          
            Dodatkowe parametry, które MUSISZ uwzględnić:
          
            - Źródło składników: ${onlyUserIngredients
              ? "Użyj WYŁĄCZNIE podanych produktów. Nie dodawaj żadnych innych składników, łącznie z solą, pieprzem czy oliwą, jeśli nie zostały wymienione."
              : "Bazuj przede wszystkim na podanych produktach. Możesz dodać podstawowe składniki uzupełniające typu sól, pieprz, oliwa, przyprawy, jeśli są potrzebne — ale nie dodawaj nowych głównych składników (np. dodatkowego mięsa, nabiału czy warzyw, których nie ma na liście)."}
          
            - Kaloryczność: Całe danie powinno mieścić się w zakresie od ${caloriesRange.start} do ${caloriesRange.end} kcal.
          
            - Typ diety: ${isRegularDiet
              ? "Standardowa, zbalansowana dieta nastolatka."
              : "Dieta dopasowana do potrzeb młodego sportowca / dnia treningowego — uwzględnij odpowiednią podaż białka i węglowodanów wspierających regenerację i energię."}
          
            - Płeć osoby, dla której przygotowywany jest przepis: ${isBoy ? "chłopak" : "dziewczynka"} (dostosuj orientacyjne potrzeby kaloryczne/makroskładnikowe, jeśli ma to znaczenie).
          
            - Czas przygotowania: Przepis musi być możliwy do wykonania w maksymalnie $timeForCooking minut.
          
            - Poziom umiejętności kulinarnych (skala 1–5, gdzie 1 = brak doświadczenia, tylko podstawowe czynności, 5 = zaawansowany, swobodne użycie noża, kuchenki i innych narzędzi): $cookingSkillLevel.
              Dostosuj złożoność technik kulinarnych i liczbę kroków do tego poziomu.
          
            - Dieta wegańska: ${isVegan ? "Przepis MUSI być w 100% wegański — żadnych produktów pochodzenia zwierzęcego (mięso, ryby, nabiał, jajka, miód itp.)." : "Brak ograniczeń wegańskich."}
          
            - Składniki, których NIE lubi/nie chce: ${notLikeController.text.isEmpty ? "Brak ograniczeń." : "NIE używaj w przepisie następujących składników: ${notLikeController.text}."}
          
            - Alergie: ${allergiesController.text.isEmpty ? "Brak alergii do uwzględnienia." : "Osoba jest uczulona na: ${allergiesController.text}. Pod żadnym pozorem nie używaj tych składników ani produktów je zawierających, nawet jeśli zostały podane jako dostępne produkty."}
          
            Wygeneruj jeden przepis kulinarny, który spełnia następujące wymagania:
            - Jest odpowiedni dla nastolatka (prosty, zrozumiały, bez skomplikowanych technik kulinarnych, dopasowany do podanego poziomu umiejętności)
            - Jest łatwy do przygotowania w podanym limicie czasu, przy użyciu podstawowych narzędzi kuchennych
            - Jest zdrowy (zbalansowany, bez nadmiaru cukru, soli i tłuszczu)
            - Spełnia wszystkie powyższe parametry (źródło składników, kaloryczność, typ diety, dieta wegańska, niechciane składniki, alergie)
            - Pole "instructions" MUSI być tablicą stringów: każdy element to JEDEN osobny krok przygotowania.
            
            Odpowiedz WYŁĄCZNIE w formacie czystego JSON (bez markdown, bez ```json, bez żadnego tekstu przed/po), o następującej strukturze:
          
            {
              "recipeName": "Nazwa przepisu",
              "ingredients": ["składnik 1 z ilością", "składnik 2 z ilością"],
              "instructions": ["krok 1", "krok 2"],
              "calories": "Wartość kaloryczna całego dania w kcal (tylko liczba + jednostka)",
              "protein": "orientacyjna ilość białka (tylko liczba + jednostka)",
              "carbohydrates": "orientacyjna ilość węglowodanów (tylko liczba + jednostka)",
              "fat": "orientacyjna ilość tłuszczu (tylko liczba + jednostka)",
              "developerInfo": {
                "products": "podane produkty",
                "onlyUserIngredients": true,
                "caloriesRange": "od-do",
                "dietType": "standardowa / sportowa",
                "gender": "chłopak/dziewczynka",
                "cookingTime": "czas w minutach",
                "cookingSkillLevel": "1-5",
                "isVegan": false,
                "dislikedIngredients": "lub brak",
                "allergies": "lub brak"
              }
            }
          
            Odpowiedz wyłącznie w języku: $language
            Nie dodawaj żadnego tekstu poza samym obiektem JSON.
          ''',
        ),
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
        log(answer.recipeName);
        log(answer.ingredients.toString());
        log(answer.instructions.toString());
        log(answer.developerInfo);
        if (!context.mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) =>
            const RecipeScreen()));
      } else {
        throw Exception('empty response');
      }
    } catch (e) {
      log('Gemini error: $e');
      if (e.toString().contains('503') || e.toString().contains('UNAVAILABLE')) {
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
    final language = Localizations.localeOf(context).languageCode;
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
      questionController.text =
          current.isEmpty ? products : '$current, $products';
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
    notifyListeners();
  }

  void setLanguage(AppLanguage value, context){
    selectedLanguage = value.toString();
    notifyListeners();
  }

  void setOnlyUserIngredients(bool? value) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    onlyUserIngredients = value ?? false;
    await prefs.setBool('onlyUserIngredients', onlyUserIngredients);
    notifyListeners();
  }

  void setCaloriesRange(RangeValues value) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    caloriesRange = value;
    await prefs.setDouble('caloriesRangeStart', value.start);
    await prefs.setDouble('caloriesRangeEnd', value.end);
    notifyListeners();
  }

  void setRegularOrSportDiet(bool? value) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isRegularDiet = value ?? false;
    await prefs.setBool('isRegularDiet', isRegularDiet);
    notifyListeners();
  }

  void setBoyOrGirl(bool? value) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isBoy = value ?? false;
    await prefs.setBool('isBoy', isBoy);
    notifyListeners();
  }

  void setTimeForCooking(double value) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    timeForCooking = value;
    await prefs.setDouble('timeForCooking', timeForCooking);
    notifyListeners();
  }

  void setCookingSkillLevel(double value) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    cookingSkillLevel = value;
    await prefs.setDouble('cookingSkillLevel', cookingSkillLevel);
    notifyListeners();
  }

  void setAllergies(String value) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('allergies', value);
    notifyListeners();
  }

  void setNotLikes(String value) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('notLikes', value);
    notifyListeners();
  }

  void setIsVegan(bool? value) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isVegan = value ?? false;
    prefs.setBool('isVegan', isVegan);
    notifyListeners();
  }

  void getValuesFromMemory() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    onlyUserIngredients = prefs.getBool('onlyUserIngredients') ?? true;
    isBoy = prefs.getBool('isBoy') ?? true;
    cookingSkillLevel = prefs.getDouble('cookingSkillLevel') ?? 1;
    allergiesController.text = prefs.getString('allergies') ?? '';
    notLikeController.text = prefs.getString('notLikes') ?? '';
    caloriesRange = RangeValues(prefs.getDouble('caloriesRangeStart') ?? 100, prefs.getDouble('caloriesRangeEnd') ?? 1000);
    isRegularDiet = prefs.getBool('isRegularDiet') ?? true;
    timeForCooking = prefs.getDouble('timeForCooking') ?? 10;
    isVegan = prefs.getBool('isVegan') ?? false;
    notifyListeners();
  }

  Future<void> initSpeech() async {
    bool available = await speech.initialize(
      onStatus: (status) => log('Status: $status'),
      onError: (error) => log('Błąd: $error'),
    );
    if (!available) {
      log('Speech recognition niedostępny na tym urządzeniu');
    }
    notifyListeners();
  }

  void startListening(BuildContext context) async {
    baseText = questionController.text;

    if (baseText.isNotEmpty && !baseText.endsWith(' ')) {
      baseText += ' ';
    }
    isListening = true;
    notifyListeners();
    await speech.listen(
      onResult: (result) {
        questionController.text = baseText + result.recognizedWords;
        questionController.selection = TextSelection.fromPosition(
          TextPosition(offset: questionController.text.length),
        );
        notifyListeners();
      },
      listenOptions: SpeechListenOptions(
        localeId: context.locale.toString(),
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  void stopListening() async {
    await speech.stop();
    isListening = false;
    notifyListeners();
    log('Zapisany tekst: ${questionController.text}');
  }

}


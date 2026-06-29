import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../screens/recipe_screen.dart';
import '../widgets/language.dart';

class MainProvider with ChangeNotifier {

  TextEditingController questionController = TextEditingController();
  TextEditingController allergiesController = TextEditingController();
  TextEditingController notLikeController = TextEditingController();

  String selectedLanguage = 'English - UK';

  bool isLoading = false;
  String answer = '';

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
          
            Odpowiedź sformatuj w następujący sposób:
            1. Nazwa przepisu
            2. Lista składników z dokładnymi ilościami (dla porcji dla jednej osoby)
            3. Instrukcja przygotowania krok po kroku
            4. Wartość kaloryczna całego dania (w kcal) oraz orientacyjny rozkład makroskładników (białko, węglowodany, tłuszcze)
            5. Podsumowanie zapytania — wypisz w punktach WSZYSTKIE poniższe parametry, które zostały podane na wejściu, dokładnie z ich wartościami:
               - Podane produkty
               - Czy użyto wyłącznie podanych produktów (tak/nie)
               - Zakres kalorii (od-do)
               - Typ diety (standardowa / sportowa)
               - Płeć (chłopak/dziewczynka)
               - Czas przygotowania (w minutach)
               - Poziom umiejętności kulinarnych (1-5)
               - Dieta wegańska (tak/nie)
               - Niechciane składniki (lub "brak")
               - Alergie (lub "brak")
          
            Odpowiedz wyłącznie w języku: $language
          
            Nie dodawaj żadnych innych informacji poza punktami 1-5. Nie pisz wstępu, podsumowania ogólnego ani komentarzy poza wskazaną strukturą.
          ''',
        ),
      ]),
    ];
    try {
      final response = await aiModel.generateContent(prompt);

      if (response.text != null) {
        answer = response.text ?? '';
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
        answer = 'Spróbuj ponownie';
      } else {
        answer = 'Spróbuj ponownie';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setLanguage(AppLanguage value, context){
    selectedLanguage = value.toString();
    notifyListeners();
  }

  void setOnlyUserIngredients(bool? value) {
    onlyUserIngredients = value ?? false;
    notifyListeners();
  }

  void setCaloriesRange(RangeValues value) {
    caloriesRange = value;
    notifyListeners();
  }

  void setRegularOrSportDiet(bool? value) {
    isRegularDiet = value ?? false;
    notifyListeners();
  }

  void setBoyOrGirl(bool? value) {
    isBoy = value ?? false;
    notifyListeners();
  }

  void setTimeForCooking(double value) {
    timeForCooking = value;
    notifyListeners();
  }

  void setCookingSkillLevel(double value) {
    cookingSkillLevel = value;
    notifyListeners();
  }

  void setIsVegan(bool? value) {
    isVegan = value ?? false;
    notifyListeners();
  }

}


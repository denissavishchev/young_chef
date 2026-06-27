import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../widgets/language.dart';

class MainProvider with ChangeNotifier {

  TextEditingController questionController = TextEditingController();

  String selectedLanguage = 'English - UK';

  bool isLoading = false;
  String answer = 'none';

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
            
            Wygeneruj jeden przepis kulinarny, który spełnia następujące wymagania:
            - Jest odpowiedni dla nastolatka (prosty, zrozumiały, bez skomplikowanych technik kulinarnych)
            - Jest łatwy i szybki do przygotowania (maksymalnie 30 minut, podstawowe narzędzia kuchenne)
            - Jest zdrowy (zbalansowany, bez nadmiaru cukru, soli i tłuszczu)
            - Wykorzystuje przede wszystkim podane produkty (możesz dodać podstawowe składniki typu sól, pieprz, oliwa, jeśli są potrzebne)
            
            Odpowiedź sformatuj w następujący sposób:
            1. Nazwa przepisu
            2. Lista składników z dokładnymi ilościami (dla porcji dla jednej osoby)
            3. Instrukcja przygotowania krok po kroku
            4. Wartość kaloryczna całego dania (w kcal) oraz orientacyjny rozkład makroskładników (białko, węglowodany, tłuszcze)
            
            Odpowiedz wyłącznie w języku: $language
            
            Nie dodawaj żadnych dodatkowych komentarzy poza przepisem.
          ''',
        ),
      ]),
    ];
    try {
      final response = await aiModel.generateContent(prompt);

      if (response.text != null) {
        answer = response.text ?? '';
      } else {
        throw Exception('empty response');
      }
    } catch (e) {
      log('Gemini error: $e');
      answer = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setLanguage(AppLanguage value, context){
    selectedLanguage = value.toString();
    notifyListeners();
  }

}

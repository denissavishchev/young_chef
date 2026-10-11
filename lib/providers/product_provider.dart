import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/product_model.dart';

/// State of the product screen: one product (typed, spoken or recognized from
/// a photo) and the facts the model returns about it.
class ProductProvider with ChangeNotifier {
  final TextEditingController controller = TextEditingController();
  final SpeechToText speech = SpeechToText();

  bool isListening = false;
  bool isScanning = false;
  bool isLoading = false;
  bool hasError = false;
  String _baseText = '';

  ProductInfo? info;

  final _model = GenerativeModel(
    model: 'gemini-2.5-flash-lite',
    apiKey: dotenv.env['GOOGLE_AI_STUDIO_KEY'].toString(),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Only the first product of the field counts.
  String get firstProduct => controller.text
      .split(RegExp(r'[,;\n]'))
      .map((e) => e.trim())
      .firstWhere((e) => e.isNotEmpty, orElse: () => '');

  Future<void> initSpeech() async {
    final available = await speech.initialize(
      onStatus: (status) => log('Status: $status'),
      onError: (error) => log('Błąd: $error'),
    );
    if (!available) log('Speech recognition niedostępny na tym urządzeniu');
    notifyListeners();
  }

  void startListening(BuildContext context) async {
    _baseText = controller.text;
    if (_baseText.isNotEmpty && !_baseText.endsWith(' ')) _baseText += ' ';
    isListening = true;
    notifyListeners();
    await speech.listen(
      onResult: (result) {
        controller.text = _baseText + result.recognizedWords;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
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
  }

  /// Takes a photo and puts the main product on it into the field. Returns
  /// false if nothing was recognized.
  Future<bool> scan(BuildContext context) async {
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
      final response = await _model.generateContent([
        Content.multi([
          TextPart(
            'Name the single main food product visible in this photo. '
            'Answer ONLY with its name in the language: $language. '
            'No other text. If there is no food, answer with an empty string.',
          ),
          DataPart('image/jpeg', bytes),
        ]),
      ]);
      final product = (response.text ?? '')
          .split(RegExp(r'[,;\n]'))
          .first
          .trim();
      if (product.isEmpty) return false;
      controller.text = product;
      return true;
    } catch (e) {
      log('Scan error: $e');
      return false;
    } finally {
      isScanning = false;
      notifyListeners();
    }
  }

  Future<void> analyze(BuildContext context) async {
    final product = firstProduct;
    if (product.isEmpty || isLoading) return;
    final language = Localizations.localeOf(context).languageCode;
    isLoading = true;
    hasError = false;
    notifyListeners();
    try {
      final response = await _model.generateContent([
        Content.text('''
You are a food expert talking to a teenager. Describe this food product: "${controller.text}".
If the text lists several products, or has no separators, describe ONLY the first product mentioned.

Answer ONLY with pure JSON (no markdown, no ```json, no text before/after) in this structure:
{
  "name": "product name",
  "about": "3-5 sentences: what it is, its short history and where it comes from",
  "pros": ["advantage 1", "advantage 2", "advantage 3"],
  "cons": ["disadvantage 1", "disadvantage 2"],
  "usefulFor": "1-3 sentences: why it is useful and what it is good for",
  "per100g": {
    "calories": "number + kcal",
    "protein": "number + g",
    "carbohydrates": "number + g",
    "fat": "number + g",
    "fiber": "number + g"
  }
}
The per100g values are approximate, per 100 g of the raw/typical product.
Answer in the language: $language.
'''),
      ]);
      final cleaned = (response.text ?? '')
          .replaceAll(RegExp(r'^```json', multiLine: true), '')
          .replaceAll('```', '')
          .trim();
      info = ProductInfo.fromJson(jsonDecode(cleaned));
    } catch (e) {
      log('Product error: $e');
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

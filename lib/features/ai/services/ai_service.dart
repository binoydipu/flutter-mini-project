import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

const String _systemPrompt =
    '''You are Life AI, a healthcare assistant in a medical app. Provide general health information, symptom explanations, and suggest relevant doctor specialties based on symptoms. Do not diagnose, prescribe, or replace medical advice. Always recommend consulting a qualified doctor for medical decisions. Keep responses concise, simple, and safe. For emergencies, advise immediate medical attention.''';

class AiService {
  AiService._();

  static final Gemini _gemini = Gemini.instance;

  static Future<String> getResponse({required String question}) async {
    try {
      final res = await _gemini.prompt(
        parts: [Part.text("$_systemPrompt\n\nUser: $question")],
      );

      return res?.output ?? 'Sorry, I did not understand that.';
    } catch (e) {
      debugPrint('Error getting AI response: $e');
      return 'Sorry, something went wrong. Please try again.';
    }
  }
}

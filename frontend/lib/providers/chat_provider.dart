import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class ChatMessage {
  final String id;
  final String userMessage;
  final String aiResponse;
  final DateTime timestamp;
  final bool isEmergency;

  ChatMessage({
    required this.id,
    required this.userMessage,
    required this.aiResponse,
    required this.timestamp,
    this.isEmergency = false,
  });
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final resp = await ApiService.get('/chat/history?limit=50');
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null && data['messages'] != null) {
        _messages.clear();
        for (final m in (data['messages'] as List).reversed) {
          _messages.add(ChatMessage(
            id: m['chat_id'] ?? '',
            userMessage: m['user_message'] ?? '',
            aiResponse: m['ai_response'] ?? '',
            timestamp:
                DateTime.tryParse(m['timestamp'] ?? '') ?? DateTime.now(),
            isEmergency:
                (m['safety_flags']?['emergency'] ?? false) == true,
          ));
        }
      }
    } catch (_) {
      // Offline or backend down — just show empty history
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final tempMsg = ChatMessage(
      id: 'temp',
      userMessage: text,
      aiResponse: '',
      timestamp: DateTime.now(),
    );
    _messages.add(tempMsg);
    _isTyping = true;
    notifyListeners();

    String reply;
    bool isEmergency = false;

    try {
      // Try our backend first
      final resp = await ApiService.post('/chat/message', {'message': text});
      final data = resp['data'] as Map<String, dynamic>?;
      reply = data?['ai_response'] ??
          'I could not process that. Please try again.';
      isEmergency =
          (data?['safety_flags']?['emergency'] ?? false) == true;
    } catch (_) {
      // Backend unavailable — use Groq directly
      reply = await _callGroqDirectly(text) ??
          'I am unable to respond right now. '
              'If this is a medical emergency, please call 108 immediately.';
    }

    _messages.removeLast();
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userMessage: text,
      aiResponse: reply,
      timestamp: DateTime.now(),
      isEmergency: isEmergency,
    ));
    _isTyping = false;
    notifyListeners();
  }

  /// Calls the Groq Cloud API directly when our backend is unreachable.
  /// Uses llama3-8b-8192 which is fast and free-tier friendly.
  static Future<String?> _callGroqDirectly(String userMessage) async {
    try {
      const apiKey =
          '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';
      const url = 'https://api.groq.com/openai/v1/chat/completions';

      final resp = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'llama3-8b-8192',
              'messages': [
                {
                  'role': 'system',
                  'content': 'You are Aarogya Sathi, a caring AI health '
                      'companion for India. Provide helpful, accurate guidance '
                      'based on ICMR and WHO guidelines. Always recommend '
                      'consulting a qualified doctor for diagnosis or treatment. '
                      'For emergencies, always advise the user to call 108. '
                      'Keep responses concise, practical, and empathetic. '
                      'Use simple language that non-medical users can understand.',
                },
                {'role': 'user', 'content': userMessage},
              ],
              'temperature': 0.7,
              'max_tokens': 500,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return data['choices']?[0]?['message']?['content'] as String?;
      }
    } catch (_) {}
    return null;
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}

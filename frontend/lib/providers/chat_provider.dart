import 'package:flutter/material.dart';
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

  List<ChatMessage> get messages => _messages;
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
            timestamp: DateTime.tryParse(m['timestamp'] ?? '') ?? DateTime.now(),
            isEmergency: (m['safety_flags']?['emergency'] ?? false) == true,
          ));
        }
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    // Add user message immediately
    final tempMsg = ChatMessage(
      id: 'temp',
      userMessage: text,
      aiResponse: '',
      timestamp: DateTime.now(),
    );
    _messages.add(tempMsg);
    _isTyping = true;
    notifyListeners();

    try {
      final resp = await ApiService.post('/chat/message', {'message': text});
      final data = resp['data'] as Map<String, dynamic>?;
      // Replace temp message with real one
      _messages.removeLast();
      _messages.add(ChatMessage(
        id: data?['chat_id'] ?? '',
        userMessage: text,
        aiResponse: data?['ai_response'] ?? 'Sorry, I could not process that.',
        timestamp: DateTime.now(),
        isEmergency: (data?['safety_flags']?['emergency'] ?? false) == true,
      ));
    } catch (e) {
      _messages.removeLast();
      _messages.add(ChatMessage(
        id: 'error',
        userMessage: text,
        aiResponse: 'Connection error. Please try again.',
        timestamp: DateTime.now(),
      ));
    }
    _isTyping = false;
    notifyListeners();
  }
}

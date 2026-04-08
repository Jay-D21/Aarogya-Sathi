import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ChatProvider>().loadHistory());
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    context.read<ChatProvider>().sendMessage(text);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.health_and_safety, color: AppTheme.primaryTeal, size: 24),
            SizedBox(width: 8),
            Text('Aarogya Sathi'),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: chat.messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          const Text('Hi! I\'m Aarogya Sathi 🏥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          const Text(
                            'Ask me anything about health, nutrition, fitness, or wellness!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chat.messages.length + (chat.isTyping ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == chat.messages.length) {
                        // Typing indicator
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 8), Text('Thinking...', style: TextStyle(color: AppTheme.textSecondary))],
                            ),
                          ),
                        );
                      }
                      final msg = chat.messages[i];
                      return Column(
                        children: [
                          // User bubble
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8, left: 48),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                              ),
                              child: Text(msg.userMessage, style: const TextStyle(color: Colors.white)),
                            ),
                          ),
                          // AI bubble
                          if (msg.aiResponse.isNotEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16, right: 48),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: msg.isEmergency ? AppTheme.accentRed.withValues(alpha: 0.15) : AppTheme.cardDark,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  border: msg.isEmergency ? Border.all(color: AppTheme.accentRed, width: 1) : null,
                                ),
                                child: Text(msg.aiResponse, style: TextStyle(color: msg.isEmergency ? AppTheme.accentRed : AppTheme.textPrimary)),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(color: AppTheme.surfaceDark),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _send(),
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Ask about your health...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: AppTheme.cardDark,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.primaryGradient),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

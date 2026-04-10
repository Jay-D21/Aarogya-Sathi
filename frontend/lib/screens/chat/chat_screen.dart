import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late AnimationController _typingCtrl;
  bool _inputEmpty = true;

  static const _suggestions = [
    ('🤒', 'I have a fever and headache'),
    ('💧', 'How much water should I drink daily?'),
    ('🍽️', 'Best diet for diabetes management'),
    ('😮‍💨', 'AQI is high, what precautions?'),
    ('💊', 'How to reduce blood pressure naturally'),
  ];

  @override
  void initState() {
    super.initState();
    _typingCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadHistory();
    });

    _inputCtrl.addListener(() {
      final empty = _inputCtrl.text.trim().isEmpty;
      if (empty != _inputEmpty) setState(() => _inputEmpty = empty);
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _typingCtrl.dispose();
    super.dispose();
  }

  Future<void> _send([String? text]) async {
    final msg = (text ?? _inputCtrl.text).trim();
    if (msg.isEmpty) return;
    _inputCtrl.clear();
    setState(() => _inputEmpty = true);
    await context.read<ChatProvider>().sendMessage(msg);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: AppTheme.durationMedium,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = AppTheme.textPrimaryOf(context);
    final textSec = AppTheme.textSecondaryOf(context);
    final card = AppTheme.cardBg(context);
    final card2 = AppTheme.cardBg2(context);
    final border = AppTheme.borderColor(context);
    final bg = AppTheme.bgOf(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(children: [
          // AI avatar
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.chatGradient,
            ),
            child: const Icon(Icons.psychology_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Health Assistant',
                style: GoogleFonts.outfit(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: textPri)),
            Row(children: [
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentGreen,
                ),
              ),
              const SizedBox(width: 4),
              Text('ICMR-Guided · Online',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppTheme.accentGreen,
                      fontWeight: FontWeight.w500)),
            ]),
          ]),
          const Spacer(),
          if (chat.messages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  size: 20, color: textSec),
              onPressed: () => _confirmClear(context, chat),
              tooltip: 'Clear chat',
            ),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: Column(children: [
        Expanded(
          child: chat.messages.isEmpty && !chat.isLoading
              ? _EmptyState(
                  suggestions: _suggestions,
                  isDark: isDark,
                  textPri: textPri,
                  textSec: textSec,
                  card: card,
                  border: border,
                  onSuggestion: _send,
                )
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: chat.messages.length +
                      (chat.isTyping ? 1 : 0) +
                      (chat.isLoading ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (chat.isLoading && chat.messages.isEmpty && i == 0) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryTeal),
                        ),
                      );
                    }
                    if (chat.isTyping && i == chat.messages.length) {
                      return _TypingIndicator(
                          ctrl: _typingCtrl, isDark: isDark,
                          card: card, border: border);
                    }
                    return _MessageBubble(
                      message: chat.messages[i],
                      isDark: isDark,
                      textPri: textPri,
                      textSec: textSec,
                      card: card,
                      card2: card2,
                    );
                  },
                ),
        ),

        // ── Input ──
        _InputBar(
          ctrl: _inputCtrl,
          inputEmpty: _inputEmpty,
          isDark: isDark,
          textPri: textPri,
          textSec: textSec,
          card: card,
          border: border,
          onSend: _send,
          onVoice: () => _showVoiceSheet(context),
        ),
      ]),
    );
  }

  void _confirmClear(BuildContext ctx, ChatProvider chat) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Clear Chat?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: const Text('All messages will be deleted locally.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              chat.clearMessages();
            },
            child: const Text('Clear',
                style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showVoiceSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (c) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 60, height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.chatGradient,
              ),
              child: const Icon(Icons.mic_rounded,
                  color: Colors.white, size: 28)),
          const SizedBox(height: 16),
          Text('Voice Input',
              style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryOf(c))),
          const SizedBox(height: 8),
          Text('Voice input coming soon. Use text for now.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textSecondaryOf(c))),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Got it'),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final List<(String, String)> suggestions;
  final bool isDark;
  final Color textPri, textSec, card, border;
  final Function(String) onSuggestion;
  const _EmptyState({
    required this.suggestions,
    required this.isDark,
    required this.textPri,
    required this.textSec,
    required this.card,
    required this.border,
    required this.onSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          // Hero
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.chatGradient,
            ),
            child: const Icon(Icons.psychology_rounded,
                color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text('How can I help you?',
              style: GoogleFonts.outfit(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: textPri)),
          const SizedBox(height: 6),
          Text(
            'Ask me anything about your health in Hindi,\nMarathi, or English.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: textSec, height: 1.5),
          ),

          const SizedBox(height: 28),

          // Feature chips row
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ('🌿', 'ICMR Guidelines'),
              ('🌬️', 'AQI-Aware'),
              ('🔒', 'Private'),
              ('🌐', 'Multilingual'),
            ].map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(item.$1, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(item.$2,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w600)),
              ]),
            )).toList(),
          ),

          const SizedBox(height: 28),

          // Suggestion cards
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Try asking:',
                  style: GoogleFonts.outfit(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: textPri)),
            ),
          ),
          ...suggestions.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SuggestionChip(
              emoji: s.$1,
              text: s.$2,
              isDark: isDark,
              card: card,
              border: border,
              textPri: textPri,
              onTap: () => onSuggestion(s.$2),
            ),
          )),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String emoji;
  final String text;
  final bool isDark;
  final Color card, border, textPri;
  final VoidCallback onTap;
  const _SuggestionChip({
    required this.emoji,
    required this.text,
    required this.isDark,
    required this.card,
    required this.border,
    required this.textPri,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: border),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(
                    fontSize: 13, color: textPri,
                    fontWeight: FontWeight.w500)),
          ),
          Icon(Icons.send_rounded, size: 14,
              color: AppTheme.primaryTeal),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MESSAGE BUBBLE
// ═══════════════════════════════════════════════════════════════════════════

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;
  final Color textPri, textSec, card, card2;
  const _MessageBubble({
    required this.message,
    required this.isDark,
    required this.textPri,
    required this.textSec,
    required this.card,
    required this.card2,
  });

  @override
  Widget build(BuildContext context) {
    final time = _fmtTime(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // User bubble
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: 48),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(message.userMessage,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.white, height: 1.4)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // AI bubble
        if (message.aiResponse.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // AI avatar
              Container(
                width: 28, height: 28, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: message.isEmergency
                      ? AppTheme.emergencyGradient
                      : AppTheme.chatGradient,
                ),
                child: Icon(
                  message.isEmergency
                      ? Icons.warning_rounded
                      : Icons.psychology_rounded,
                  color: Colors.white, size: 14,
                ),
              ),
              Flexible(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: message.isEmergency
                          ? AppTheme.accentRed.withValues(alpha: 0.12)
                          : card,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      border: Border.all(
                        color: message.isEmergency
                            ? AppTheme.accentRed.withValues(alpha: 0.4)
                            : AppTheme.borderColor(context),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.isEmergency)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(children: [
                              const Icon(Icons.warning_rounded,
                                  size: 14, color: AppTheme.accentRed),
                              const SizedBox(width: 4),
                              Text('URGENT — Call 108',
                                  style: GoogleFonts.outfit(
                                      fontSize: 11, fontWeight: FontWeight.w700,
                                      color: AppTheme.accentRed)),
                            ]),
                          ),
                        Text(message.aiResponse,
                            style: GoogleFonts.inter(
                                fontSize: 14, color: textPri, height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    const SizedBox(width: 4),
                    Text(time,
                        style: GoogleFonts.inter(
                            fontSize: 10, color: AppTheme.textMutedOf(context))),
                    const SizedBox(width: 8),
                    Text('· ICMR Guided',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.w500)),
                  ]),
                ]),
              ),
            ],
          ),
      ]),
    );
  }

  String _fmtTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TYPING INDICATOR
// ═══════════════════════════════════════════════════════════════════════════

class _TypingIndicator extends StatelessWidget {
  final AnimationController ctrl;
  final bool isDark;
  final Color card, border;
  const _TypingIndicator({
    required this.ctrl,
    required this.isDark,
    required this.card,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 28, height: 28, margin: const EdgeInsets.only(right: 8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.chatGradient,
          ),
          child: const Icon(Icons.psychology_rounded,
              color: Colors.white, size: 14),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: card,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            border: Border.all(color: border),
          ),
          child: AnimatedBuilder(
            animation: ctrl,
            builder: (context, child) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final t = ((ctrl.value - i * 0.15) % 1.0).clamp(0.0, 1.0);
                final bounce = t < 0.5 ? t * 2 : (1 - t) * 2;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.translate(
                    offset: Offset(0, -5 * bounce),
                    child: Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryTeal
                            .withValues(alpha: 0.5 + 0.5 * bounce),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INPUT BAR
// ═══════════════════════════════════════════════════════════════════════════

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool inputEmpty;
  final bool isDark;
  final Color textPri, textSec, card, border;
  final Function([String?]) onSend;
  final VoidCallback onVoice;
  const _InputBar({
    required this.ctrl,
    required this.inputEmpty,
    required this.isDark,
    required this.textPri,
    required this.textSec,
    required this.card,
    required this.border,
    required this.onSend,
    required this.onVoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        border: Border(top: BorderSide(color: border, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Voice
          GestureDetector(
            onTap: onVoice,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceL2 : AppTheme.surfaceL2Light,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border),
              ),
              child: Icon(Icons.mic_outlined, size: 20, color: textSec),
            ),
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceL2 : AppTheme.surfaceL2Light,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border),
              ),
              child: TextField(
                controller: ctrl,
                maxLines: 5,
                minLines: 1,
                style: GoogleFonts.inter(fontSize: 14, color: textPri),
                decoration: InputDecoration(
                  hintText: 'Ask about your health...',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 14, color: AppTheme.textMutedOf(context)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send
          GestureDetector(
            onTap: inputEmpty ? null : () => onSend(),
            child: AnimatedContainer(
              duration: AppTheme.durationFast,
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: inputEmpty ? null : AppTheme.primaryGradient,
                color: inputEmpty
                    ? (isDark ? AppTheme.surfaceL2 : AppTheme.surfaceL2Light)
                    : null,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border),
              ),
              child: Icon(
                Icons.send_rounded,
                size: 18,
                color: inputEmpty
                    ? AppTheme.textMutedOf(context)
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

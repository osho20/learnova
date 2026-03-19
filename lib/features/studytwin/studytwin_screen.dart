import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StudyTwinScreen extends StatefulWidget {
  const StudyTwinScreen({super.key});

  @override
  State<StudyTwinScreen> createState() => _StudyTwinScreenState();
}

class _StudyTwinScreenState extends State<StudyTwinScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<String> _quickPrompts = [
    '📚 Explain simply',
    '🧪 Give examples',
    '❓ Quiz me',
    '📝 Study tips',
    '🎯 Help me focus',
    '💡 Summarize',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'assistant',
      'content':
          'Hi! 👋 I\'m your AI Study Twin! I\'m here to help you study smarter. Ask me anything — I can explain topics, quiz you, simplify complex concepts, or just chat about your studies. What would you like to work on today? 🎓',
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isTyping = true;
    });
    _scrollToBottom();

    final box = Hive.box('settings');
    final apiKey = box.get('geminiApiKey', defaultValue: '');

    if (apiKey.isEmpty) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'assistant',
          'content':
              '⚠️ Please add your Gemini API key in Settings to use AI Study Twin! Go to Settings → AI Configuration → Add your free key from aistudio.google.com',
        });
      });
      _scrollToBottom();
      return;
    }

    try {
      final dio = Dio();
      final contents = _messages
          .where((m) => m['role'] != 'typing')
          .map((m) => {
                'role': m['role'] == 'user' ? 'user' : 'model',
                'parts': [
                  {'text': m['content']}
                ],
              })
          .toList();

      final response = await dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {
          'contents': contents,
          'systemInstruction': {
            'parts': [
              {
                'text':
                    'You are an AI Study Twin — a friendly, encouraging personal tutor for students. Help with assignments, explain concepts simply, quiz students, give study tips, and motivate them. Keep responses concise and student-friendly. Use emojis occasionally. Always be positive and supportive.'
              }
            ]
          },
        },
      );

      final reply =
          response.data['candidates'][0]['content']['parts'][0]['text'];
      setState(() {
        _isTyping = false;
        _messages.add({'role': 'assistant', 'content': reply});
      });
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'assistant',
          'content':
              '❌ Connection error. Please check your Gemini API key in Settings!',
        });
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6FF),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.psychology_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Study Twin',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('Always here to help',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  final message = _messages[index];
                  final isUser = message['role'] == 'user';
                  return _buildMessage(message['content'], isUser, index);
                },
              ),
            ),
            // Quick prompts
            Container(
              height: 44,
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: _quickPrompts.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => _sendMessage(_quickPrompts[index]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF1A237E).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF1A237E).withOpacity(0.2)),
                    ),
                    child: Center(
                      child: Text(_quickPrompts[index],
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A237E))),
                    ),
                  ),
                ),
              ),
            ),
            // Input bar
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.poppins(fontSize: 14),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: 'Ask your Study Twin anything...',
                        hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400], fontSize: 13),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF0D0D1A)
                            : const Color(0xFFF4F6FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_controller.text),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(String content, bool isUser, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                      )
                    : null,
                color: isUser
                    ? null
                    : isDark
                        ? const Color(0xFF1A1A2E)
                        : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                content,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.5,
                  color: isUser ? Colors.white : null,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.psychology_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(delay: Duration(milliseconds: index * 200))
        .then()
        .fadeOut(delay: Duration(milliseconds: index * 200));
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/db_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
class AssignmentsScreen extends StatefulWidget {
  final String? subjectId;
  final String? subjectName;
  const AssignmentsScreen({super.key, this.subjectId, this.subjectName});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final _questionController = TextEditingController();
  int _selectedMarks = 5;
  bool _isGenerating = false;
  String _generatedContent = '';
  List<Map<String, dynamic>> _history = [];
  bool _showHistory = false;

  final String _apiKey = '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'; // Replace with your key

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final db = await DBService.instance.database;
      final maps = await db.query(
        'assignments',
        where: widget.subjectId != null ? 'subjectId = ?' : null,
        whereArgs: widget.subjectId != null ? [widget.subjectId] : null,
        orderBy: 'createdAt DESC',
      );
      setState(() => _history = maps);
    } catch (e) {
      // ignore on web
    }
  }

 Future<void> _generateAssignment() async {
  if (_questionController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please enter a question or topic',
            style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final box = Hive.box('settings');
  final apiKey = box.get('geminiApiKey', defaultValue: '');

  if (apiKey.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please add your Gemini API key in Settings!',
            style: GoogleFonts.poppins()),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  setState(() {
    _isGenerating = true;
    _generatedContent = '';
  });

  try {
    final dio = Dio();
    final prompt = '''Write a complete assignment answer for the following question. 
The answer should be worth ${_selectedMarks} marks.
${_selectedMarks == 5 ? 'Write approximately 150-200 words with 2-3 key points.' : _selectedMarks == 10 ? 'Write approximately 300-400 words with 4-5 key points and examples.' : 'Write approximately 500-600 words with comprehensive coverage, examples, and detailed explanation.'}

Format the answer with:
- Title
- Introduction
- Main Body with key points
- Conclusion

Question: ${_questionController.text.trim()}

Write in clear academic style suitable for a student answer.''';

    final response = await dio.post(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey',
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
      data: {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
      },
    );

    final content = response
        .data['candidates'][0]['content']['parts'][0]['text'];
    setState(() {
      _generatedContent = content;
      _isGenerating = false;
    });
    await _saveAssignment(content);
  } catch (e) {
    setState(() {
      _generatedContent =
          'Error generating assignment. Please check your Gemini API key in Settings!';
      _isGenerating = false;
    });
  }
}

  Future<void> _saveAssignment(String content) async {
    try {
      final db = await DBService.instance.database;
      await db.insert('assignments', {
        'id': const Uuid().v4(),
        'subjectId': widget.subjectId ?? 'general',
        'question': _questionController.text.trim(),
        'marks': _selectedMarks,
        'content': content,
        'createdAt': DateTime.now().toIso8601String(),
      });
      _loadHistory();
    } catch (e) {
      // ignore on web
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6FF),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Assignment Generator',
                            style: GoogleFonts.poppins(
                                fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('AI-powered answers in seconds',
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Input Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enter Your Question',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A237E))),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _questionController,
                          maxLines: 4,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'e.g. Explain the process of photosynthesis',
                            hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6FF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Marks Selector
                        Text('Select Marks',
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A237E))),
                        const SizedBox(height: 10),
                        Row(
                          children: [5, 10, 15].map((marks) {
                            final isSelected = _selectedMarks == marks;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedMarks = marks),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1A237E)
                                      : const Color(0xFF1A237E).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF1A237E).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  '$marks Marks',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF1A237E),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Generate Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isGenerating ? null : _generateAssignment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A237E),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isGenerating
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2),
                                      ),
                                      const SizedBox(width: 12),
                                      Text('Generating...',
                                          style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white)),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.auto_awesome_rounded,
                                          color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text('Generate Assignment',
                                          style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white)),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 20),

                  // Generated Content
                  if (_generatedContent.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF1A237E).withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A237E).withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded,
                                  color: Color(0xFF1A237E), size: 20),
                              const SizedBox(width: 8),
                              Text('Generated Assignment',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A237E))),
                              const Spacer(),
                              // Copy button
                              IconButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Copied to clipboard!',
                                          style: GoogleFonts.poppins()),
                                      backgroundColor: const Color(0xFF1A237E),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy_rounded,
                                    color: Color(0xFF1A237E)),
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            _generatedContent,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                height: 1.6,
                                color: isDark ? Colors.white70 : Colors.black87),
                          ),
                          const SizedBox(height: 16),
                          // Marks badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A237E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_selectedMarks Marks Assignment',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A237E)),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 20),

                  // History Section
                  if (_history.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () => setState(() => _showHistory = !_showHistory),
                      child: Row(
                        children: [
                          Text('Assignment History',
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF1A237E))),
                          const Spacer(),
                          Icon(
                            _showHistory
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: const Color(0xFF1A237E),
                          ),
                        ],
                      ),
                    ),
                    if (_showHistory)
                      ..._history.map((assignment) => Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFF1A237E).withOpacity(0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        assignment['question'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A237E).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${assignment['marks']}M',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1A237E)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  assignment['content'].toString().substring(
                                      0,
                                      assignment['content'].toString().length > 100
                                          ? 100
                                          : assignment['content'].toString().length),
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          )),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
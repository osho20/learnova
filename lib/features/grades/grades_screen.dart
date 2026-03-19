import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/storage_service.dart';
class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  List<Map<String, dynamic>> _subjects = [];
void _addSubject(String name, double currentScore, double totalScore) {
  final subject = {
    'id': const Uuid().v4(),
    'name': name,
    'currentScore': currentScore,
    'totalScore': totalScore,
    'targetScore': 90.0,
  };
  StorageService.instance.saveGrade(subject);
  setState(() => _subjects.add(subject));
}
  @override
void initState() {
  super.initState();
  _subjects = StorageService.instance.getGrades();
}

  double _getPercentage(Map<String, dynamic> subject) {
    if (subject['totalScore'] == 0) return 0;
    return (subject['currentScore'] / subject['totalScore']) * 100;
  }

  String _getGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF00695C);
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getPrediction(double percentage) {
    if (percentage >= 90) return '🌟 Excellent! Keep it up!';
    if (percentage >= 80) return '😊 Great performance!';
    if (percentage >= 70) return '👍 Good, push a bit more!';
    if (percentage >= 60) return '⚠️ Need improvement';
    return '🚨 Critical — needs attention!';
  }

  void _showAddSubjectSheet() {
    final nameController = TextEditingController();
    final currentController = TextEditingController();
    final totalController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24, left: 24, right: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Add Subject',
                style: GoogleFonts.poppins(fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A237E))),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Subject name',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.book_rounded,
                    color: Color(0xFF1A237E)),
                filled: true,
                fillColor: const Color(0xFFF4F6FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: currentController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Current score',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFFF4F6FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: totalController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Total marks',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFFF4F6FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  final current =
                      double.tryParse(currentController.text) ?? 0;
                  final total =
                      double.tryParse(totalController.text) ?? 100;
                  _addSubject(nameController.text.trim(), current, total);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Add Subject',
                    style: GoogleFonts.poppins(fontSize: 16,
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double get _overallPercentage {
    if (_subjects.isEmpty) return 0;
    final total = _subjects.fold<double>(
        0, (sum, s) => sum + _getPercentage(s));
    return total / _subjects.length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overall = _overallPercentage;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor:
          isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFF6A1B9A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Predict My Grade',
                            style: GoogleFonts.poppins(fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text('Track and predict your performance',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_subjects.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6A1B9A).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('Overall Performance',
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            overall.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                                fontSize: 56,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text('%',
                                style: GoogleFonts.poppins(
                                    fontSize: 24, color: Colors.white70)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Grade: ${_getGrade(overall)}',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(_getPrediction(overall),
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.white70)),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).scale(),
              ),
            ),
          _subjects.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grade_rounded,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No subjects added',
                            style: GoogleFonts.poppins(fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('Tap + to add your scores',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.grey[400])),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final subject = _subjects[index];
                        final percentage = _getPercentage(subject);
                        final grade = _getGrade(percentage);
                        final color = _getGradeColor(percentage);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A1A2E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(subject['name'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(grade,
                                          style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: color)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      setState(() => _subjects.removeWhere(
                                          (s) => s['id'] == subject['id']));
                                    },
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red, size: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    '${subject['currentScore'].toStringAsFixed(0)}/${subject['totalScore'].toStringAsFixed(0)}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: color),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('marks',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, color: Colors.grey)),
                                  const Spacer(),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: color),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor: color.withOpacity(0.1),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(color),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(_getPrediction(percentage),
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ).animate().fadeIn(delay: (index * 100).ms)
                            .slideY(begin: 0.2, end: 0);
                      },
                      childCount: _subjects.length,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 220)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSubjectSheet,
        backgroundColor: const Color(0xFF6A1B9A),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Subject',
            style: GoogleFonts.poppins(fontSize: 14,
                fontWeight: FontWeight.w600, color: Colors.white)),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
    );
  }
}
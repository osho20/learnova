import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  List<Map<String, dynamic>> _exams = [];

  int _daysUntil(DateTime date) {
    final now = DateTime.now();
    return date.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  Color _urgencyColor(int days) {
    if (days <= 3) return Colors.red;
    if (days <= 7) return Colors.orange;
    if (days <= 14) return Colors.amber;
    return const Color(0xFF00695C);
  }

  String _urgencyLabel(int days) {
    if (days <= 0) return 'TODAY!';
    if (days <= 3) return '🔥 URGENT';
    if (days <= 7) return '⚠️ Soon';
    if (days <= 14) return '📅 Coming up';
    return '✅ Plenty of time';
  }

  int _readinessScore(int days) {
    if (days <= 0) return 20;
    if (days <= 3) return 35;
    if (days <= 7) return 55;
    if (days <= 14) return 70;
    return 85;
  }

  void _showAddExamSheet() {
    final nameController = TextEditingController();
    final subjectController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
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
              Text('Add Exam',
                  style: GoogleFonts.poppins(fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A237E))),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Exam name (e.g. Mid Semester)',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.assignment_rounded,
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
              TextField(
                controller: subjectController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Subject (e.g. Physics)',
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
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setSheetState(() => selectedDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: Color(0xFF1A237E), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text('Tap to change',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    setState(() {
                      _exams.add({
                        'id': const Uuid().v4(),
                        'name': nameController.text.trim(),
                        'subject': subjectController.text.trim(),
                        'date': selectedDate.toIso8601String(),
                      });
                      _exams.sort((a, b) => DateTime.parse(a['date'])
                          .compareTo(DateTime.parse(b['date'])));
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Add Exam',
                      style: GoogleFonts.poppins(fontSize: 16,
                          fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6FF),
      body: CustomScrollView(
        slivers: [
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
                        Text('Exam Countdown',
                            style: GoogleFonts.poppins(fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text('Stay ahead of your exams',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _exams.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_rounded,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No exams added',
                            style: GoogleFonts.poppins(fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('Tap + to add your first exam',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.grey[400])),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final exam = _exams[index];
                        final date = DateTime.parse(exam['date']);
                        final days = _daysUntil(date);
                        final color = _urgencyColor(days);
                        final readiness = _readinessScore(days);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A1A2E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border(
                                left: BorderSide(color: color, width: 5)),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.1),
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(exam['name'],
                                            style: GoogleFonts.poppins(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700)),
                                        if (exam['subject'].isNotEmpty)
                                          Text(exam['subject'],
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          days <= 0
                                              ? '0'
                                              : days.toString(),
                                          style: GoogleFonts.poppins(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                              color: color),
                                        ),
                                        Text('days',
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: color)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${date.day}/${date.month}/${date.year}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(_urgencyLabel(days),
                                        style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: color)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Readiness score
                              Row(
                                children: [
                                  Text('Readiness Score',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey)),
                                  const Spacer(),
                                  Text('$readiness%',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: color)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: readiness / 100,
                                  backgroundColor: color.withOpacity(0.1),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(color),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Delete button
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() => _exams.removeWhere(
                                        (e) => e['id'] == exam['id']));
                                  },
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      color: Colors.red, size: 16),
                                  label: Text('Remove',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, color: Colors.red)),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (index * 100).ms)
                            .slideY(begin: 0.2, end: 0);
                      },
                      childCount: _exams.length,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExamSheet,
        backgroundColor: const Color(0xFF1A237E),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Exam',
            style: GoogleFonts.poppins(fontSize: 14,
                fontWeight: FontWeight.w600, color: Colors.white)),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
    );
  }
}
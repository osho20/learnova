import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/storage_service.dart';
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Map<String, dynamic>> _subjects = [];
void _addSubject(String name) {
  final subject = {
    'id': const Uuid().v4(),
    'name': name,
    'present': 0,
    'absent': 0,
  };
  StorageService.instance.saveAttendance(subject);
  setState(() => _subjects.add(subject));
}
@override
void initState() {
  super.initState();
  _subjects = StorageService.instance.getAttendance();
}
  void _markAttendance(String id, bool isPresent) {
  setState(() {
    final index = _subjects.indexWhere((s) => s['id'] == id);
    if (index != -1) {
      if (isPresent) {
        _subjects[index]['present']++;
      } else {
        _subjects[index]['absent']++;
      }
      StorageService.instance.saveAttendance(_subjects[index]);
    }
  });
}
void _deleteSubject(String id) {
  StorageService.instance.deleteAttendance(id);
  setState(() => _subjects.removeWhere((s) => s['id'] == id));
}
  double _getPercentage(Map<String, dynamic> subject) {
    final total = subject['present'] + subject['absent'];
    if (total == 0) return 0;
    return (subject['present'] / total) * 100;
  }

  int _classesNeeded(Map<String, dynamic> subject) {
    final present = subject['present'];
    final total = subject['present'] + subject['absent'];
    if (_getPercentage(subject) >= 75) return 0;
    int needed = 0;
    while (((present + needed) / (total + needed)) * 100 < 75) {
      needed++;
    }
    return needed;
  }

  int _safeToSkip(Map<String, dynamic> subject) {
    final present = subject['present'];
    final total = subject['present'] + subject['absent'];
    if (_getPercentage(subject) < 75) return 0;
    int skip = 0;
    while (((present) / (total + skip + 1)) * 100 >= 75) {
      skip++;
    }
    return skip;
  }

  void _showEditSheet(Map<String, dynamic> subject) {
    final nameController = TextEditingController(text: subject['name']);
    int present = subject['present'];
    int absent = subject['absent'];

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
              Text('Edit Attendance',
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
              const SizedBox(height: 20),
              // Present counter
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Present Classes',
                            style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: const Color(0xFF00695C))),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (present > 0) {
                                  setSheetState(() => present--);
                                }
                              },
                              icon: const Icon(Icons.remove_circle_rounded,
                                  color: Colors.red),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.1),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text('$present',
                                    style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF00695C))),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setSheetState(() => present++),
                              icon: const Icon(Icons.add_circle_rounded,
                                  color: Color(0xFF00695C)),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF00695C)
                                    .withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Absent counter
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Absent Classes',
                            style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: Colors.red)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (absent > 0) {
                                  setSheetState(() => absent--);
                                }
                              },
                              icon: const Icon(Icons.remove_circle_rounded,
                                  color: Colors.red),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.1),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text('$absent',
                                    style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red)),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setSheetState(() => absent++),
                              icon: const Icon(Icons.add_circle_rounded,
                                  color: Colors.red),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Live percentage preview
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pie_chart_rounded,
                        color: Color(0xFF1A237E), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Attendance: ${(present + absent) == 0 ? 0 : ((present / (present + absent)) * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A237E)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _deleteSubject(subject['id']);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text('Delete',
                          style: GoogleFonts.poppins(fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) return;
                        setState(() {
                          final index = _subjects.indexWhere(
                              (s) => s['id'] == subject['id']);
                          if (index != -1) {
                            _subjects[index] = {
                              ...subject,
                              'name': nameController.text.trim(),
                              'present': present,
                              'absent': absent,
                            };
                          }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Save Changes',
                          style: GoogleFonts.poppins(fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSubjectSheet() {
    final nameController = TextEditingController();
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
                hintText: 'Subject name (e.g. Physics)',
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
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    _addSubject(nameController.text.trim());
                    Navigator.pop(context);
                  }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                        Text('Attendance',
                            style: GoogleFonts.poppins(fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text('Track your attendance',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _subjects.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fact_check_rounded,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No subjects yet',
                            style: GoogleFonts.poppins(fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('Tap + to add a subject',
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
                        final subject = _subjects[index];
                        final percentage = _getPercentage(subject);
                        final needed = _classesNeeded(subject);
                        final safe = _safeToSkip(subject);
                        final color = percentage >= 75
                            ? const Color(0xFF00695C)
                            : percentage >= 60
                                ? Colors.orange
                                : Colors.red;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A1A2E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
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
                                  // Edit button
                                  IconButton(
                                    onPressed: () => _showEditSheet(subject),
                                    icon: const Icon(Icons.edit_rounded,
                                        color: Color(0xFF1A237E), size: 20),
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFF1A237E)
                                          .withOpacity(0.08),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: color)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
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
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildStat('Present',
                                      subject['present'].toString(),
                                      const Color(0xFF00695C)),
                                  const SizedBox(width: 16),
                                  _buildStat('Absent',
                                      subject['absent'].toString(),
                                      Colors.red),
                                  const SizedBox(width: 16),
                                  _buildStat(
                                      'Total',
                                      (subject['present'] + subject['absent'])
                                          .toString(),
                                      const Color(0xFF1A237E)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (needed > 0)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_rounded,
                                          color: Colors.red, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                            'Attend $needed more classes to reach 75%',
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.red,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ],
                                  ),
                                )
                              else if (safe > 0)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00695C)
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          color: Color(0xFF00695C), size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                          'You can skip $safe more classes',
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: const Color(0xFF00695C),
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _markAttendance(
                                          subject['id'], true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF00695C),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      icon: const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 18),
                                      label: Text('Present',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _markAttendance(
                                          subject['id'], false),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      icon: const Icon(Icons.close_rounded,
                                          color: Colors.white, size: 18),
                                      label: Text('Absent',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
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
        backgroundColor: const Color(0xFF1A237E),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Subject',
            style: GoogleFonts.poppins(fontSize: 14,
                fontWeight: FontWeight.w600, color: Colors.white)),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

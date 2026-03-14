import '../attendance/attendance_screen.dart';
import '../pomodoro/pomodoro_screen.dart';
import '../exam/exam_screen.dart';
import '../timetable/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../subjects/subjects_screen.dart';
import '../notes/notes_screen.dart';
import '../assignments/assignments_screen.dart';
import '../flashcards/flashcards_screen.dart';
import '../studytwin/studytwin_screen.dart';
import '../grades/grades_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const SubjectsScreen(),
    const NotesScreen(),
    const AssignmentsScreen(),
    const FlashcardsScreen(),
    const TimetableScreen(),
    const AttendanceScreen(),
    const PomodoroScreen(),
    const ExamScreen(),
    const StudyTwinScreen(),
    const GradesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF1A237E),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: const [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_rounded),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.folder_rounded),
    label: 'Subjects',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.note_rounded),
    label: 'Notes',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.auto_awesome_rounded),
    label: 'Assign',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.style_rounded),
    label: 'Cards',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.calendar_month_rounded),
    label: 'Timetable',
    
  ),
  BottomNavigationBarItem(
  icon: Icon(Icons.fact_check_rounded),
  label: 'Attendance',
),
BottomNavigationBarItem(
  icon: Icon(Icons.timer_rounded),
  label: 'Pomodoro',
),
BottomNavigationBarItem(
  icon: Icon(Icons.event_rounded),
  label: 'Exams',
),
BottomNavigationBarItem(
  icon: Icon(Icons.psychology_rounded),
  label: 'AI Twin',
),
BottomNavigationBarItem(
  icon: Icon(Icons.grade_rounded),
  label: 'Grades',
),
],

        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final box = Hive.box('settings');
    final userName = box.get('userName', defaultValue: 'Student');
    final collegeName = box.get('collegeName', defaultValue: 'Your College');

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A237E),
                      Color(0xFF3949AB),
                      Color(0xFF1565C0),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.school_rounded,
                                  color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Welcome back,',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13, color: Colors.white70)),
                                  Text(userName,
                                      style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(collegeName,
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white60)),
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
                  const SizedBox(height: 8),
                  Text('Quick Actions',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A237E))),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildQuickAction(
                        context,
                        icon: Icons.auto_awesome_rounded,
                        title: 'New Assignment',
                        color: const Color(0xFF1A237E),
                        bgColor: const Color(0xFFE8EAF6),
                        onTap: () {},
                      ),
                      _buildQuickAction(
                        context,
                        icon: Icons.note_add_rounded,
                        title: 'New Note',
                        color: const Color(0xFF00695C),
                        bgColor: const Color(0xFFE0F2F1),
                        onTap: () {},
                      ),
                      _buildQuickAction(
                        context,
                        icon: Icons.style_rounded,
                        title: 'Study Flashcards',
                        color: const Color(0xFF6A1B9A),
                        bgColor: const Color(0xFFF3E5F5),
                        onTap: () {},
                      ),
                      _buildQuickAction(
                        context,
                        icon: Icons.psychology_rounded,
                        title: 'Study Twin',
                        color: const Color(0xFFE65100),
                        bgColor: const Color(0xFFFBE9E7),
                        onTap: () {},
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 24),
                  Text('Your Progress',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A237E))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatCard('0', 'Subjects',
                              Icons.folder_rounded, const Color(0xFF1A237E), isDark)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildStatCard('0', 'Notes',
                              Icons.note_rounded, const Color(0xFF00695C), isDark)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildStatCard('0', 'Flashcards',
                              Icons.style_rounded, const Color(0xFF6A1B9A), isDark)),
                    ],
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon,
      Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color)),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../subjects/subjects_screen.dart';
import '../notes/notes_screen.dart';
import '../assignments/assignments_screen.dart';
import '../flashcards/flashcards_screen.dart';
import '../timetable/timetable_screen.dart';
import '../attendance/attendance_screen.dart';
import '../pomodoro/pomodoro_screen.dart';
import '../exam/exam_screen.dart';
import '../studytwin/studytwin_screen.dart';
import '../grades/grades_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const StudyTwinScreen(),
    const SubjectsScreen(),
    const NotesScreen(),
    const AssignmentsScreen(),
    const FlashcardsScreen(),
    const TimetableScreen(),
    const AttendanceScreen(),
    const PomodoroScreen(),
    const ExamScreen(),
    const GradesScreen(),
    const SettingsScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_rounded, 'label': 'Home', 'color': const Color(0xFF1A237E)},
    {'icon': Icons.psychology_rounded, 'label': 'AI Twin', 'color': const Color(0xFFE65100)},
    {'icon': Icons.folder_rounded, 'label': 'Subjects', 'color': const Color(0xFF00695C)},
    {'icon': Icons.note_rounded, 'label': 'Notes', 'color': const Color(0xFF6A1B9A)},
    {'icon': Icons.auto_awesome_rounded, 'label': 'Assign', 'color': const Color(0xFF0D47A1)},
    {'icon': Icons.style_rounded, 'label': 'Cards', 'color': const Color(0xFFB71C1C)},
    {'icon': Icons.calendar_month_rounded, 'label': 'Time', 'color': const Color(0xFF1A237E)},
    {'icon': Icons.fact_check_rounded, 'label': 'Attend', 'color': const Color(0xFF00695C)},
    {'icon': Icons.timer_rounded, 'label': 'Pomodoro', 'color': const Color(0xFF1A237E)},
    {'icon': Icons.event_rounded, 'label': 'Exams', 'color': const Color(0xFFB71C1C)},
    {'icon': Icons.grade_rounded, 'label': 'Grades', 'color': const Color(0xFF6A1B9A)},
    {'icon': Icons.settings_rounded, 'label': 'Settings', 'color': const Color(0xFF1A237E)},
  ];

  void _onNavTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: false,
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildPremiumNav(isDark),
    );
  }

  Widget _buildPremiumNav(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1A2E).withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A237E).withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            itemCount: _navItems.length,
            itemBuilder: (context, index) {
              final item = _navItems[index];
              final isSelected = _currentIndex == index;
              final color = item['color'] as Color;

              return GestureDetector(
                onTap: () => _onNavTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 18 : 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.45),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 22,
                        color: isSelected
                            ? Colors.white
                            : isDark
                                ? Colors.white38
                                : Colors.black38,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          item['label'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Map<String, dynamic>> _quickActions = [
    {
      'icon': Icons.auto_awesome_rounded,
      'title': 'AI Assignment',
      'subtitle': 'Generate answers',
      'color': const Color(0xFF1A237E),
      'bgColor': const Color(0xFFE8EAF6),
      'page': 4,
    },
    {
      'icon': Icons.note_add_rounded,
      'title': 'My Notes',
      'subtitle': 'Write & organize',
      'color': const Color(0xFF00695C),
      'bgColor': const Color(0xFFE0F2F1),
      'page': 3,
    },
    {
      'icon': Icons.style_rounded,
      'title': 'Flashcards',
      'subtitle': 'Study & review',
      'color': const Color(0xFF6A1B9A),
      'bgColor': const Color(0xFFF3E5F5),
      'page': 5,
    },
    {
      'icon': Icons.psychology_rounded,
      'title': 'AI Study Twin',
      'subtitle': 'Chat & learn',
      'color': const Color(0xFFE65100),
      'bgColor': const Color(0xFFFBE9E7),
      'page': 1,
    },
    {
      'icon': Icons.timer_rounded,
      'title': 'Pomodoro',
      'subtitle': 'Focus timer',
      'color': const Color(0xFF0D47A1),
      'bgColor': const Color(0xFFE3F2FD),
      'page': 8,
    },
    {
      'icon': Icons.event_rounded,
      'title': 'Exam Countdown',
      'subtitle': 'Track exams',
      'color': const Color(0xFFB71C1C),
      'bgColor': const Color(0xFFFFEBEE),
      'page': 9,
    },
  ];

  void _navigateTo(BuildContext context, int pageIndex) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    homeState?.setState(() => homeState._currentIndex = pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final box = Hive.box('settings');
    final userName = box.get('userName', defaultValue: 'Student');
    final collegeName = box.get('collegeName', defaultValue: 'Your College');
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D1B6B),
                      Color(0xFF1A237E),
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
                                  Text('$greeting 👋',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.white70)),
                                  Text(userName,
                                      style: GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(collegeName,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.white60)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Quick Actions',
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A237E))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.45,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _quickActions.length,
                    itemBuilder: (context, index) {
                      final action = _quickActions[index];
                      final color = action['color'] as Color;
                      return GestureDetector(
                        onTap: () =>
                            _navigateTo(context, action['page'] as int),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A1A2E)
                                : action['bgColor'] as Color,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: color.withOpacity(0.15), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(action['icon'] as IconData,
                                    color: color, size: 24),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(action['title'] as String,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white
                                              : color)),
                                  Text(action['subtitle'] as String,
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: isDark
                                              ? Colors.white38
                                              : color.withOpacity(0.6))),
                                ],
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: (index * 80).ms)
                            .slideY(begin: 0.3, end: 0),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00695C),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Your Progress',
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A237E))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatCard(
                              '📚', 'Subjects',
                              const Color(0xFF1A237E), isDark)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildStatCard(
                              '📝', 'Notes',
                              const Color(0xFF00695C), isDark)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildStatCard(
                              '🃏', 'Cards',
                              const Color(0xFF6A1B9A), isDark)),
                    ],
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String emoji, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  late int _selectedDay;
  final DateTime _now = DateTime.now();

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<String> _fullDays = [
    'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday'
  ];

  final Map<int, List<Map<String, dynamic>>> _timetable = {
    0: <Map<String, dynamic>>[],
    1: <Map<String, dynamic>>[],
    2: <Map<String, dynamic>>[],
    3: <Map<String, dynamic>>[],
    4: <Map<String, dynamic>>[],
    5: <Map<String, dynamic>>[],
  };

  final List<Color> _colors = [
    const Color(0xFF1A237E),
    const Color(0xFF6A1B9A),
    const Color(0xFF00695C),
    const Color(0xFFB71C1C),
    const Color(0xFFE65100),
    const Color(0xFF0D47A1),
    const Color(0xFF880E4F),
    const Color(0xFF1B5E20),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-select today (0=Mon, 1=Tue... 5=Sat, Sunday defaults to Mon)
    final weekday = _now.weekday; // 1=Mon, 7=Sun
    _selectedDay = weekday <= 6 ? weekday - 1 : 0;
    if (_selectedDay > 5) _selectedDay = 0;
  }

  bool _isToday(int index) {
    final weekday = _now.weekday;
    return weekday - 1 == index;
  }

  String _getCurrentTimeSlot() {
    final hour = _now.hour;
    final minute = _now.minute;
    return '$hour:${minute.toString().padLeft(2, '0')}';
  }

  bool _isCurrentClass(Map<String, dynamic> cls) {
    if (!_isToday(_selectedDay)) return false;
    final now = _now.hour * 60 + _now.minute;
    final start = _parseTime(cls['startTime']);
    final end = _parseTime(cls['endTime']);
    return now >= start && now <= end;
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  void _showAddClassSheet() {
    final subjectController = TextEditingController();
    final roomController = TextEditingController();
    final teacherController = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
    int selectedColor = 0;

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
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
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
                Text('Add Class',
                    style: GoogleFonts.poppins(fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A237E))),
                Text('${_fullDays[_selectedDay]}',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 20),
                TextField(
                  controller: subjectController,
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
                TextField(
                  controller: roomController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Room / Location',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.room_rounded,
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
                  controller: teacherController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Teacher name (optional)',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.person_rounded,
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
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );
                          if (time != null) {
                            setSheetState(() => startTime = time);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  color: Color(0xFF1A237E), size: 18),
                              const SizedBox(width: 8),
                              Text(startTime.format(context),
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: Colors.grey),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );
                          if (time != null) {
                            setSheetState(() => endTime = time);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  color: Color(0xFF1A237E), size: 18),
                              const SizedBox(width: 8),
                              Text(endTime.format(context),
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Color',
                    style: GoogleFonts.poppins(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A237E))),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colors.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedColor == index;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedColor = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36, height: 36,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: _colors[index],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                  color: _colors[index].withOpacity(0.5),
                                  blurRadius: 8)
                            ] : [],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (subjectController.text.trim().isEmpty) return;
                      setState(() {
                        _timetable[_selectedDay]!.add({
                          'subject': subjectController.text.trim(),
                          'room': roomController.text.trim(),
                          'teacher': teacherController.text.trim(),
                          'startTime':
                              '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
                          'endTime':
                              '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}',
                          'color': selectedColor,
                        });
                        _timetable[_selectedDay]!.sort((a, b) =>
                            a['startTime'].compareTo(b['startTime']));
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Add to Timetable',
                        style: GoogleFonts.poppins(fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayClasses = _timetable[_selectedDay] ?? [];

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
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Timetable',
                                      style: GoogleFonts.poppins(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white)),
                                  Text(
                                    _fullDays[_selectedDay] +
                                        (_isToday(_selectedDay)
                                            ? ' • Today 📅'
                                            : ''),
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(_getCurrentTimeSlot(),
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Day selector
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF1A237E),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_days.length, (index) {
                  final isSelected = _selectedDay == index;
                  final isToday = _isToday(index);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 48, height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? Colors.white.withOpacity(0.25)
                                : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: isToday && !isSelected
                            ? Border.all(
                                color: Colors.white.withOpacity(0.6),
                                width: 1.5)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_days[index],
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? const Color(0xFF1A237E)
                                      : Colors.white)),
                          if (isToday)
                            Container(
                              width: 4, height: 4,
                              margin: const EdgeInsets.only(top: 3),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1A237E)
                                    : Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Classes list
          todayClasses.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          _isToday(_selectedDay)
                              ? 'No classes today! 🎉'
                              : 'No classes on ${_days[_selectedDay]}',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text('Tap + to add a class',
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
                        final cls = todayClasses[index];
                        final color = _colors[cls['color']];
                        final isCurrent = _isCurrentClass(cls);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A1A2E) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border(
                              left: BorderSide(color: color, width: 5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isCurrent
                                    ? color.withOpacity(0.2)
                                    : Colors.black.withOpacity(0.04),
                                blurRadius: isCurrent ? 20 : 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.class_rounded,
                                  color: color, size: 26),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(cls['subject'],
                                      style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: color)),
                                ),
                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('NOW',
                                        style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white)),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded,
                                        size: 13, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                        '${cls['startTime']} - ${cls['endTime']}',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey)),
                                  ],
                                ),
                                if ((cls['room'] as String).isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.room_rounded,
                                          size: 13, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(cls['room'],
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ],
                                if ((cls['teacher'] as String).isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.person_rounded,
                                          size: 13, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(cls['teacher'],
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _timetable[_selectedDay]!.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ).animate().fadeIn(delay: (index * 80).ms)
                            .slideX(begin: -0.1, end: 0);
                      },
                      childCount: todayClasses.length,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 220)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddClassSheet,
        backgroundColor: const Color(0xFF1A237E),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Class',
            style: GoogleFonts.poppins(fontSize: 14,
                fontWeight: FontWeight.w600, color: Colors.white)),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
    );
  }
}

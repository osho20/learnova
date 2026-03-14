import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int _selectedDay = DateTime.now().weekday - 1;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  final Map<int, List<Map<String, dynamic>>> _timetable = {
    0: [], 1: [], 2: [], 3: [], 4: [], 5: [],
  };

  final List<Color> _colors = [
    const Color(0xFF1A237E),
    const Color(0xFF6A1B9A),
    const Color(0xFF00695C),
    const Color(0xFFB71C1C),
    const Color(0xFFE65100),
    const Color(0xFF0D47A1),
  ];

  void _showAddClassSheet() {
    final subjectController = TextEditingController();
    final roomController = TextEditingController();
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
              Text('Add Class',
                  style: GoogleFonts.poppins(fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A237E))),
              const SizedBox(height: 16),
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
                  hintText: 'Room / Location (optional)',
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
              Row(
                children: List.generate(_colors.length, (index) {
                  final isSelected = selectedColor == index;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedColor = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36, height: 36,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: _colors[index],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(color: _colors[index].withOpacity(0.5),
                              blurRadius: 8)
                        ] : [],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }),
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
                        'startTime': '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
                        'endTime': '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}',
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
    final todayClasses = _timetable[_selectedDay] ?? [];

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
                        Text('Timetable',
                            style: GoogleFonts.poppins(fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text('Weekly class schedule',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Day selector
                Container(
                  color: const Color(0xFF1A237E),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_days.length, (index) {
                      final isSelected = _selectedDay == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(_days[index],
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF1A237E)
                                        : Colors.white)),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                if (todayClasses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No classes on ${_days[_selectedDay]}',
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.w600,
                                  color: Colors.grey)),
                          const SizedBox(height: 8),
                          Text('Tap + to add a class',
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: Colors.grey[400])),
                        ],
                      ),
                    ),
                  )
                else
                  ...todayClasses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cls = entry.value;
                    final color = _colors[cls['color']];
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1A1A2E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border(
                            left: BorderSide(color: color, width: 5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.class_rounded,
                              color: color, size: 24),
                        ),
                        title: Text(cls['subject'],
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: color)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                    '${cls['startTime']} - ${cls['endTime']}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            if (cls['room'].isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.room_rounded,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(cls['room'],
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
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
                  }),
                const SizedBox(height: 100),
              ],
            ),
          ),
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
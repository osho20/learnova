import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../notes/notes_screen.dart';
import '../assignments/assignments_screen.dart';
import '../flashcards/flashcards_screen.dart';

class SubjectDetailScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final Color color;

  const SubjectDetailScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.color,
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6FF),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: widget.color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color,
                      widget.color.withOpacity(0.7),
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
                        Text(widget.subjectName,
                            style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Notes • Assignments • Flashcards',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: '📝 Notes'),
                Tab(text: '✨ Assignments'),
                Tab(text: '🃏 Flashcards'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            NotesScreen(
              subjectId: widget.subjectId,
              subjectName: widget.subjectName,
            ),
            AssignmentsScreen(
              subjectId: widget.subjectId,
              subjectName: widget.subjectName,
            ),
            const FlashcardsScreen(),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/db_service.dart';

class Subject {
  final String id;
  final String name;
  final String colorHex;
  final String icon;
  bool isPinned;

  Subject({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.icon,
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorHex': colorHex,
        'icon': icon,
        'isPinned': isPinned ? 1 : 0,
        'createdAt': DateTime.now().toIso8601String(),
      };

  factory Subject.fromMap(Map<String, dynamic> map) => Subject(
        id: map['id'],
        name: map['name'],
        colorHex: map['colorHex'],
        icon: map['icon'],
        isPinned: map['isPinned'] == 1,
      );
}

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  List<Subject> _subjects = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Indigo', 'hex': '#1A237E', 'color': const Color(0xFF1A237E)},
    {'name': 'Purple', 'hex': '#6A1B9A', 'color': const Color(0xFF6A1B9A)},
    {'name': 'Teal', 'hex': '#00695C', 'color': const Color(0xFF00695C)},
    {'name': 'Red', 'hex': '#B71C1C', 'color': const Color(0xFFB71C1C)},
    {'name': 'Orange', 'hex': '#E65100', 'color': const Color(0xFFE65100)},
    {'name': 'Green', 'hex': '#1B5E20', 'color': const Color(0xFF1B5E20)},
    {'name': 'Blue', 'hex': '#0D47A1', 'color': const Color(0xFF0D47A1)},
    {'name': 'Pink', 'hex': '#880E4F', 'color': const Color(0xFF880E4F)},
  ];

  final List<Map<String, dynamic>> _iconOptions = [
    {'icon': Icons.science_rounded, 'name': 'Science'},
    {'icon': Icons.calculate_rounded, 'name': 'Math'},
    {'icon': Icons.history_edu_rounded, 'name': 'History'},
    {'icon': Icons.language_rounded, 'name': 'Language'},
    {'icon': Icons.computer_rounded, 'name': 'Computer'},
    {'icon': Icons.biotech_rounded, 'name': 'Biology'},
    {'icon': Icons.public_rounded, 'name': 'Geography'},
    {'icon': Icons.psychology_rounded, 'name': 'Psychology'},
    {'icon': Icons.music_note_rounded, 'name': 'Music'},
    {'icon': Icons.brush_rounded, 'name': 'Art'},
    {'icon': Icons.sports_soccer_rounded, 'name': 'Sports'},
    {'icon': Icons.menu_book_rounded, 'name': 'Literature'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final db = await DBService.instance.database;
      final maps = await db.query('subjects', orderBy: 'isPinned DESC, createdAt ASC');
      setState(() {
        _subjects = maps.map((m) => Subject.fromMap(m)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSubject(String name, String colorHex, String icon) async {
    final subject = Subject(
      id: const Uuid().v4(),
      name: name,
      colorHex: colorHex,
      icon: icon,
    );
    try {
      final db = await DBService.instance.database;
      await db.insert('subjects', subject.toMap());
      setState(() => _subjects.add(subject));
    } catch (e) {
      setState(() => _subjects.add(subject));
    }
  }

  Future<void> _deleteSubject(String id) async {
    try {
      final db = await DBService.instance.database;
      await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      // ignore on web
    }
    setState(() => _subjects.removeWhere((s) => s.id == id));
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  void _showAddSubjectSheet() {
    final nameController = TextEditingController();
    String selectedColor = _colorOptions[0]['hex'];
    String selectedIcon = 'science';
    int selectedColorIndex = 0;
    int selectedIconIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1A1A2E)
                : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'New Subject',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: GoogleFonts.poppins(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Subject name (e.g. Physics)',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFFF4F6FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
                  ),
                  prefixIcon: const Icon(Icons.book_rounded, color: Color(0xFF1A237E)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Pick a Color',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A237E))),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colorOptions.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedColorIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          selectedColorIndex = index;
                          selectedColor = _colorOptions[index]['hex'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: _colorOptions[index]['color'],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: _colorOptions[index]['color'].withOpacity(0.5), blurRadius: 8)]
                              : [],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text('Pick an Icon',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A237E))),
              const SizedBox(height: 10),
              SizedBox(
                height: 54,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _iconOptions.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedIconIndex == index;
                    final color = _hexToColor(selectedColor);
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          selectedIconIndex = index;
                          selectedIcon = _iconOptions[index]['name'].toString().toLowerCase();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 54,
                        height: 54,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _iconOptions[index]['icon'],
                          color: isSelected ? color : Colors.grey,
                          size: 26,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      _addSubject(nameController.text.trim(), selectedColor, selectedIcon);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Create Subject',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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
      backgroundColor: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                        Text('My Subjects',
                            style: GoogleFonts.poppins(
                                fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('${_subjects.length} subjects',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _isLoading
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              : _subjects.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('No subjects yet',
                                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text('Tap + to add your first subject',
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400])),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final subject = _subjects[index];
                            final color = _hexToColor(subject.colorHex);
                            return _buildSubjectCard(subject, color, index);
                          },
                          childCount: _subjects.length,
                        ),
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSubjectSheet,
        backgroundColor: const Color(0xFF1A237E),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Subject',
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
    );
  }

  Widget _buildSubjectCard(Subject subject, Color color, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(subject),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border(left: BorderSide(color: color, width: 5)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getIcon(subject.icon), color: color, size: 24),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: color.withOpacity(0.5), size: 16),
              ],
            ),
            const Spacer(),
            Text(
              subject.name,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: color),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text('Tap to open',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400])),
          ],
        ),
      ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.2, end: 0),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'science': return Icons.science_rounded;
      case 'math': return Icons.calculate_rounded;
      case 'history': return Icons.history_edu_rounded;
      case 'language': return Icons.language_rounded;
      case 'computer': return Icons.computer_rounded;
      case 'biology': return Icons.biotech_rounded;
      case 'geography': return Icons.public_rounded;
      case 'psychology': return Icons.psychology_rounded;
      case 'music': return Icons.music_note_rounded;
      case 'art': return Icons.brush_rounded;
      case 'sports': return Icons.sports_soccer_rounded;
      default: return Icons.menu_book_rounded;
    }
  }

  void _showDeleteDialog(Subject subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Subject?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "${subject.name}"?',
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteSubject(subject.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
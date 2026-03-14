import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';

class NotesScreen extends StatefulWidget {
  final String? subjectId;
  final String? subjectName;
  const NotesScreen({super.key, this.subjectId, this.subjectName});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> _notes = [];
  String _searchQuery = '';

  Color _tagColor(String? tag) {
    switch (tag) {
      case 'important': return Colors.red;
      case 'review': return Colors.orange;
      case 'exam': return Colors.purple;
      default: return const Color(0xFF1A237E);
    }
  }

  Future<void> _togglePin(Map<String, dynamic> note) async {
    final newPin = note['isPinned'] == 1 ? 0 : 1;
    setState(() {
      final index = _notes.indexWhere((n) => n['id'] == note['id']);
      if (index != -1) _notes[index] = {...note, 'isPinned': newPin};
      _notes.sort((a, b) {
        if (b['isPinned'] != a['isPinned']) return b['isPinned'] - a['isPinned'];
        return b['createdAt'].compareTo(a['createdAt']);
      });
    });
  }

  void _deleteNote(String id) {
    setState(() => _notes.removeWhere((n) => n['id'] == id));
  }

  List<Map<String, dynamic>> get _filteredNotes {
    if (_searchQuery.isEmpty) return _notes;
    return _notes.where((n) =>
        n['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
        n['content'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void _showAddNoteSheet({Map<String, dynamic>? existing}) {
    final titleController = TextEditingController(text: existing?['title'] ?? '');
    final contentController = TextEditingController(text: existing?['content'] ?? '');
    String selectedTag = existing?['tag'] ?? 'general';

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
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
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
              const SizedBox(height: 16),
              Text(existing != null ? 'Edit Note' : 'New Note',
                  style: GoogleFonts.poppins(fontSize: 22,
                      fontWeight: FontWeight.w700, color: const Color(0xFF1A237E))),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Note title...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
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
                children: ['general', 'important', 'review', 'exam'].map((tag) {
                  final isSelected = selectedTag == tag;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedTag = tag),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _tagColor(tag) : _tagColor(tag).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tag,
                          style: GoogleFonts.poppins(fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : _tagColor(tag))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: GoogleFonts.poppins(fontSize: 14, height: 1.6),
                  decoration: InputDecoration(
                    hintText: 'Write your notes here...',
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    if (existing != null) {
                      setState(() {
                        final index = _notes.indexWhere((n) => n['id'] == existing['id']);
                        if (index != -1) {
                          _notes[index] = {
                            ...existing,
                            'title': titleController.text.trim(),
                            'content': contentController.text.trim(),
                            'tag': selectedTag,
                          };
                        }
                      });
                    } else {
                      setState(() {
                        _notes.insert(0, {
                          'id': const Uuid().v4(),
                          'subjectId': widget.subjectId ?? 'general',
                          'title': titleController.text.trim(),
                          'content': contentController.text.trim(),
                          'tag': selectedTag,
                          'isPinned': 0,
                          'createdAt': DateTime.now().toIso8601String(),
                        });
                      });
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Save Note',
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
      backgroundColor: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6FF),
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
                        Text('My Notes',
                            style: GoogleFonts.poppins(fontSize: 28,
                                fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('${_notes.length} notes saved',
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF1A237E)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          _filteredNotes.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No notes yet',
                            style: GoogleFonts.poppins(fontSize: 18,
                                fontWeight: FontWeight.w600, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('Tap + to create your first note',
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
                        final note = _filteredNotes[index];
                        final tagColor = _tagColor(note['tag']);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border(left: BorderSide(color: tagColor, width: 4)),
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
                            title: Row(
                              children: [
                                if (note['isPinned'] == 1)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6),
                                    child: Icon(Icons.push_pin_rounded,
                                        size: 16, color: Colors.amber),
                                  ),
                                Expanded(
                                  child: Text(note['title'],
                                      style: GoogleFonts.poppins(
                                          fontSize: 15, fontWeight: FontWeight.w700)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: tagColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(note['tag'] ?? 'general',
                                      style: GoogleFonts.poppins(fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: tagColor)),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(note['content'] ?? '',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13, color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert_rounded),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  onTap: () => Future.delayed(Duration.zero,
                                      () => _showAddNoteSheet(existing: note)),
                                  child: Row(children: [
                                    const Icon(Icons.edit_rounded, size: 18),
                                    const SizedBox(width: 8),
                                    Text('Edit', style: GoogleFonts.poppins()),
                                  ]),
                                ),
                                PopupMenuItem(
                                  onTap: () => _togglePin(note),
                                  child: Row(children: [
                                    const Icon(Icons.push_pin_rounded, size: 18),
                                    const SizedBox(width: 8),
                                    Text(note['isPinned'] == 1 ? 'Unpin' : 'Pin',
                                        style: GoogleFonts.poppins()),
                                  ]),
                                ),
                                PopupMenuItem(
                                  onTap: () => _deleteNote(note['id']),
                                  child: Row(children: [
                                    const Icon(Icons.delete_rounded,
                                        size: 18, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text('Delete',
                                        style: GoogleFonts.poppins(color: Colors.red)),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: (index * 80).ms)
                            .slideX(begin: -0.1, end: 0);
                      },
                      childCount: _filteredNotes.length,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNoteSheet(),
        backgroundColor: const Color(0xFF1A237E),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Note',
            style: GoogleFonts.poppins(fontSize: 14,
                fontWeight: FontWeight.w600, color: Colors.white)),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
    );
  }
}

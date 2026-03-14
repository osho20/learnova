import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  List<Map<String, dynamic>> _flashcards = [];
  bool _isReviewMode = false;
  int _currentIndex = 0;
  bool _isFlipped = false;

  void _addFlashcard(String question, String answer) {
    setState(() {
      _flashcards.add({
        'id': const Uuid().v4(),
        'question': question,
        'answer': answer,
        'isDifficult': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
    });
  }

  void _deleteFlashcard(String id) {
    setState(() => _flashcards.removeWhere((f) => f['id'] == id));
  }

  void _toggleDifficult(String id) {
    setState(() {
      final index = _flashcards.indexWhere((f) => f['id'] == id);
      if (index != -1) {
        _flashcards[index] = {
          ..._flashcards[index],
          'isDifficult': !_flashcards[index]['isDifficult'],
        };
      }
    });
  }

  void _startReview({bool difficultOnly = false}) {
    void _startReview({bool difficultOnly = false}) {
    List<Map<String, dynamic>> cards = difficultOnly
        ? _flashcards.where((f) => f['isDifficult'] == true).toList()
        : List<Map<String, dynamic>>.from(_flashcards);
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No cards to review!', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF1A237E),
        ),
      );
      return;
    }
    cards.shuffle(Random());
    setState(() {
      _flashcards = cards;
      _isReviewMode = true;
      _currentIndex = 0;
      _isFlipped = false;
    });
  }
  }

  void _showAddFlashcardSheet() {
    final questionController = TextEditingController();
    final answerController = TextEditingController();

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
            Text('New Flashcard',
                style: GoogleFonts.poppins(fontSize: 22,
                    fontWeight: FontWeight.w700, color: const Color(0xFF1A237E))),
            const SizedBox(height: 20),
            TextField(
              controller: questionController,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Question / Front side...',
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
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: answerController,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Answer / Back side...',
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
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (questionController.text.trim().isNotEmpty &&
                      answerController.text.trim().isNotEmpty) {
                    _addFlashcard(
                      questionController.text.trim(),
                      answerController.text.trim(),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Create Flashcard',
                    style: GoogleFonts.poppins(fontSize: 16,
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isReviewMode) {
      return _buildReviewMode(isDark);
    }

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
                        Text('Flashcards',
                            style: GoogleFonts.poppins(fontSize: 28,
                                fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('${_flashcards.length} cards',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_flashcards.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _startReview(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow_rounded,
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              Text('Review All',
                                  style: GoogleFonts.poppins(
                                      fontSize: 15, fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _startReview(difficultOnly: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.red),
                              const SizedBox(width: 8),
                              Text('Difficult',
                                  style: GoogleFonts.poppins(
                                      fontSize: 15, fontWeight: FontWeight.w600,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          _flashcards.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.style_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No flashcards yet',
                            style: GoogleFonts.poppins(fontSize: 18,
                                fontWeight: FontWeight.w600, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('Tap + to create your first card',
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
                        final card = _flashcards[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A237E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.style_rounded,
                                  color: Color(0xFF1A237E)),
                            ),
                            title: Text(card['question'],
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(card['answer'],
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _toggleDifficult(card['id']),
                                  icon: Icon(
                                    card['isDifficult'] == true
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: card['isDifficult'] == true
                                        ? Colors.amber : Colors.grey,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _deleteFlashcard(card['id']),
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: (index * 80).ms)
                            .slideX(begin: -0.1, end: 0);
                      },
                      childCount: _flashcards.length,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFlashcardSheet,
        backgroundColor: const Color(0xFF1A237E),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Card',
            style: GoogleFonts.poppins(fontSize: 14,
                fontWeight: FontWeight.w600, color: Colors.white)),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
    );
  }

  Widget _buildReviewMode(bool isDark) {
    final card = _flashcards[_currentIndex];
    final progress = (_currentIndex + 1) / _flashcards.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: Text('Review Mode',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => setState(() => _isReviewMode = false),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${_currentIndex + 1}/${_flashcards.length}',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: Colors.white70)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A237E)),
            minHeight: 4,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isFlipped ? 'Answer' : 'Question',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  // 3D Flip Card
                  GestureDetector(
                    onTap: () => setState(() => _isFlipped = !_isFlipped),
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(
                          begin: 0, end: _isFlipped ? pi : 0),
                      duration: const Duration(milliseconds: 400),
                      builder: (context, double value, child) {
                        final showFront = value < pi / 2;
                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(value),
                          alignment: Alignment.center,
                          child: Container(
                            width: double.infinity,
                            height: 280,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: showFront
                                    ? [const Color(0xFF1A237E), const Color(0xFF3949AB)]
                                    : [const Color(0xFF00695C), const Color(0xFF00897B)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: (showFront
                                      ? const Color(0xFF1A237E)
                                      : const Color(0xFF00695C)).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Transform(
                                  transform: Matrix4.identity()
                                    ..rotateY(showFront ? 0 : pi),
                                  alignment: Alignment.center,
                                  child: Text(
                                    showFront
                                        ? card['question']
                                        : card['answer'],
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.5),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Tap card to flip',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 32),
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _currentIndex > 0
                            ? () => setState(() {
                                  _currentIndex--;
                                  _isFlipped = false;
                                })
                            : null,
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E).withOpacity(0.1),
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _toggleDifficult(card['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: card['isDifficult'] == true
                              ? Colors.amber : Colors.grey.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(
                          card['isDifficult'] == true
                              ? Icons.star_rounded : Icons.star_border_rounded,
                          color: card['isDifficult'] == true
                              ? Colors.white : Colors.grey,
                        ),
                        label: Text(
                          card['isDifficult'] == true ? 'Difficult' : 'Mark Hard',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: card['isDifficult'] == true
                                  ? Colors.white : Colors.grey),
                        ),
                      ),
                      IconButton(
                        onPressed: _currentIndex < _flashcards.length - 1
                            ? () => setState(() {
                                  _currentIndex++;
                                  _isFlipped = false;
                                })
                            : null,
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E).withOpacity(0.1),
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                  if (_currentIndex == _flashcards.length - 1) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => setState(() {
                          _isReviewMode = false;
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Finish Review 🎉',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
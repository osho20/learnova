import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../../core/services/storage_service.dart';
class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _flashcards = [];
  bool _isReviewMode = false;
  int _currentIndex = 0;
  bool _isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
    
  }
void _loadFlashcards() {
  setState(() {
    _flashcards = StorageService.instance.getFlashcards();
  });
}
  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      _flipController.reset();
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      _flipController.reset();
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }
void _addFlashcard(String question, String answer) {
  final card = {
    'id': const Uuid().v4(),
    'question': question,
    'answer': answer,
    'isDifficult': false,
    'createdAt': DateTime.now().toIso8601String(),
  };
  StorageService.instance.saveFlashcard(card);
  setState(() => _flashcards.add(card));
}
void _deleteFlashcard(String id) {
  StorageService.instance.deleteFlashcard(id);
  setState(() => _flashcards.removeWhere((f) => f['id'] == id));
}

 void _toggleDifficult(String id) {
  setState(() {
    final index = _flashcards.indexWhere((f) => f['id'] == id);
    if (index != -1) {
      _flashcards[index] = {
        ..._flashcards[index],
        'isDifficult': !(_flashcards[index]['isDifficult'] as bool),
      };
      StorageService.instance.updateFlashcard(_flashcards[index]);
    }
  });
}
  void _startReview({bool difficultOnly = false}) {
    List<Map<String, dynamic>> cards = difficultOnly
        ? _flashcards.where((f) => f['isDifficult'] == true).toList()
        : List<Map<String, dynamic>>.from(_flashcards);
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No cards to review!', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF1A237E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    cards.shuffle(Random());
    _flipController.reset();
    setState(() {
      _flashcards = cards;
      _isReviewMode = true;
      _currentIndex = 0;
      _isFlipped = false;
    });
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A237E))),
            const SizedBox(height: 8),
            Text('Add a question and answer',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFF1A237E).withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('FRONT',
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: questionController,
                    maxLines: 3,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Question...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00695C).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFF00695C).withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00695C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('BACK',
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: answerController,
                    maxLines: 3,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Answer...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                  ),
                ],
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

    if (_isReviewMode) return _buildReviewMode(isDark);

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
                        Text('Flashcards',
                            style: GoogleFonts.poppins(fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text('${_flashcards.length} cards • Long press to delete',
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
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1A237E).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_circle_rounded,
                                  color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              Text('Review All',
                                  style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
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
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Colors.red.withOpacity(0.3), width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Colors.red, size: 24),
                              const SizedBox(width: 8),
                              Text('Hard Cards',
                                  style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
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
                        Icon(Icons.style_rounded,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No flashcards yet',
                            style: GoogleFonts.poppins(fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey)),
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
                        return GestureDetector(
                          onLongPress: () => _deleteFlashcard(card['id']),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1A1A2E) : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A237E)
                                        .withOpacity(0.05),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(18)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1A237E),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text('Q',
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white)),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(card['question'],
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _toggleDifficult(card['id']),
                                        icon: Icon(
                                          card['isDifficult'] == true
                                              ? Icons.star_rounded
                                              : Icons.star_border_rounded,
                                          color: card['isDifficult'] == true
                                              ? Colors.amber : Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00695C),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text('A',
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white)),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(card['answer'],
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey[600]),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: (index * 80).ms)
                              .slideX(begin: -0.1, end: 0),
                        );
                      },
                      childCount: _flashcards.length,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 220)),
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
      backgroundColor:
          isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () {
            _flipController.reset();
            setState(() {
              _isReviewMode = false;
              _isFlipped = false;
              _currentIndex = 0;
            });
          },
        ),
        title: Text('Review Mode',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600,
                color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${_flashcards.length}',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
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
            valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1A237E)),
            minHeight: 4,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Flip hint
                  AnimatedOpacity(
                    opacity: _isFlipped ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_rounded,
                              size: 16, color: Color(0xFF1A237E)),
                          const SizedBox(width: 6),
                          Text('Tap card to reveal answer',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF1A237E))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 3D Flip Card
                  Expanded(
                    child: GestureDetector(
                      onTap: _flipCard,
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          final angle = _flipAnimation.value * pi;
                          final showFront = angle < pi / 2;
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            alignment: Alignment.center,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: showFront
                                      ? [
                                          const Color(0xFF1A237E),
                                          const Color(0xFF3949AB),
                                        ]
                                      : [
                                          const Color(0xFF00695C),
                                          const Color(0xFF00897B),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: (showFront
                                        ? const Color(0xFF1A237E)
                                        : const Color(0xFF00695C))
                                        .withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Transform(
                                    transform: Matrix4.identity()
                                      ..rotateY(showFront ? 0 : pi),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            showFront
                                                ? 'QUESTION'
                                                : 'ANSWER',
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white70,
                                                letterSpacing: 1.5),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          showFront
                                              ? card['question']
                                              : card['answer'],
                                          style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              height: 1.5),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _prevCard,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _currentIndex > 0
                                ? const Color(0xFF1A237E).withOpacity(0.1)
                                : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: _currentIndex > 0
                                ? const Color(0xFF1A237E)
                                : Colors.grey,
                            size: 22,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleDifficult(card['id']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: card['isDifficult'] == true
                                ? Colors.amber.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: card['isDifficult'] == true
                                  ? Colors.amber
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                card['isDifficult'] == true
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: card['isDifficult'] == true
                                    ? Colors.amber
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                card['isDifficult'] == true
                                    ? 'Hard'
                                    : 'Mark Hard',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: card['isDifficult'] == true
                                        ? Colors.amber
                                        : Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _nextCard,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _currentIndex < _flashcards.length - 1
                                ? const Color(0xFF1A237E).withOpacity(0.1)
                                : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: _currentIndex < _flashcards.length - 1
                                ? const Color(0xFF1A237E)
                                : Colors.grey,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_currentIndex == _flashcards.length - 1) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _flipController.reset();
                          setState(() {
                            _isReviewMode = false;
                            _isFlipped = false;
                            _currentIndex = 0;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('🎉 Finish Review!',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

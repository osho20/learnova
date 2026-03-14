import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int _workMinutes = 25;
  static const int _shortBreak = 5;
  static const int _longBreak = 15;

  int _seconds = _workMinutes * 60;
  bool _isRunning = false;
  bool _isWork = true;
  int _completedSessions = 0;
  Timer? _timer;
  String _currentTask = '';

  final List<String> _sessionHistory = [];

  void _startStop() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_seconds > 0) {
          setState(() => _seconds--);
        } else {
          _onTimerComplete();
        }
      });
    }
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_isWork) {
        _completedSessions++;
        _sessionHistory.insert(0,
            '✅ Work session completed${_currentTask.isNotEmpty ? ' - $_currentTask' : ''}');
        if (_completedSessions % 4 == 0) {
          _seconds = _longBreak * 60;
          _isWork = false;
          _showCompletionDialog('Long Break! 🎉',
              'Amazing! Take a ${_longBreak}-minute break!');
        } else {
          _seconds = _shortBreak * 60;
          _isWork = false;
          _showCompletionDialog(
              'Short Break! ☕', 'Take a ${_shortBreak}-minute break!');
        }
      } else {
        _seconds = _workMinutes * 60;
        _isWork = true;
        _showCompletionDialog('Back to Work! 💪', 'Break over. Let\'s focus!');
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isWork = true;
      _seconds = _workMinutes * 60;
    });
  }

  void _showCompletionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(message,
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startStop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Start',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String get _timeString {
    final minutes = _seconds ~/ 60;
    final secs = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final total = _isWork
        ? _workMinutes * 60
        : (_completedSessions % 4 == 0 ? _longBreak : _shortBreak) * 60;
    return 1 - (_seconds / total);
  }

  Color get _timerColor =>
      _isWork ? const Color(0xFF1A237E) : const Color(0xFF00695C);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: _timerColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_timerColor, _timerColor.withOpacity(0.7)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Pomodoro Timer',
                            style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text(
                            _isWork
                                ? '🍅 Focus Time'
                                : '☕ Break Time',
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
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Timer circle
                  Center(
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 260,
                            height: 260,
                            child: CircularProgressIndicator(
                              value: _progress,
                              strokeWidth: 12,
                              backgroundColor: _timerColor.withOpacity(0.1),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(_timerColor),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _timeString,
                                style: GoogleFonts.poppins(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w700,
                                  color: _timerColor,
                                ),
                              ),
                              Text(
                                _isWork ? 'Focus' : 'Break',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(),
                  const SizedBox(height: 32),
                  // Task input
                  TextField(
                    onChanged: (v) => setState(() => _currentTask = v),
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'What are you working on?',
                      hintStyle:
                          GoogleFonts.poppins(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.task_alt_rounded,
                          color: _timerColor),
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF1A1A2E) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _startStop,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _timerColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _timerColor.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _onTimerComplete,
                        icon: const Icon(Icons.skip_next_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Sessions completed
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A1A2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSessionStat('🍅', '$_completedSessions',
                            'Sessions'),
                        Container(
                            width: 1, height: 40, color: Colors.grey[200]),
                        _buildSessionStat('⏱️',
                            '${(_completedSessions * 25)} min', 'Focused'),
                        Container(
                            width: 1, height: 40, color: Colors.grey[200]),
                        _buildSessionStat('🔥',
                            '${(_completedSessions * 25 / 60).toStringAsFixed(1)}h',
                            'Total'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Session modes
                  Row(
                    children: [
                      _buildModeButton('25:00', 'Focus', true),
                      const SizedBox(width: 8),
                      _buildModeButton('5:00', 'Short', false),
                      const SizedBox(width: 8),
                      _buildModeButton('15:00', 'Long', false),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // History
                  if (_sessionHistory.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Session History',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A237E))),
                    ),
                    const SizedBox(height: 12),
                    ..._sessionHistory.take(5).map((session) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A1A2E) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(session,
                              style: GoogleFonts.poppins(fontSize: 13)),
                        )),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: _timerColor)),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildModeButton(String time, String label, bool isWork) {
    final isSelected = this._isWork == isWork;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _timer?.cancel();
          setState(() {
            _isRunning = false;
            this._isWork = isWork;
            if (label == 'Focus') _seconds = 25 * 60;
            if (label == 'Short') _seconds = 5 * 60;
            if (label == 'Long') _seconds = 15 * 60;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _timerColor : _timerColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(time,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : _timerColor)),
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white70 : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
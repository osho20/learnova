import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  // Box names
  static const String subjectsBox = 'subjects';
  static const String notesBox = 'notes';
  static const String flashcardsBox = 'flashcards';
  static const String attendanceBox = 'attendance';
  static const String timetableBox = 'timetable';
  static const String examsBox = 'exams';
  static const String gradesBox = 'grades';

  Future<void> init() async {
    await Hive.openBox(subjectsBox);
    await Hive.openBox(notesBox);
    await Hive.openBox(flashcardsBox);
    await Hive.openBox(attendanceBox);
    await Hive.openBox(timetableBox);
    await Hive.openBox(examsBox);
    await Hive.openBox(gradesBox);
  }

  // ─── SUBJECTS ────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> getSubjects() {
    final box = Hive.box(subjectsBox);
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> saveSubject(Map<String, dynamic> subject) async {
    final box = Hive.box(subjectsBox);
    await box.put(subject['id'], subject);
  }

  Future<void> deleteSubject(String id) async {
    final box = Hive.box(subjectsBox);
    await box.delete(id);
  }

  // ─── NOTES ───────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> getNotes({String? subjectId}) {
    final box = Hive.box(notesBox);
    final all = box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    if (subjectId != null) {
      return all.where((n) => n['subjectId'] == subjectId).toList();
    }
    return all;
  }

  Future<void> saveNote(Map<String, dynamic> note) async {
    final box = Hive.box(notesBox);
    await box.put(note['id'], note);
  }

  Future<void> deleteNote(String id) async {
    final box = Hive.box(notesBox);
    await box.delete(id);
  }

  // ─── FLASHCARDS ──────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> getFlashcards() {
    final box = Hive.box(flashcardsBox);
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> saveFlashcard(Map<String, dynamic> card) async {
    final box = Hive.box(flashcardsBox);
    await box.put(card['id'], card);
  }

  Future<void> deleteFlashcard(String id) async {
    final box = Hive.box(flashcardsBox);
    await box.delete(id);
  }

  Future<void> updateFlashcard(Map<String, dynamic> card) async {
    final box = Hive.box(flashcardsBox);
    await box.put(card['id'], card);
  }

  // ─── ATTENDANCE ──────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> getAttendance() {
    final box = Hive.box(attendanceBox);
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> saveAttendance(Map<String, dynamic> subject) async {
    final box = Hive.box(attendanceBox);
    await box.put(subject['id'], subject);
  }

  Future<void> deleteAttendance(String id) async {
    final box = Hive.box(attendanceBox);
    await box.delete(id);
  }

  // ─── TIMETABLE ───────────────────────────────────────────────────────────────

  Map<int, List<Map<String, dynamic>>> getTimetable() {
    final box = Hive.box(timetableBox);
    final Map<int, List<Map<String, dynamic>>> result = {
      0: [], 1: [], 2: [], 3: [], 4: [], 5: [],
    };
    for (int day = 0; day < 6; day++) {
      final raw = box.get('day_$day');
      if (raw != null) {
        result[day] = (raw as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    }
    return result;
  }

  Future<void> saveTimetableDay(
      int day, List<Map<String, dynamic>> classes) async {
    final box = Hive.box(timetableBox);
    await box.put('day_$day', classes);
  }

  // ─── EXAMS ───────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> getExams() {
    final box = Hive.box(examsBox);
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> saveExam(Map<String, dynamic> exam) async {
    final box = Hive.box(examsBox);
    await box.put(exam['id'], exam);
  }

  Future<void> deleteExam(String id) async {
    final box = Hive.box(examsBox);
    await box.delete(id);
  }

  // ─── GRADES ──────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> getGrades() {
    final box = Hive.box(gradesBox);
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> saveGrade(Map<String, dynamic> subject) async {
    final box = Hive.box(gradesBox);
    await box.put(subject['id'], subject);
  }

  Future<void> deleteGrade(String id) async {
    final box = Hive.box(gradesBox);
    await box.delete(id);
  }
}
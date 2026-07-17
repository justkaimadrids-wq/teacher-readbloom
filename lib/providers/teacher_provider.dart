import 'package:flutter/material.dart';
import '../models/teacher_models.dart';

class TeacherProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  final String _teacherName = 'Ana Mirandilla';
  final String _school = 'SPES - Teacher';
  final String _email = 'teacherana@readbloom.it.com';

  final List<ClassStats> _classes = [
    ClassStats(
      grade: 'Grade 4',
      totalStudents: 28,
      completionRate: 0.78,
      totalLessons: 145,
    ),
    ClassStats(
      grade: 'Grade 5',
      totalStudents: 28,
      completionRate: 0.78,
      totalLessons: 145,
    ),
    ClassStats(
      grade: 'Grade 6',
      totalStudents: 26,
      completionRate: 0.85,
      totalLessons: 138,
    ),
  ];

  final List<StudentProgress> _students = [
    StudentProgress(
      id: 'stud1',
      name: 'Kira Jhonson',
      readingAccuracy: 0.82,
      vocabularyLevel: 0.85,
      progressCurrent: 12,
      progressTotal: 20,
      status: 'GROWING',
      badges: ['Growing Reader', 'Try Hard', 'Keep Going'],
      grade: 'Grade 4',
      section: 'Section A',
    ),
    StudentProgress(
      id: 'stud2',
      name: 'Akame Tori',
      readingAccuracy: 0.82,
      vocabularyLevel: 0.92,
      progressCurrent: 18,
      progressTotal: 20,
      status: 'OUTSTANDING',
      badges: ['Super Reader', 'Star Reader', 'Book Boss'],
      grade: 'Grade 5',
      section: 'Section B',
    ),
    StudentProgress(
      id: 'stud3',
      name: 'Asta Orfai',
      readingAccuracy: 0.82,
      vocabularyLevel: 0.72,
      progressCurrent: 8,
      progressTotal: 20,
      status: 'EXPLORER',
      badges: ['Try Hard', 'Keep Going'],
      grade: 'Grade 6',
      section: 'Section A',
    ),
    StudentProgress(
      id: 'stud4',
      name: 'Kei Adamson',
      readingAccuracy: 0.60,
      vocabularyLevel: 0.54,
      progressCurrent: 6,
      progressTotal: 20,
      status: 'NON-READER',
      badges: ['Try Hard'],
      grade: 'Grade 4',
      section: 'Section B',
    ),
  ];

  final List<StudentActivity> _activities = [
    StudentActivity(
      id: 'a1',
      studentName: 'Kira Jhonson',
      activityTitle: 'Completed reading: The Brave Little Squirrel',
      score: 0.90,
      date: '2026-03-10',
    ),
    StudentActivity(
      id: 'a2',
      studentName: 'Akame Tori',
      activityTitle: 'Completed reading: Space Exploration',
      score: 0.95,
      date: '2026-02-09',
    ),
    StudentActivity(
      id: 'a3',
      studentName: 'Asta Orfai',
      activityTitle: 'Completed vocabulary: Nature Words',
      score: 0.80,
      date: '2026-03-01',
    ),
    StudentActivity(
      id: 'a4',
      studentName: 'Kei Adamson',
      activityTitle: 'Completed vocabulary: Action Verbs',
      score: 0.66,
      date: '2026-02-01',
    ),
  ];

  final Map<String, EvaluationMetrics> _evaluations = {
    'stud1': EvaluationMetrics(
      omissions: 2,
      repetitions: 3,
      selfCorrections: 4,
      mispronunciations: 5,
      feedback:
          "Well done, Read more books and focus on the words that your not familiar with",
    ),
  };

  StudentProgress? _selectedStudentForEvaluation;

  bool get isLoggedIn => _isLoggedIn;
  String get teacherName => _teacherName;
  String get school => _school;
  String get email => _email;
  List<ClassStats> get classes => _classes;
  List<StudentProgress> get students => _students;
  List<StudentActivity> get activities => _activities;
  StudentProgress? get selectedStudentForEvaluation =>
      _selectedStudentForEvaluation ?? _students[0];

  void selectStudentForEvaluation(StudentProgress student) {
    _selectedStudentForEvaluation = student;
    notifyListeners();
  }

  EvaluationMetrics getEvaluationForStudent(String studentId) {
    return _evaluations[studentId] ??
        EvaluationMetrics(
          omissions: 0,
          repetitions: 0,
          selfCorrections: 0,
          mispronunciations: 0,
          feedback: '',
        );
  }

  void updateEvaluation(
    String studentId,
    int o,
    int r,
    int s,
    int m,
    String f,
  ) {
    _evaluations[studentId] = EvaluationMetrics(
      omissions: o,
      repetitions: r,
      selfCorrections: s,
      mispronunciations: m,
      feedback: f,
    );
    notifyListeners();
  }

  void addBadgeToStudent(String studentId, String badge) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final currentStudent = _students[index];
      final updatedBadges = List<String>.from(currentStudent.badges)..add(badge);
      _students[index] = StudentProgress(
        id: currentStudent.id,
        name: currentStudent.name,
        readingAccuracy: currentStudent.readingAccuracy,
        vocabularyLevel: currentStudent.vocabularyLevel,
        progressCurrent: currentStudent.progressCurrent,
        progressTotal: currentStudent.progressTotal,
        status: currentStudent.status,
        badges: updatedBadges,
        grade: currentStudent.grade,
        section: currentStudent.section,
      );
      notifyListeners();
    }
  }

  final List<Book> _books = [
    Book(
      id: 'book1',
      title: 'The Brave Little Squirrel',
      grade: 'Grade 4',
      section: 'Section A',
      content: 'Once upon a time, in a lush green forest, lived a little squirrel named Sammy. Sammy was smaller than other squirrels, but he was very brave. One day, a huge storm hit the forest...',
    ),
    Book(
      id: 'book2',
      title: 'Space Exploration',
      grade: 'Grade 5',
      section: 'Section B',
      content: 'Human beings have always looked up at the stars and wondered. Space exploration began in the mid-20th century. Today, robotic rovers explore Mars, and astronomers look for distant habitable planets...',
    ),
    Book(
      id: 'book3',
      title: 'The Whispering Trees',
      grade: 'Grade 5',
      section: 'Section A',
      content: 'Deep in the valley, the old trees stood tall. People said that if you listened closely on a quiet night, you could hear the trees whispering ancient secrets of the earth to each other...',
    ),
    Book(
      id: 'book4',
      title: 'Nature Trails',
      grade: 'Grade 6',
      section: 'Section A',
      content: 'Hiking through nature trails is a wonderful way to connect with the environment. Along the path, you can observe diverse ecosystems, from tiny insects on decaying logs to majestic birds nesting in the canopy...',
    ),
  ];

  List<Book> get books => _books;

  void addBook(String title, String grade, String section, String content) {
    final newBook = Book(
      id: 'book_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      grade: grade,
      section: section,
      content: content,
    );
    _books.add(newBook);
    notifyListeners();
  }

  void login(String email, String password) {
    if (email.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  void logout() {
    _isLoggedIn = false;
    _selectedStudentForEvaluation = null;
    notifyListeners();
  }
}

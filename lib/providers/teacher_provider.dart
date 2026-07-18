import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/teacher_models.dart';
import '../repositories/teacher_repository.dart';
import '../services/auth_service.dart';

class TeacherProvider extends ChangeNotifier {
  final TeacherRepository _teacherRepository;
  final AuthService _authService;
  late TeacherAccount _account;
  late final List<ClassStats> _classes;
  late final List<StudentActivity> _activities;
  late final Map<String, EvaluationMetrics> _evaluations;
  late List<Book> _books;
  late List<StudentProgress> _students;
  List<String> _assignedSections = const [];

  bool _isLoggedIn = false;
  bool _isAuthLoading = true;
  bool _isUploadingAvatar = false;
  bool _isBooksLoading = false;
  String? _booksError;
  StudentProgress? _selectedStudentForEvaluation;

  TeacherProvider({
    TeacherRepository? teacherRepository,
    AuthService? authService,
  }) : _teacherRepository = teacherRepository ?? SupabaseTeacherRepository(),
       _authService = authService ?? SupabaseRoleAuthService(AppRole.teacher) {
    _account = _teacherRepository.getAccount();
    _classes = _teacherRepository.getClasses();
    _students = List<StudentProgress>.from(_teacherRepository.getStudents());
    _activities = _teacherRepository.getActivities();
    _evaluations = _teacherRepository.getEvaluations();
    _books = List<Book>.from(_teacherRepository.getBooks());
    restoreSession();
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isAuthLoading => _isAuthLoading;
  String get teacherName => _account.name;
  String get school => _account.school;
  String get email => _account.email;
  String get avatarUrl => _account.avatarUrl;
  List<String> get assignedSections => _assignedSections;
  bool get isUploadingAvatar => _isUploadingAvatar;
  List<ClassStats> get classes => _classes;
  List<StudentProgress> get students => _students;
  List<StudentActivity> get activities => _activities;
  StudentProgress? get selectedStudentForEvaluation =>
      _selectedStudentForEvaluation ??
      (_students.isNotEmpty ? _students[0] : null);
  List<Book> get books => _books;
  bool get isBooksLoading => _isBooksLoading;
  String? get booksError => _booksError;

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
    if (index == -1 || badge.trim().isEmpty) return;

    final currentStudent = _students[index];
    if (currentStudent.badges.contains(badge)) return;

    final updatedBadges = List<String>.from(currentStudent.badges)..add(badge);
    _students = List<StudentProgress>.from(_students)
      ..[index] = StudentProgress(
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

  Future<String?> addBook({
    required String title,
    required String grade,
    required String section,
    required String content,
    required List<BookQuestionInput> questions,
  }) async {
    final cleanedQuestions = <BookQuestionInput>[];
    for (final question in questions) {
      final cleanedQuestion = _cleanQuestion(question);
      if (cleanedQuestion != null) cleanedQuestions.add(cleanedQuestion);
    }

    if (title.trim().isEmpty ||
        content.trim().isEmpty ||
        cleanedQuestions.isEmpty) {
      return 'Please complete the book and quiz fields.';
    }

    _isBooksLoading = true;
    _booksError = null;
    notifyListeners();
    try {
      final newBook = await _teacherRepository.addBook(
        title: title.trim(),
        grade: grade.trim(),
        section: section.trim(),
        content: content.trim(),
        questions: cleanedQuestions,
      );
      _books = List<Book>.from(_books)..add(newBook);
      return null;
    } catch (_) {
      _booksError = 'Unable to save this book right now.';
      return _booksError;
    } finally {
      _isBooksLoading = false;
      notifyListeners();
    }
  }

  BookQuestionInput? _cleanQuestion(BookQuestionInput question) {
    final questionText = question.questionText.trim();
    final trimmedOptions = question.options
        .map((option) => option.trim())
        .toList();
    final selectedAnswer =
        question.correctOptionIndex >= 0 &&
            question.correctOptionIndex < trimmedOptions.length
        ? trimmedOptions[question.correctOptionIndex]
        : '';
    final cleanedOptions = trimmedOptions
        .where((option) => option.isNotEmpty)
        .toList();
    final normalizedCorrectOptionIndex = trimmedOptions
        .take(question.correctOptionIndex)
        .where((option) => option.isNotEmpty)
        .length;

    if (questionText.isEmpty ||
        selectedAnswer.isEmpty ||
        cleanedOptions.length < 2 ||
        normalizedCorrectOptionIndex >= cleanedOptions.length) {
      return null;
    }

    return BookQuestionInput(
      questionText: questionText,
      options: cleanedOptions,
      correctOptionIndex: normalizedCorrectOptionIndex,
    );
  }

  Future<void> restoreSession() async {
    _isAuthLoading = true;
    notifyListeners();
    _isLoggedIn = await _authService.hasValidSession();
    if (_isLoggedIn) {
      try {
        await _loadAccountState();
      } catch (_) {
        await _authService.signOut();
        _isLoggedIn = false;
      }
    }
    _isAuthLoading = false;
    notifyListeners();
  }

  Future<AuthResult> login(String email, String password) async {
    final result = await _authService.signIn(
      email: email.trim(),
      password: password,
    );
    if (result.success) {
      try {
        await _loadAccountState();
      } catch (_) {
        await _authService.signOut();
        return const AuthResult.failure(
          'Unable to load this teacher profile right now.',
        );
      }
      _isLoggedIn = true;
      notifyListeners();
    }
    return result;
  }

  Future<void> logout() async {
    await _authService.signOut();
    _isLoggedIn = false;
    _selectedStudentForEvaluation = null;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _authService.sendPasswordResetEmail(email);
  }

  Future<AuthResult> updatePassword(String password) {
    return _authService.updatePassword(password);
  }

  Future<String?> updateProfilePicture() async {
    if (_isUploadingAvatar) return null;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      allowMultiple: false,
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) return null;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      return 'Unable to read the selected image.';
    }

    _isUploadingAvatar = true;
    notifyListeners();
    try {
      _account = await _teacherRepository.updateCurrentProfileAvatar(
        bytes: bytes,
        fileName: file.name,
      );
      return null;
    } catch (_) {
      return 'Unable to update profile picture right now.';
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }

  Future<void> _loadAccountState() async {
    _account = await _teacherRepository.getCurrentAccount();
    _assignedSections = await _teacherRepository.getAssignedSections();
    _books = await _teacherRepository.getCurrentBooks();
  }
}

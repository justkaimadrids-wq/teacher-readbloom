import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/teacher_models.dart';
import '../repositories/teacher_repository.dart';
import '../services/auth_service.dart';

class TeacherProvider extends ChangeNotifier {
  final TeacherRepository _teacherRepository;
  final AuthService _authService;
  late TeacherAccount _account;
  late List<ClassStats> _classes;
  late List<StudentActivity> _activities;
  late Map<String, EvaluationMetrics> _evaluations;
  late List<Book> _books;
  late List<StudentProgress> _students;
  late Map<String, List<ReadingSubmissionReview>> _readingReviewsByStudent;
  List<String> _assignedSections = const [];

  bool _isLoggedIn = false;
  bool _isAuthLoading = true;
  bool _isUploadingAvatar = false;
  bool _isBooksLoading = false;
  bool _isTeacherDataLoading = false;
  bool _isSavingFeedback = false;
  bool _isUpdatingSkillLevel = false;
  String? _booksError;
  String? _teacherDataError;
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
    _readingReviewsByStudent = const {};
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
  bool get isTeacherDataLoading => _isTeacherDataLoading;
  bool get isSavingFeedback => _isSavingFeedback;
  bool get isUpdatingSkillLevel => _isUpdatingSkillLevel;
  String? get teacherDataError => _teacherDataError;
  StudentProgress? get selectedStudentForEvaluation =>
      _selectedStudentForEvaluation ??
      (_students.isNotEmpty ? _students[0] : null);
  List<Book> get books => _books;
  bool get isBooksLoading => _isBooksLoading;
  String? get booksError => _booksError;
  List<String> get availableGrades {
    final grades = _students.map((student) => student.grade).toSet().toList()
      ..sort();
    return ['All Grades', ...grades.where((grade) => grade.isNotEmpty)];
  }

  List<String> get availableSections {
    final sections =
        _students.map((student) => student.section).toSet().toList()..sort();
    return ['All Sections', ...sections.where((section) => section.isNotEmpty)];
  }

  List<ReadingSubmissionReview> getReadingReviewsForStudent(String studentId) {
    return List.unmodifiable(_readingReviewsByStudent[studentId] ?? const []);
  }

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

  Future<String?> addBadgeToStudent(String studentId, String badge) async {
    final index = _students.indexWhere((s) => s.id == studentId);
    final cleanedBadge = badge.trim();
    if (index == -1 || cleanedBadge.isEmpty) return null;

    final currentStudent = _students[index];
    if (currentStudent.badges.contains(cleanedBadge)) return null;

    try {
      await _teacherRepository.awardBadgeToStudent(
        studentId: studentId,
        badgeName: cleanedBadge,
      );
    } catch (_) {
      return 'Unable to award badge right now.';
    }

    final updatedBadges = List<String>.from(currentStudent.badges)
      ..add(cleanedBadge);
    _students = List<StudentProgress>.from(_students)
      ..[index] = _copyStudent(currentStudent, badges: updatedBadges);
    notifyListeners();
    return null;
  }

  Future<String?> updateStudentSkillLevels({
    required String studentId,
    required int readingLevel,
    required int vocabularyLevel,
    required int wordMasterLevel,
    required int comprehensionLevel,
  }) async {
    final index = _students.indexWhere((student) => student.id == studentId);
    if (index == -1) return null;

    final safeReadingLevel = readingLevel < 1 ? 1 : readingLevel;
    final safeVocabularyLevel = vocabularyLevel < 1 ? 1 : vocabularyLevel;
    final safeWordMasterLevel = wordMasterLevel < 1 ? 1 : wordMasterLevel;
    final safeComprehensionLevel = comprehensionLevel < 1
        ? 1
        : comprehensionLevel;

    try {
      await _teacherRepository.updateStudentSkillLevels(
        studentId: studentId,
        readingLevel: safeReadingLevel,
        vocabularyLevel: safeVocabularyLevel,
        wordMasterLevel: safeWordMasterLevel,
        comprehensionLevel: safeComprehensionLevel,
      );
    } catch (_) {
      return 'Unable to update skill levels right now.';
    }

    final student = _students[index];
    _students = List<StudentProgress>.from(_students)
      ..[index] = _copyStudent(
        student,
        readingLevel: safeReadingLevel,
        vocabularySkillLevel: safeVocabularyLevel,
        wordMasterLevel: safeWordMasterLevel,
        comprehensionLevel: safeComprehensionLevel,
      );
    notifyListeners();
    return null;
  }

  Future<String?> sendFeedbackForSubmission({
    required ReadingSubmissionReview submission,
    required String studentId,
    required String feedback,
  }) async {
    final cleanedFeedback = feedback.trim();
    if (cleanedFeedback.isEmpty) return 'Please enter feedback first.';

    _isSavingFeedback = true;
    notifyListeners();
    try {
      await _teacherRepository.sendFeedback(
        submission: submission,
        studentId: studentId,
        feedback: cleanedFeedback,
      );
      updateEvaluation(studentId, 0, 0, 0, 0, cleanedFeedback);
      return null;
    } catch (_) {
      return 'Unable to send feedback right now.';
    } finally {
      _isSavingFeedback = false;
      notifyListeners();
    }
  }

  Future<String?> updateStudentSkillLevel({
    required String studentId,
    required String skillLevel,
  }) async {
    final cleanedSkillLevel = skillLevel.trim();
    if (cleanedSkillLevel.isEmpty) return 'Please enter a skill level.';

    _isUpdatingSkillLevel = true;
    notifyListeners();
    try {
      await _teacherRepository.updateStudentSkillLevel(
        studentId: studentId,
        skillLevel: cleanedSkillLevel,
      );
      _students = _students.map((student) {
        if (student.id != studentId) return student;
        return _copyStudent(student, skillLevel: cleanedSkillLevel);
      }).toList();
      return null;
    } catch (_) {
      return 'Unable to update skill level right now.';
    } finally {
      _isUpdatingSkillLevel = false;
      notifyListeners();
    }
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
    _isTeacherDataLoading = true;
    _teacherDataError = null;
    notifyListeners();
    try {
      _assignedSections = await _teacherRepository.getAssignedSections();
      _books = await _teacherRepository.getCurrentBooks();
      _readingReviewsByStudent = await _teacherRepository
          .getCurrentReadingReviews();
      _students = await _teacherRepository.getCurrentStudents();
      _classes = await _teacherRepository.getCurrentClasses();
      _activities = await _teacherRepository.getCurrentActivities();
      if (_selectedStudentForEvaluation != null &&
          !_students.any(
            (student) => student.id == _selectedStudentForEvaluation!.id,
          )) {
        _selectedStudentForEvaluation = null;
      }
    } catch (error) {
      _teacherDataError =
          'Unable to load teacher dashboard data right now. ${error.toString()}';
    } finally {
      _isTeacherDataLoading = false;
      notifyListeners();
    }
  }

  StudentProgress _copyStudent(
    StudentProgress student, {
    List<String>? badges,
    String? skillLevel,
    int? readingLevel,
    int? vocabularySkillLevel,
    int? wordMasterLevel,
    int? comprehensionLevel,
  }) {
    return StudentProgress(
      id: student.id,
      name: student.name,
      readingAccuracy: student.readingAccuracy,
      vocabularyLevel: student.vocabularyLevel,
      progressCurrent: student.progressCurrent,
      progressTotal: student.progressTotal,
      status: student.status,
      badges: badges ?? student.badges,
      grade: student.grade,
      section: student.section,
      avatarUrl: student.avatarUrl,
      skillLevel: skillLevel ?? student.skillLevel,
      readingLevel: readingLevel ?? student.readingLevel,
      vocabularySkillLevel:
          vocabularySkillLevel ?? student.vocabularySkillLevel,
      wordMasterLevel: wordMasterLevel ?? student.wordMasterLevel,
      comprehensionLevel: comprehensionLevel ?? student.comprehensionLevel,
    );
  }
}

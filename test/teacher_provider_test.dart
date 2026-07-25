import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_readbloom/models/teacher_models.dart';
import 'package:teacher_readbloom/providers/teacher_provider.dart';
import 'package:teacher_readbloom/repositories/teacher_repository.dart';
import 'package:teacher_readbloom/services/auth_service.dart';

class ResetPasswordTeacherAuthService implements AuthService {
  String? updatedPassword;
  bool signedOut = false;

  @override
  AppRole get requiredRole => AppRole.teacher;

  @override
  Future<bool> hasValidSession() async => false;

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    return const AuthResult.success();
  }

  @override
  Future<void> signOut() async {
    signedOut = true;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<AuthResult> updatePassword(String password) async {
    updatedPassword = password;
    return const AuthResult.success();
  }
}

class BadgeFixtureTeacherRepository extends MockTeacherRepository {
  final List<StudentProgress> _students = [
    StudentProgress(
      id: 'student-1',
      name: 'Student One',
      readingAccuracy: 0,
      vocabularyLevel: 0,
      progressCurrent: 0,
      progressTotal: 0,
      status: '',
      badges: const ['Existing Badge'],
      grade: 'Grade 4',
      section: 'Section A',
    ),
  ];

  @override
  List<StudentProgress> getStudents() => List.unmodifiable(_students);

  @override
  Future<List<StudentProgress>> getCurrentStudents() async => getStudents();
}

void main() {
  test('addBook appends a valid book through repository boundary', () async {
    final provider = TeacherProvider();
    final initialCount = provider.books.length;

    final error = await provider.addBook(
      title: 'New Passage',
      grade: 'Grade 4',
      section: 'Section A',
      content: 'Passage text',
      questions: const [
        BookQuestionInput(
          questionText: 'What is the title?',
          options: ['New Passage', 'Old Passage'],
          correctOptionIndex: 0,
        ),
        BookQuestionInput(
          questionText: 'What kind of text is this?',
          options: ['Passage', 'Poem'],
          correctOptionIndex: 0,
        ),
      ],
    );

    expect(error, isNull);
    expect(provider.books.length, initialCount + 1);
    expect(provider.books.last.title, 'New Passage');
    expect(provider.books.last.questions, hasLength(2));
  });

  test('addBadgeToStudent does not duplicate badges', () async {
    final provider = TeacherProvider(
      teacherRepository: BadgeFixtureTeacherRepository(),
    );
    final student = provider.students.first;
    final initialBadgeCount = student.badges.length;

    await provider.addBadgeToStudent(student.id, student.badges.first);

    expect(provider.students.first.badges.length, initialBadgeCount);
  });

  test('password reset rejects mismatched confirmation', () async {
    final auth = ResetPasswordTeacherAuthService();
    final provider = TeacherProvider(authService: auth);

    final result = await provider.completePasswordReset('new-pass', 'wrong');

    expect(result.success, isFalse);
    expect(result.message, 'Passwords do not match.');
    expect(auth.updatedPassword, isNull);
  });

  test('password reset updates password and signs out', () async {
    final auth = ResetPasswordTeacherAuthService();
    final provider = TeacherProvider(authService: auth);

    final result = await provider.completePasswordReset(
      'new-password',
      'new-password',
    );

    expect(result.success, isTrue);
    expect(auth.updatedPassword, 'new-password');
    expect(auth.signedOut, isTrue);
    expect(provider.isLoggedIn, isFalse);
    expect(provider.isPasswordRecovery, isFalse);
  });
}

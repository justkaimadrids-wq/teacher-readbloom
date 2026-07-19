import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_readbloom/models/teacher_models.dart';
import 'package:teacher_readbloom/providers/teacher_provider.dart';
import 'package:teacher_readbloom/repositories/teacher_repository.dart';

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
}

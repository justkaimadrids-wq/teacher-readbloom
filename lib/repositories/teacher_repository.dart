import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/teacher_models.dart';
import '../services/supabase_service.dart';

class TeacherAccount {
  final String name;
  final String school;
  final String email;
  final String avatarUrl;

  const TeacherAccount({
    required this.name,
    required this.school,
    required this.email,
    this.avatarUrl = '',
  });
}

abstract class TeacherRepository {
  TeacherAccount getAccount();
  Future<TeacherAccount> getCurrentAccount();
  Future<TeacherAccount> updateCurrentProfileAvatar({
    required Uint8List bytes,
    required String fileName,
  });
  Future<List<String>> getAssignedSections();
  List<ClassStats> getClasses();
  List<StudentProgress> getStudents();
  List<StudentActivity> getActivities();
  Map<String, EvaluationMetrics> getEvaluations();
  List<Book> getBooks();
  Future<List<Book>> getCurrentBooks();
  Future<Book> addBook({
    required String title,
    required String grade,
    required String section,
    required String content,
    required List<BookQuestionInput> questions,
  });
}

class MockTeacherRepository implements TeacherRepository {
  final TeacherAccount _account = const TeacherAccount(
    name: 'Ana Mirandilla',
    school: 'SPES - Teacher',
    email: 'teacherana@readbloom.it.com',
  );

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

  final List<Book> _books = [
    Book(
      id: 'book1',
      title: 'The Brave Little Squirrel',
      grade: 'Grade 4',
      section: 'Section A',
      content:
          'Once upon a time, in a lush green forest, lived a little squirrel named Sammy. Sammy was smaller than other squirrels, but he was very brave. One day, a huge storm hit the forest...',
    ),
    Book(
      id: 'book2',
      title: 'Space Exploration',
      grade: 'Grade 5',
      section: 'Section B',
      content:
          'Human beings have always looked up at the stars and wondered. Space exploration began in the mid-20th century. Today, robotic rovers explore Mars, and astronomers look for distant habitable planets...',
    ),
    Book(
      id: 'book3',
      title: 'The Whispering Trees',
      grade: 'Grade 5',
      section: 'Section A',
      content:
          'Deep in the valley, the old trees stood tall. People said that if you listened closely on a quiet night, you could hear the trees whispering ancient secrets of the earth to each other...',
    ),
    Book(
      id: 'book4',
      title: 'Nature Trails',
      grade: 'Grade 6',
      section: 'Section A',
      content:
          'Hiking through nature trails is a wonderful way to connect with the environment. Along the path, you can observe diverse ecosystems, from tiny insects on decaying logs to majestic birds nesting in the canopy...',
    ),
  ];

  @override
  TeacherAccount getAccount() => _account;

  @override
  Future<TeacherAccount> getCurrentAccount() async => _account;

  @override
  Future<TeacherAccount> updateCurrentProfileAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async => _account;

  @override
  Future<List<String>> getAssignedSections() async => const [];

  @override
  List<ClassStats> getClasses() => List.unmodifiable(_classes);

  @override
  List<StudentProgress> getStudents() => List.unmodifiable(_students);

  @override
  List<StudentActivity> getActivities() => List.unmodifiable(_activities);

  @override
  Map<String, EvaluationMetrics> getEvaluations() => Map.of(_evaluations);

  @override
  List<Book> getBooks() => List.unmodifiable(_books);

  @override
  Future<List<Book>> getCurrentBooks() async => getBooks();

  @override
  Future<Book> addBook({
    required String title,
    required String grade,
    required String section,
    required String content,
    required List<BookQuestionInput> questions,
  }) async {
    final newBook = Book(
      id: 'book_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      grade: grade,
      section: section,
      content: content,
      questions: questions
          .asMap()
          .entries
          .map(
            (entry) => BookQuestion(
              id: 'question_${DateTime.now().microsecondsSinceEpoch}_${entry.key}',
              questionText: entry.value.questionText,
              options: entry.value.options,
              correctOptionIndex: entry.value.correctOptionIndex,
            ),
          )
          .toList(),
    );
    _books.add(newBook);
    return newBook;
  }
}

class SupabaseTeacherRepository extends MockTeacherRepository {
  @override
  Future<TeacherAccount> getCurrentAccount() async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return super.getCurrentAccount();

    final base = getAccount();
    final profile = await client
        .from('profiles')
        .select('email,full_name,avatar_url')
        .eq('id', user.id)
        .maybeSingle();
    final teacherProfile = await client
        .from('teacher_profiles')
        .select('school_id')
        .eq('profile_id', user.id)
        .maybeSingle();

    String school = base.school;
    final schoolId = teacherProfile?['school_id'] as String?;
    if (schoolId != null) {
      final schoolRow = await client
          .from('schools')
          .select('name')
          .eq('id', schoolId)
          .maybeSingle();
      school = schoolRow?['name'] as String? ?? school;
    }

    final avatarUrl = await _getSignedAvatarUrl(
      profile?['avatar_url'] as String?,
    );

    return TeacherAccount(
      name: profile?['full_name'] as String? ?? base.name,
      school: school,
      email: profile?['email'] as String? ?? user.email ?? base.email,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<TeacherAccount> updateCurrentProfileAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return super.getCurrentAccount();

    final extension = _extensionFor(fileName);
    final path =
        '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';

    await client.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: _contentTypeFor(extension)),
        );
    await client
        .from('profiles')
        .update({'avatar_url': path})
        .eq('id', user.id);

    return getCurrentAccount();
  }

  @override
  Future<List<String>> getAssignedSections() async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return const [];

    final rows = await client
        .from('teacher_sections')
        .select('sections(grade_level,name)')
        .eq('teacher_id', user.id);

    return rows
        .map<String>((row) {
          final section = row['sections'] as Map<String, dynamic>?;
          if (section == null) return '';
          final grade = section['grade_level'] as String? ?? '';
          final name = section['name'] as String? ?? '';
          return '$grade - $name'.trim();
        })
        .where((label) => label.isNotEmpty)
        .toList();
  }

  @override
  Future<List<Book>> getCurrentBooks() async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return super.getCurrentBooks();

    final rows = await client
        .from('books')
        .select(
          'id,title,grade_level,passage_text,status,sections(name),'
          'book_questions(id,question_text,options,correct_option_index,sort_order)',
        )
        .eq('created_by', user.id)
        .order('grade_level')
        .order('title');

    return rows.map<Book>(_bookFromRow).toList();
  }

  @override
  Future<Book> addBook({
    required String title,
    required String grade,
    required String section,
    required String content,
    required List<BookQuestionInput> questions,
  }) async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      return super.addBook(
        title: title,
        grade: grade,
        section: section,
        content: content,
        questions: questions,
      );
    }

    final teacherSectionRow = await client
        .from('teacher_sections')
        .select('sections!inner(id,grade_level,name)')
        .eq('teacher_id', user.id)
        .eq('sections.grade_level', grade)
        .eq('sections.name', section)
        .maybeSingle();
    final sectionRow = teacherSectionRow?['sections'] as Map<String, dynamic>?;
    final sectionId = sectionRow?['id'] as String?;
    if (sectionId == null) {
      throw StateError('Selected section was not found.');
    }

    final bookRow = await client
        .from('books')
        .insert({
          'created_by': user.id,
          'section_id': sectionId,
          'grade_level': grade,
          'title': title,
          'passage_text': content,
          'status': 'published',
        })
        .select('id,title,grade_level,passage_text,status,sections(name)')
        .single();

    await client
        .from('book_questions')
        .insert(
          questions.asMap().entries.map((entry) {
            final question = entry.value;
            return {
              'book_id': bookRow['id'],
              'question_text': question.questionText,
              'options': question.options,
              'correct_option_index': question.correctOptionIndex,
              'sort_order': entry.key,
            };
          }).toList(),
        );

    return _bookFromRow({
      ...bookRow,
      'book_questions': questions.asMap().entries.map((entry) {
        final question = entry.value;
        return {
          'id': 'new_${entry.key}',
          'question_text': question.questionText,
          'options': question.options,
          'correct_option_index': question.correctOptionIndex,
          'sort_order': entry.key,
        };
      }).toList(),
    });
  }

  Book _bookFromRow(Map<String, dynamic> row) {
    final section = row['sections'] as Map<String, dynamic>?;
    final rawQuestions = row['book_questions'] as List<dynamic>? ?? const [];
    final questionRows =
        rawQuestions
            .map((question) => question as Map<String, dynamic>)
            .toList()
          ..sort((a, b) {
            final aOrder = (a['sort_order'] as num?)?.toInt() ?? 0;
            final bOrder = (b['sort_order'] as num?)?.toInt() ?? 0;
            return aOrder.compareTo(bOrder);
          });
    final questions = questionRows.map<BookQuestion>((questionRow) {
      final rawOptions = questionRow['options'] as List<dynamic>? ?? const [];
      return BookQuestion(
        id: questionRow['id'] as String? ?? '',
        questionText: questionRow['question_text'] as String? ?? '',
        options: rawOptions.map((option) => option.toString()).toList(),
        correctOptionIndex:
            (questionRow['correct_option_index'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    return Book(
      id: row['id'] as String,
      title: row['title'] as String? ?? 'Untitled Book',
      grade: row['grade_level'] as String? ?? '',
      section: section?['name'] as String? ?? '',
      content: row['passage_text'] as String? ?? '',
      questions: questions,
    );
  }

  Future<String> _getSignedAvatarUrl(String? avatarPath) async {
    if (avatarPath == null || avatarPath.trim().isEmpty) return '';
    if (avatarPath.startsWith('http://') || avatarPath.startsWith('https://')) {
      return avatarPath;
    }

    final client = SupabaseService.client;
    if (client == null) return '';
    return client.storage.from('avatars').createSignedUrl(avatarPath, 3600);
  }

  String _extensionFor(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (extension == 'png' || extension == 'webp') return extension;
    return 'jpg';
  }

  String _contentTypeFor(String extension) {
    if (extension == 'png') return 'image/png';
    if (extension == 'webp') return 'image/webp';
    return 'image/jpeg';
  }
}

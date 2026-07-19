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
  Future<List<ClassStats>> getCurrentClasses();
  Future<List<StudentProgress>> getCurrentStudents();
  Future<List<StudentActivity>> getCurrentActivities();
  Future<Map<String, List<ReadingSubmissionReview>>> getCurrentReadingReviews();
  Future<List<Book>> getCurrentBooks();
  Future<void> sendFeedback({
    required ReadingSubmissionReview submission,
    required String studentId,
    required String feedback,
  });
  Future<void> updateStudentSkillLevel({
    required String studentId,
    required String skillLevel,
  });
  Future<void> updateStudentSkillLevels({
    required String studentId,
    required int readingLevel,
    required int vocabularyLevel,
    required int wordMasterLevel,
    required int comprehensionLevel,
  });
  Future<void> awardBadgeToStudent({
    required String studentId,
    required String badgeName,
  });
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
  Future<List<ClassStats>> getCurrentClasses() async => getClasses();

  @override
  Future<List<StudentProgress>> getCurrentStudents() async => getStudents();

  @override
  Future<List<StudentActivity>> getCurrentActivities() async => getActivities();

  @override
  Future<Map<String, List<ReadingSubmissionReview>>>
  getCurrentReadingReviews() async {
    return const {};
  }

  @override
  Future<void> sendFeedback({
    required ReadingSubmissionReview submission,
    required String studentId,
    required String feedback,
  }) async {}

  @override
  Future<void> updateStudentSkillLevel({
    required String studentId,
    required String skillLevel,
  }) async {}

  @override
  Future<void> updateStudentSkillLevels({
    required String studentId,
    required int readingLevel,
    required int vocabularyLevel,
    required int wordMasterLevel,
    required int comprehensionLevel,
  }) async {}

  @override
  Future<void> awardBadgeToStudent({
    required String studentId,
    required String badgeName,
  }) async {}

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
  Future<List<StudentProgress>> getCurrentStudents() async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return super.getCurrentStudents();

    final rows = await client
        .from('student_profiles')
        .select(
          'profile_id,grade_level,current_skill_level,reading_level,vocabulary_level,word_master_level,comprehension_level,profiles(full_name,email,avatar_url,status),sections(name)',
        )
        .order('grade_level');

    final submissionsByStudent = await getCurrentReadingReviews();
    final students = <StudentProgress>[];
    for (final row in rows) {
      final profile = _embeddedMap(row['profiles']);
      final section = _embeddedMap(row['sections']);
      final id = row['profile_id'] as String? ?? '';
      if (id.isEmpty) continue;
      final reviews = submissionsByStudent[id] ?? const [];
      final submittedCount = reviews
          .where((review) => review.status == 'submitted')
          .length;
      final accuracyValues = reviews
          .map((review) => review.readingAccuracy)
          .whereType<double>()
          .toList();
      final avgAccuracy = accuracyValues.isEmpty
          ? 0.0
          : accuracyValues.reduce((a, b) => a + b) / accuracyValues.length;
      final status = _statusForAccuracy(avgAccuracy, submittedCount);

      final badges = await _getStudentBadges(id);

      students.add(
        StudentProgress(
          id: id,
          name: profile['full_name'] as String? ?? 'Unnamed Student',
          readingAccuracy: avgAccuracy,
          vocabularyLevel: avgAccuracy,
          progressCurrent: submittedCount,
          progressTotal: reviews.length > submittedCount
              ? reviews.length
              : submittedCount,
          status: status,
          badges: badges,
          grade: row['grade_level'] as String? ?? '',
          section: section['name'] as String? ?? '',
          avatarUrl: await _getSignedAvatarUrl(
            profile['avatar_url'] as String?,
          ),
          skillLevel:
              row['current_skill_level'] as String? ?? 'Reading Explorer',
          readingLevel: (row['reading_level'] as num?)?.toInt() ?? 1,
          vocabularySkillLevel: (row['vocabulary_level'] as num?)?.toInt() ?? 1,
          wordMasterLevel: (row['word_master_level'] as num?)?.toInt() ?? 1,
          comprehensionLevel:
              (row['comprehension_level'] as num?)?.toInt() ?? 1,
        ),
      );
    }
    return students;
  }

  @override
  Future<List<ClassStats>> getCurrentClasses() async {
    final students = await getCurrentStudents();
    final books = await getCurrentBooks();
    final byGrade = <String, List<StudentProgress>>{};
    for (final student in students) {
      byGrade.putIfAbsent(student.grade, () => []).add(student);
    }

    return byGrade.entries.map((entry) {
      final gradeStudents = entry.value;
      final completed = gradeStudents
          .where((student) => student.progressCurrent > 0)
          .length;
      final lessons = books.where((book) => book.grade == entry.key).length;
      return ClassStats(
        grade: entry.key,
        totalStudents: gradeStudents.length,
        completionRate: gradeStudents.isEmpty
            ? 0
            : completed / gradeStudents.length,
        totalLessons: lessons,
      );
    }).toList()..sort((a, b) => a.grade.compareTo(b.grade));
  }

  @override
  Future<List<StudentActivity>> getCurrentActivities() async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return super.getCurrentActivities();

    final rows = await client
        .from('reading_submissions')
        .select(
          'id,student_id,book_title_snapshot,status,submitted_at,created_at,profiles(full_name)',
        )
        .inFilter('status', ['submitted', 'processed'])
        .order('created_at', ascending: false)
        .limit(50);

    return rows.map<StudentActivity>((row) {
      final profile = _embeddedMap(row['profiles']);
      return StudentActivity(
        id: row['id'] as String? ?? '',
        studentName: profile['full_name'] as String? ?? 'Student',
        activityTitle: 'Read: ${row['book_title_snapshot'] ?? 'Untitled Book'}',
        score: row['status'] == 'submitted' ? 1 : 0,
        date: _dateLabel(row['submitted_at'] ?? row['created_at']),
      );
    }).toList();
  }

  @override
  Future<Map<String, List<ReadingSubmissionReview>>>
  getCurrentReadingReviews() async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      return super.getCurrentReadingReviews();
    }

    final rows = await client
        .from('reading_submissions')
        .select(
          'id,student_id,book_title_snapshot,passage_text_snapshot,video_path,status,submitted_at,created_at,'
          'transcript_results(raw_transcript,alignment_json,overall_accuracy),'
          'quiz_answers(is_correct)',
        )
        .inFilter('status', ['submitted', 'processed'])
        .order('created_at', ascending: false);

    final result = <String, List<ReadingSubmissionReview>>{};
    for (final row in rows) {
      final studentId = row['student_id'] as String? ?? '';
      if (studentId.isEmpty) continue;
      final videoPath = row['video_path'] as String? ?? '';
      final transcript = _embeddedMap(row['transcript_results']);
      final quizRows = _embeddedList(row['quiz_answers']);
      final quizTotal = quizRows.length;
      final quizScore = quizRows.where((answer) {
        final answerRow = answer as Map<String, dynamic>;
        return answerRow['is_correct'] == true;
      }).length;

      final review = ReadingSubmissionReview(
        id: row['id'] as String? ?? '',
        studentId: studentId,
        bookTitle: row['book_title_snapshot'] as String? ?? 'Untitled Book',
        passageText: row['passage_text_snapshot'] as String? ?? '',
        status: row['status'] as String? ?? '',
        submittedAtLabel: _dateLabel(row['submitted_at'] ?? row['created_at']),
        videoPath: videoPath,
        videoUrl: videoPath.isEmpty
            ? ''
            : await client.storage
                  .from('reading-videos')
                  .createSignedUrl(videoPath, 3600),
        rawTranscript: transcript['raw_transcript'] as String? ?? '',
        alignment: _alignmentFromJson(transcript['alignment_json']),
        readingAccuracy: _toDouble(transcript['overall_accuracy']),
        quizScore: quizScore,
        quizTotal: quizTotal,
      );
      result.putIfAbsent(studentId, () => []).add(review);
    }
    return result;
  }

  @override
  Future<void> sendFeedback({
    required ReadingSubmissionReview submission,
    required String studentId,
    required String feedback,
  }) async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      return super.sendFeedback(
        submission: submission,
        studentId: studentId,
        feedback: feedback,
      );
    }

    await client.from('teacher_feedback').insert({
      'submission_id': submission.id,
      'teacher_id': user.id,
      'student_id': studentId,
      'feedback_text': feedback,
    });
    await client.from('messages').insert({
      'recipient_id': studentId,
      'sender_id': user.id,
      'type': 'teacher_feedback',
      'title': 'Reading feedback: ${submission.bookTitle}',
      'body': feedback,
      'related_submission_id': submission.id,
    });
    try {
      await client.from('activity_logs').insert({
        'actor_id': user.id,
        'actor_role': 'teacher',
        'action': 'sent_teacher_feedback',
        'entity_type': 'reading_submission',
        'entity_id': submission.id,
        'metadata': {
          'student_id': studentId,
          'book_title': submission.bookTitle,
        },
      });
    } catch (_) {}
  }

  @override
  Future<void> updateStudentSkillLevel({
    required String studentId,
    required String skillLevel,
  }) async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      return super.updateStudentSkillLevel(
        studentId: studentId,
        skillLevel: skillLevel,
      );
    }

    await client
        .from('student_profiles')
        .update({'current_skill_level': skillLevel})
        .eq('profile_id', studentId);
  }

  @override
  Future<void> updateStudentSkillLevels({
    required String studentId,
    required int readingLevel,
    required int vocabularyLevel,
    required int wordMasterLevel,
    required int comprehensionLevel,
  }) async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      return super.updateStudentSkillLevels(
        studentId: studentId,
        readingLevel: readingLevel,
        vocabularyLevel: vocabularyLevel,
        wordMasterLevel: wordMasterLevel,
        comprehensionLevel: comprehensionLevel,
      );
    }

    await client
        .from('student_profiles')
        .update({
          'reading_level': readingLevel,
          'vocabulary_level': vocabularyLevel,
          'word_master_level': wordMasterLevel,
          'comprehension_level': comprehensionLevel,
        })
        .eq('profile_id', studentId);

    try {
      await client.from('activity_logs').insert({
        'actor_id': user.id,
        'actor_role': 'teacher',
        'action': 'updated_student_skill_levels',
        'entity_type': 'student_profile',
        'entity_id': studentId,
        'metadata': {
          'student_id': studentId,
          'reading_level': readingLevel,
          'vocabulary_level': vocabularyLevel,
          'word_master_level': wordMasterLevel,
          'comprehension_level': comprehensionLevel,
        },
      });
    } catch (_) {}
  }

  @override
  Future<void> awardBadgeToStudent({
    required String studentId,
    required String badgeName,
  }) async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      return super.awardBadgeToStudent(
        studentId: studentId,
        badgeName: badgeName,
      );
    }

    final existingBadge = await client
        .from('badges')
        .select('id')
        .eq('name', badgeName)
        .maybeSingle();
    final badgeRow =
        existingBadge ??
        await client
            .from('badges')
            .insert({'name': badgeName, 'created_by': user.id})
            .select('id')
            .single();
    final badgeId = badgeRow['id'] as String;

    final existingAward = await client
        .from('student_badges')
        .select('student_id')
        .eq('student_id', studentId)
        .eq('badge_id', badgeId)
        .maybeSingle();
    if (existingAward == null) {
      await client.from('student_badges').insert({
        'student_id': studentId,
        'badge_id': badgeId,
        'awarded_by': user.id,
      });
    }

    try {
      await client.from('activity_logs').insert({
        'actor_id': user.id,
        'actor_role': 'teacher',
        'action': 'awarded_badge',
        'entity_type': 'badge',
        'entity_id': badgeId,
        'metadata': {'student_id': studentId, 'badge_name': badgeName},
      });
    } catch (_) {}
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

  Future<List<String>> _getStudentBadges(String studentId) async {
    final client = SupabaseService.client;
    if (client == null) return const [];
    try {
      final rows = await client
          .from('student_badges')
          .select('badges(name)')
          .eq('student_id', studentId)
          .order('awarded_at', ascending: false);
      return rows
          .map<String>((row) {
            final badge = _embeddedMap(row['badges']);
            return badge['name'] as String? ?? '';
          })
          .where((badge) => badge.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
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

  String _statusForAccuracy(double accuracy, int submittedCount) {
    if (submittedCount == 0) return 'NO SUBMISSIONS';
    if (accuracy >= 0.9) return 'OUTSTANDING';
    if (accuracy >= 0.75) return 'GROWING';
    if (accuracy >= 0.5) return 'EXPLORER';
    return 'NEEDS SUPPORT';
  }

  String _dateLabel(dynamic rawDate) {
    final date = DateTime.tryParse(rawDate?.toString() ?? '');
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  List<TranscriptWordDiff> _alignmentFromJson(dynamic rawAlignment) {
    if (rawAlignment is! List) return const [];
    return rawAlignment
        .map<TranscriptWordDiff>((item) {
          if (item is! Map) {
            return TranscriptWordDiff(word: item.toString(), status: 'matched');
          }
          final word = item['expected']?.toString().trim().isNotEmpty == true
              ? item['expected'].toString()
              : item['word']?.toString().trim().isNotEmpty == true
              ? item['word'].toString()
              : item['actual']?.toString() ?? '';
          return TranscriptWordDiff(
            word: word,
            status: item['status']?.toString() ?? 'matched',
          );
        })
        .where((diff) => diff.word.trim().isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _embeddedMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is List && value.isNotEmpty && value.first is Map) {
      return Map<String, dynamic>.from(value.first as Map);
    }
    return <String, dynamic>{};
  }

  List<dynamic> _embeddedList(dynamic value) {
    if (value is List) return value;
    if (value is Map<String, dynamic>) return [value];
    return const [];
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
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

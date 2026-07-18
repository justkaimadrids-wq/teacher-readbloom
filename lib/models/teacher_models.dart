class ClassStats {
  final String grade;
  final int totalStudents;
  final double completionRate;
  final int totalLessons;

  ClassStats({
    required this.grade,
    required this.totalStudents,
    required this.completionRate,
    required this.totalLessons,
  });
}

class StudentProgress {
  final String id;
  final String name;
  final double readingAccuracy;
  final double vocabularyLevel;
  final int progressCurrent;
  final int progressTotal;
  final String status;
  final List<String> badges;
  final String grade;
  final String section;
  final String avatarUrl;
  final String skillLevel;

  StudentProgress({
    required this.id,
    required this.name,
    required this.readingAccuracy,
    required this.vocabularyLevel,
    required this.progressCurrent,
    required this.progressTotal,
    required this.status,
    required this.badges,
    required this.grade,
    required this.section,
    this.avatarUrl = '',
    this.skillLevel = 'Reading Explorer',
  });
}

class StudentActivity {
  final String id;
  final String studentName;
  final String activityTitle;
  final double score;
  final String date;

  StudentActivity({
    required this.id,
    required this.studentName,
    required this.activityTitle,
    required this.score,
    required this.date,
  });
}

class ReadingSubmissionReview {
  final String id;
  final String studentId;
  final String bookTitle;
  final String passageText;
  final String status;
  final String submittedAtLabel;
  final String videoPath;
  final String videoUrl;
  final String rawTranscript;
  final List<TranscriptWordDiff> alignment;
  final double? readingAccuracy;
  final int quizScore;
  final int quizTotal;

  const ReadingSubmissionReview({
    required this.id,
    required this.studentId,
    required this.bookTitle,
    required this.passageText,
    required this.status,
    required this.submittedAtLabel,
    required this.videoPath,
    required this.videoUrl,
    required this.rawTranscript,
    required this.alignment,
    required this.readingAccuracy,
    required this.quizScore,
    required this.quizTotal,
  });
}

class TranscriptWordDiff {
  final String word;
  final String status;

  const TranscriptWordDiff({required this.word, required this.status});
}

class EvaluationMetrics {
  int omissions;
  int repetitions;
  int selfCorrections;
  int mispronunciations;
  String feedback;

  EvaluationMetrics({
    required this.omissions,
    required this.repetitions,
    required this.selfCorrections,
    required this.mispronunciations,
    required this.feedback,
  });
}

class Book {
  final String id;
  final String title;
  final String grade;
  final String section;
  final String content;
  final List<BookQuestion> questions;

  Book({
    required this.id,
    required this.title,
    required this.grade,
    required this.section,
    required this.content,
    this.questions = const [],
  });
}

class BookQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  const BookQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });
}

class BookQuestionInput {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  const BookQuestionInput({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });
}

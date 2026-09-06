import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_readbloom/models/teacher_models.dart';
import 'package:teacher_readbloom/providers/teacher_provider.dart';

void main() {
  group('TeacherProvider Evaluation Metrics Tests', () {
    test('getEvaluationForStudent returns 0s when no submissions exist', () {
      final provider = TeacherProvider();
      final eval = provider.getEvaluationForStudent('student-123');

      expect(eval.omissions, 0);
      expect(eval.repetitions, 0);
      expect(eval.selfCorrections, 0);
      expect(eval.mispronunciations, 0);
      expect(eval.feedback, '');
    });

    test('updateEvaluation updates metrics correctly', () {
      final provider = TeacherProvider();
      provider.updateEvaluation('student-123', 1, 2, 3, 4, 'Great job!');

      final eval = provider.getEvaluationForStudent('student-123');
      expect(eval.omissions, 1);
      expect(eval.repetitions, 2);
      expect(eval.selfCorrections, 3);
      expect(eval.mispronunciations, 4);
      expect(eval.feedback, 'Great job!');
    });

    test('sendFeedbackForSubmission updates evaluation counts and feedback text', () async {
      final provider = TeacherProvider();
      const submission = ReadingSubmissionReview(
        id: 'sub-1',
        studentId: 'student-456',
        bookTitle: 'Test Book',
        passageText: 'Sample passage',
        status: 'submitted',
        submittedAtLabel: 'Today',
        videoPath: '',
        videoUrl: '',
        rawTranscript: 'sample words',
        alignment: [],
        readingAccuracy: 95.0,
        quizScore: 5,
        quizTotal: 5,
        suggestedRemarks: SuggestedReadingRemarks(
          omission: ReadingRemarkSuggestion(
            label: 'Omission',
            count: 3,
            transcriptIndexes: [],
            expectedIndexes: [],
            words: [],
            confidence: 'high',
          ),
          repetition: ReadingRemarkSuggestion(
            label: 'Repetition',
            count: 2,
            transcriptIndexes: [],
            expectedIndexes: [],
            words: [],
            confidence: 'high',
          ),
          selfCorrection: ReadingRemarkSuggestion(
            label: 'Self Correction',
            count: 1,
            transcriptIndexes: [],
            expectedIndexes: [],
            words: [],
            confidence: 'high',
          ),
          mispronunciation: ReadingRemarkSuggestion(
            label: 'Mispronunciation',
            count: 4,
            transcriptIndexes: [],
            expectedIndexes: [],
            words: [],
            confidence: 'high',
          ),
        ),
      );

      final reviewJson = jsonEncode({
        'format': 'readbloom_teacher_review_v1',
        'feedback': 'Good effort! Practice word pronunciation.',
        'transcript': 'sample words',
        'passage': 'Sample passage',
        'remarks': {
          'omission': {'label': 'Omission', 'count': 5, 'indexes': [0]},
          'repetition': {'label': 'Repetition', 'count': 1, 'indexes': [1]},
          'selfCorrection': {'label': 'Self Correction', 'count': 2, 'indexes': []},
          'mispronunciation': {'label': 'Mispronunciation', 'count': 3, 'indexes': []},
        },
      });

      await provider.sendFeedbackForSubmission(
        submission: submission,
        studentId: 'student-456',
        feedback: reviewJson,
      );

      final eval = provider.getEvaluationForStudent('student-456');
      expect(eval.omissions, 5);
      expect(eval.repetitions, 1);
      expect(eval.selfCorrections, 2);
      expect(eval.mispronunciations, 3);
      expect(eval.feedback, 'Good effort! Practice word pronunciation.');
    });
  });
}

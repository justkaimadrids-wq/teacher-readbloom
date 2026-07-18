import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/teacher_models.dart';
import '../../../providers/teacher_provider.dart';
import '../widgets/video_review_dialog.dart';

// Helper class to draw dashed borders in Flutter
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.dashLength,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final dashPath = _buildDashedPath(path, dashLength, gap);
    canvas.drawPath(dashPath, paint);
  }

  Path _buildDashedPath(Path source, double dashWidth, double dashGap) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = draw ? dashWidth : dashGap;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashedContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final double dashLength;
  final double gap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const DashedContainer({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1.5,
    this.borderRadius = 12.0,
    this.dashLength = 6.0,
    this.gap = 4.0,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        borderRadius: borderRadius,
        dashLength: dashLength,
        gap: gap,
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}

class EvaluationDetailPopup extends StatelessWidget {
  final StudentProgress student;
  final EvaluationMetrics eval;
  final String storyTitle;
  final ReadingSubmissionReview? submission;

  const EvaluationDetailPopup({
    super.key,
    required this.student,
    required this.eval,
    required this.storyTitle,
    this.submission,
  });

  void _showWriteFeedbackPopup(
    BuildContext context,
    StudentProgress student,
    EvaluationMetrics eval,
  ) {
    final controller = TextEditingController(text: eval.feedback);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext dialogContext) {
        return Center(
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Feedback',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Write a reading evaluation message for ${student.name}.',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24, width: 1.5),
                        ),
                        child: TextField(
                          controller: controller,
                          maxLines: 4,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter feedback message here...',
                            hintStyle: TextStyle(color: Colors.black38),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              final text = controller.text.trim();
                              final selectedSubmission = submission;
                              final provider = context.read<TeacherProvider>();
                              final navigator = Navigator.of(dialogContext);
                              final messenger = ScaffoldMessenger.of(context);
                              final error = selectedSubmission == null
                                  ? 'No selected reading submission was found.'
                                  : await provider.sendFeedbackForSubmission(
                                      submission: selectedSubmission,
                                      studentId: student.id,
                                      feedback: text,
                                    );
                              navigator.pop();
                              if (error != null) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: Colors.red.shade700,
                                  ),
                                );
                                return;
                              }
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Feedback successfully sent to ${student.name}!',
                                  ),
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF60A5FA),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Send',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 750;

    return Center(
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
            : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              width: isMobile ? double.infinity : 1000,
              constraints: BoxConstraints(
                maxHeight: isMobile
                    ? MediaQuery.of(context).size.height * 0.85
                    : 700,
              ),
              padding: isMobile
                  ? const EdgeInsets.all(20)
                  : const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header with Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Oral Reading Evaluation Report - $storyTitle',
                          style: GoogleFonts.outfit(
                            fontSize: isMobile ? 15 : 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white70),
                        hoverColor: Colors.white.withValues(alpha: 0.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24, thickness: 1),
                  const SizedBox(height: 16),

                  // Main layout content
                  Expanded(
                    child: SingleChildScrollView(
                      child: isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildLeftColumn(context, isMobile: true),
                                const SizedBox(height: 24),
                                _buildRightColumn(isMobile: true),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column (Avatar + Actions)
                                SizedBox(
                                  width: 250,
                                  child: _buildLeftColumn(
                                    context,
                                    isMobile: false,
                                  ),
                                ),
                                const SizedBox(width: 28),
                                // Right Column (Metrics + Story Text)
                                Expanded(
                                  child: _buildRightColumn(isMobile: false),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context, {required bool isMobile}) {
    final image = student.avatarUrl.isEmpty
        ? Image.asset('lib/assets/student_avatar.png', fit: BoxFit.cover)
        : Image.network(
            student.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Image.asset('lib/assets/student_avatar.png', fit: BoxFit.cover),
          );

    return Column(
      children: [
        // Beautiful Rounded Student Photo frame (Matches mockup avatar container)
        Container(
          width: isMobile ? 180 : 220,
          height: isMobile ? 140 : 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF60A5FA), width: 3.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: image,
          ),
        ),
        const SizedBox(height: 20),

        // REVIEW VIDEO BUTTON
        InkWell(
          onTap: submission?.videoUrl.isNotEmpty == true
              ? () {
                  showDialog(
                    context: context,
                    builder: (context) => VideoReviewDialog(
                      videoUrl: submission!.videoUrl,
                      title: submission!.bookTitle,
                    ),
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(24),
          child: DashedContainer(
            color: Colors.black,
            backgroundColor: Colors.white,
            borderRadius: 24,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'REVIEW VIDEO',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // FEEDBACK BUTTON
        InkWell(
          onTap: () => _showWriteFeedbackPopup(context, student, eval),
          borderRadius: BorderRadius.circular(24),
          child: DashedContainer(
            color: Colors.black,
            backgroundColor: Colors.white,
            borderRadius: 24,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'FEEDBACK',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SkillLevelControl(student: student),
      ],
    );
  }

  Widget _buildRightColumn({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Error metrics row/grid
        isMobile
            ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildPopupErrorTile(
                          'OMISSION',
                          eval.omissions > 0 ? eval.omissions : 2,
                          Colors.red,
                          isMobile: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildPopupErrorTile(
                          'REPETITION',
                          eval.repetitions > 0 ? eval.repetitions : 3,
                          const Color(0xFFF472B6),
                          isMobile: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPopupErrorTile(
                          'SELF CORRECTION',
                          eval.selfCorrections > 0 ? eval.selfCorrections : 4,
                          const Color(0xFF10B981),
                          isMobile: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildPopupErrorTile(
                          'MISPRONUNCIATION',
                          eval.mispronunciations > 0
                              ? eval.mispronunciations
                              : 5,
                          const Color(0xFFEAB308),
                          isMobile: true,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildPopupErrorTile(
                      'OMISSION',
                      eval.omissions > 0 ? eval.omissions : 2,
                      Colors.red,
                      isMobile: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPopupErrorTile(
                      'REPETITION',
                      eval.repetitions > 0 ? eval.repetitions : 3,
                      const Color(0xFFF472B6),
                      isMobile: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPopupErrorTile(
                      'SELF CORRECTION',
                      eval.selfCorrections > 0 ? eval.selfCorrections : 4,
                      const Color(0xFF10B981),
                      isMobile: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPopupErrorTile(
                      'MISPRONUNCIATION',
                      eval.mispronunciations > 0 ? eval.mispronunciations : 5,
                      const Color(0xFFEAB308),
                      isMobile: false,
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 24),

        if (submission != null) ...[
          _buildSubmissionSummary(isMobile: isMobile),
          const SizedBox(height: 18),
        ],

        // Color-coded Story analysis box
        _buildMockupStoryCard(isMobile: isMobile),
      ],
    );
  }

  Widget _buildPopupErrorTile(
    String title,
    int count,
    Color textColor, {
    required bool isMobile,
  }) {
    return DashedContainer(
      color: Colors.black,
      backgroundColor: Colors.white,
      borderRadius: 18,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 14),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 9 : 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 20 : 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockupStoryCard({required bool isMobile}) {
    final selectedSubmission = submission;
    if (selectedSubmission != null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 2.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transcript',
              style: GoogleFonts.outfit(
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedSubmission.rawTranscript.isEmpty
                  ? 'Transcript is not available yet.'
                  : selectedSubmission.rawTranscript,
              style: GoogleFonts.outfit(
                fontSize: isMobile ? 13 : 15,
                color: Colors.black87,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Passage Alignment',
              style: GoogleFonts.outfit(
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 8,
              children: selectedSubmission.alignment.isEmpty
                  ? [
                      Text(
                        selectedSubmission.passageText,
                        style: GoogleFonts.outfit(
                          fontSize: isMobile ? 13 : 15,
                          color: Colors.black87,
                          height: 1.45,
                        ),
                      ),
                    ]
                  : selectedSubmission.alignment.map((diff) {
                      final color = _alignmentColor(diff.status);
                      return Text(
                        diff.word,
                        style: GoogleFonts.outfit(
                          fontSize: isMobile ? 13 : 15,
                          color: color,
                          fontWeight: color == Colors.black87
                              ? FontWeight.w500
                              : FontWeight.w900,
                          decoration:
                              diff.status == 'missing' ||
                                  diff.status == 'substitution'
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                      );
                    }).toList(),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(
                fontSize: isMobile ? 14 : 18,
                color: Colors.black,
                height: 1.8,
                letterSpacing: 0.5,
              ),
              children: [
                // Paragraph 1
                const TextSpan(
                  text: 'Once there were two friends a ',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: 'squirrel ',
                  style: TextStyle(
                    color: Color(0xFFEAB308),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: 'and a puppy. They '),
                const TextSpan(
                  text: 'used ',
                  style: TextStyle(
                    color: Color(0xFFEAB308),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: 'to '),
                const TextSpan(
                  text: 'live ',
                  style: TextStyle(
                    color: Color(0xFFEAB308),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text:
                      'and play together. The squirrel was very sporty and always won the game. The puppy used to feel bad and ',
                ),
                const TextSpan(
                  text: 'thought ',
                  style: TextStyle(
                    color: Color(0xFFEAB308),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: 'that it was of no use.\n\n'),

                // Paragraph 2
                const TextSpan(text: 'One day, it started raining '),
                const TextSpan(
                  text: 'heavily',
                  style: TextStyle(
                    color: Color(0xFFEAB308),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: '. The squirrel was in '),
                const TextSpan(
                  text: 'high ',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: 'spirits. He started doing '),
                const TextSpan(
                  text: 'antics ',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: 'but '),
                const TextSpan(
                  text: 'suddenly',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ', '),
                const TextSpan(
                  text: 'lost ',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(
                  text: 'his balance and fell in the rain water.\n\n',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Paragraph 3
                const TextSpan(text: 'He '),
                const TextSpan(
                  text: 'called ',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: 'his friend, the puppy for help. The puppy ',
                ),
                const TextSpan(
                  text: 'came ',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: 'to his rescue. The squirrel climbed on its back and ',
                ),
                const TextSpan(
                  text: 'reached ',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text:
                      'a safe place. He thanked his friend for saving his life.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionSummary({required bool isMobile}) {
    final selectedSubmission = submission!;
    final accuracy = selectedSubmission.readingAccuracy == null
        ? 'Pending'
        : '${(selectedSubmission.readingAccuracy! * 100).round()}%';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 8,
        children: [
          _summaryText('Submitted', selectedSubmission.submittedAtLabel),
          _summaryText('Accuracy', accuracy),
          _summaryText(
            'Quiz',
            '${selectedSubmission.quizScore}/${selectedSubmission.quizTotal}',
          ),
          _summaryText('Skill', student.skillLevel),
        ],
      ),
    );
  }

  Widget _summaryText(String label, String value) {
    return Text(
      '$label: ${value.isEmpty ? 'N/A' : value}',
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    );
  }

  Color _alignmentColor(String status) {
    switch (status.toLowerCase()) {
      case 'missing':
      case 'omission':
        return Colors.red;
      case 'extra':
      case 'repetition':
        return const Color(0xFFF472B6);
      case 'substitution':
      case 'mismatch':
        return const Color(0xFFEAB308);
      default:
        return Colors.black87;
    }
  }
}

class _SkillLevelControl extends StatefulWidget {
  final StudentProgress student;

  const _SkillLevelControl({required this.student});

  @override
  State<_SkillLevelControl> createState() => _SkillLevelControlState();
}

class _SkillLevelControlState extends State<_SkillLevelControl> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.student.skillLevel);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SKILL LEVEL',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: provider.isUpdatingSkillLevel
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final error = await context
                        .read<TeacherProvider>()
                        .updateStudentSkillLevel(
                          studentId: widget.student.id,
                          skillLevel: _controller.text,
                        );
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(error ?? 'Skill level updated.'),
                        backgroundColor: error == null
                            ? const Color(0xFF10B981)
                            : Colors.red.shade700,
                      ),
                    );
                  },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/teacher_provider.dart';
import '../../../models/teacher_models.dart';

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
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

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

class DetailedProgressWebBody extends StatefulWidget {
  final VoidCallback onBack;
  const DetailedProgressWebBody({super.key, required this.onBack});

  @override
  State<DetailedProgressWebBody> createState() => _DetailedProgressWebBodyState();
}

class _DetailedProgressWebBodyState extends State<DetailedProgressWebBody> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final prov = context.read<TeacherProvider>();
    final student = prov.selectedStudentForEvaluation;
    if (student != null) {
      _feedbackController.text = prov.getEvaluationForStudent(student.id).feedback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TeacherProvider>();
    final student = prov.selectedStudentForEvaluation;
    if (student == null) {
      return Center(
        child: Text('No student selected.', style: GoogleFonts.outfit(color: Colors.white)),
      );
    }

    final eval = prov.getEvaluationForStudent(student.id);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header with Back Button
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                height: 85,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.white24,
                      width: 1.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: widget.onBack,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Evaluation Detail: ${student.name}',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable layout columns
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column (Avatar + Actions)
                    SizedBox(
                      width: 250,
                      child: _buildLeftColumn(student, eval),
                    ),
                    const SizedBox(width: 28),
                    // Right Column (Metrics + Story Text)
                    Expanded(
                      child: _buildRightColumn(eval),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn(StudentProgress student, EvaluationMetrics eval) {
    return Column(
      children: [
        // Beautiful Rounded Student Photo frame (Matches mockup avatar container)
        Container(
          width: 220,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF60A5FA), width: 3.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'lib/assets/student_avatar.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // REVIEW VIDEO BUTTON
        InkWell(
          onTap: () {},
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
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // GENERATE REPORT BUTTON
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: DashedContainer(
            color: Colors.black,
            backgroundColor: Colors.white,
            borderRadius: 24,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'GENERATE REPORT',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // FEEDBACK BOX (Mockup style feedback block)
        DashedContainer(
          color: Colors.black,
          backgroundColor: Colors.white,
          borderRadius: 20,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'FEEDBACK',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                eval.feedback.isNotEmpty
                    ? eval.feedback
                    : "Well done, Read more books and focus on the words that your not familiar with",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn(EvaluationMetrics eval) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Error metrics row (mockup style capsules with dashed borders)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildPopupErrorTile('OMISSION', eval.omissions > 0 ? eval.omissions : 2, Colors.red)),
            const SizedBox(width: 12),
            Expanded(child: _buildPopupErrorTile('REPETITION', eval.repetitions > 0 ? eval.repetitions : 3, const Color(0xFFF472B6))), // Pinkish
            const SizedBox(width: 12),
            Expanded(child: _buildPopupErrorTile('SELF CORRECTION', eval.selfCorrections > 0 ? eval.selfCorrections : 4, const Color(0xFF10B981))), // Emerald green
            const SizedBox(width: 12),
            Expanded(child: _buildPopupErrorTile('MISPRONUNCIATION', eval.mispronunciations > 0 ? eval.mispronunciations : 5, const Color(0xFFEAB308))), // Amber yellow
          ],
        ),
        const SizedBox(height: 28),

        // Color-coded Story analysis box
        _buildMockupStoryCard(),
      ],
    );
  }

  Widget _buildPopupErrorTile(String title, int count, Color textColor) {
    return DashedContainer(
      color: Colors.black,
      backgroundColor: Colors.white,
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockupStoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
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
                fontSize: 18,
                color: Colors.black,
                height: 1.8,
                letterSpacing: 0.5,
              ),
              children: [
                // Paragraph 1
                const TextSpan(text: 'Once there were two friends a ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                const TextSpan(text: 'squirrel ', style: TextStyle(color: Color(0xFFEAB308), fontWeight: FontWeight.bold)),
                const TextSpan(text: 'and a puppy. They '),
                const TextSpan(text: 'used ', style: TextStyle(color: Color(0xFFEAB308), fontWeight: FontWeight.bold)),
                const TextSpan(text: 'to '),
                const TextSpan(text: 'live ', style: TextStyle(color: Color(0xFFEAB308), fontWeight: FontWeight.bold)),
                const TextSpan(text: 'and play together. The squirrel was very sporty and always won the game. The puppy used to feel bad and '),
                const TextSpan(text: 'thought ', style: TextStyle(color: Color(0xFFEAB308), fontWeight: FontWeight.bold)),
                const TextSpan(text: 'that it was of no use.\n\n'),

                // Paragraph 2
                const TextSpan(text: 'One day, it started raining '),
                const TextSpan(text: 'heavily', style: TextStyle(color: Color(0xFFEAB308), fontWeight: FontWeight.bold)),
                const TextSpan(text: '. The squirrel was in '),
                const TextSpan(text: 'high ', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                const TextSpan(text: 'spirits. He started doing '),
                const TextSpan(text: 'antics ', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                const TextSpan(text: 'but '),
                const TextSpan(text: 'suddenly', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                const TextSpan(text: ', '),
                const TextSpan(text: 'lost ', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                const TextSpan(text: 'his balance and fell in the rain water.\n\n', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),

                // Paragraph 3
                const TextSpan(text: 'He '),
                const TextSpan(text: 'called ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                const TextSpan(text: 'his friend, the puppy for help. The puppy '),
                const TextSpan(text: 'came ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                const TextSpan(text: 'to his rescue. The squirrel climbed on its back and '),
                const TextSpan(text: 'reached ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                const TextSpan(text: 'a safe place. He thanked his friend for saving his life.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

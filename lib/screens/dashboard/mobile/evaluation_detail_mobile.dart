import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/teacher_provider.dart';
import '../../../models/teacher_models.dart';

class EvaluationDetailMobileBody extends StatefulWidget {
  final VoidCallback onBack;
  const EvaluationDetailMobileBody({super.key, required this.onBack});

  @override
  State<EvaluationDetailMobileBody> createState() => _EvaluationDetailMobileBodyState();
}

class _EvaluationDetailMobileBodyState extends State<EvaluationDetailMobileBody> {
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
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            'No student selected.',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    final eval = prov.getEvaluationForStudent(student.id);
    final initials = student.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Evaluation Detail',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 32.0),
          child: Column(
            children: [
              // Student Card Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      child: Text(
                        initials,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF0371C2),
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      student.name,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${student.grade} • ${student.section}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons (Clean glass outline buttons)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'REVIEW VIDEO',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF60A5FA),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'GENERATE REPORT',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Metrics Grid
              _buildMetricsGrid(eval),
              const SizedBox(height: 24),

              // Color-coded Story analysis box
              _buildMockupStoryCard(),
              const SizedBox(height: 24),

              // Feedback Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FEEDBACK',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _feedbackController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.black, fontSize: 13),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'Enter feedback message...',
                          hintStyle: TextStyle(color: Colors.black38),
                        ),
                        onChanged: (val) {
                          eval.feedback = val;
                          prov.updateEvaluation(
                            student.id,
                            eval.omissions,
                            eval.repetitions,
                            eval.selfCorrections,
                            eval.mispronunciations,
                            val,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(EvaluationMetrics eval) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.6,
      children: [
        _buildPopupErrorTile('OMISSION', eval.omissions > 0 ? eval.omissions : 2, Colors.red),
        _buildPopupErrorTile('REPETITION', eval.repetitions > 0 ? eval.repetitions : 3, const Color(0xFFF472B6)),
        _buildPopupErrorTile('SELF CORRECTION', eval.selfCorrections > 0 ? eval.selfCorrections : 4, const Color(0xFF10B981)),
        _buildPopupErrorTile('MISPRONUNCIATION', eval.mispronunciations > 0 ? eval.mispronunciations : 5, const Color(0xFFEAB308)),
      ],
    );
  }

  Widget _buildPopupErrorTile(String title, int count, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: GoogleFonts.outfit(
              fontSize: 24,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Oral Reading Analysis',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.black.withValues(alpha: 0.12), thickness: 1),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: Colors.black,
                height: 1.8,
              ),
              children: [
                const TextSpan(text: 'Once there were two friends a ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                const TextSpan(text: 'squirrel ', style: TextStyle(color: Color(0xFFEAB308), fontWeight: FontWeight.bold)),
                const TextSpan(text: 'and a puppy. They '),
                const TextSpan(text: 'used ', style: TextStyle(color: Color(0xFFEAB308), fontWeight: FontWeight.bold)),
                const TextSpan(text: 'to '),
                const TextSpan(text: 'live ', style: TextStyle(color: Color(0xFFEAB308), fontWeight: FontWeight.bold)),
                const TextSpan(text: 'and play together. The squirrel was very sporty and always won the game. The puppy used to feel bad and '),
                const TextSpan(text: 'thought ', style: TextStyle(color: Color(0xFFEAB308), fontWeight: FontWeight.bold)),
                const TextSpan(text: 'that it was of no use.\n\n'),

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

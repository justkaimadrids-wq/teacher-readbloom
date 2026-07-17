import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/teacher_provider.dart';
import '../../../models/teacher_models.dart';
import '../../../theme/app_theme.dart';

class DetailedProgressMobileBody extends StatefulWidget {
  final VoidCallback onBack;
  const DetailedProgressMobileBody({super.key, required this.onBack});

  @override
  State<DetailedProgressMobileBody> createState() =>
      _DetailedProgressMobileBodyState();
}

class _DetailedProgressMobileBodyState
    extends State<DetailedProgressMobileBody> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final prov = context.read<TeacherProvider>();
    final student = prov.selectedStudentForEvaluation;
    if (student != null) {
      _feedbackController.text = prov
          .getEvaluationForStudent(student.id)
          .feedback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TeacherProvider>();
    final student = prov.selectedStudentForEvaluation;
    if (student == null) {
      return Center(
        child: Text('No student selected.', style: GoogleFonts.outfit()),
      );
    }

    final eval = prov.getEvaluationForStudent(student.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Evaluation Detail: ${student.name}',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildStudentCard(student, eval),
              const SizedBox(height: 20),
              _buildMetricsGrid(eval),
              const SizedBox(height: 20),
              _buildStoryCodeCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(StudentProgress student, EvaluationMetrics eval) {
    return Column(
      children: [
        // Student avatar preview card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TeacherTheme.border),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: TeacherTheme.secondary.withValues(alpha: 0.08),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: TeacherTheme.secondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                student.name,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Level: ${student.status}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: TeacherTheme.text,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Action triggers
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: TeacherTheme.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('REVIEW VIDEO'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: TeacherTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('GENERATE REPORT'),
          ),
        ),
        const SizedBox(height: 16),
        // Feedback card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TeacherTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FEEDBACK',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter feedback...',
                ),
                onChanged: (val) {
                  eval.feedback = val;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(EvaluationMetrics eval) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: [
        _buildErrorCountTile('OMISSION', eval.omissions, Colors.red),
        _buildErrorCountTile('REPETITION', eval.repetitions, Colors.red.shade300),
        _buildErrorCountTile('SELF CORRECTION', eval.selfCorrections, Colors.green),
        _buildErrorCountTile('MISPRONUNCIATION', eval.mispronunciations, Colors.amber),
      ],
    );
  }

  Widget _buildErrorCountTile(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCodeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TeacherTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Oral Reading Analysis',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Divider(height: 20),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black87,
                height: 1.8,
              ),
              children: const [
                TextSpan(text: 'Once there were two friends a '),
                TextSpan(text: 'squirrel ', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                TextSpan(text: 'and a '),
                TextSpan(text: 'puppy', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                TextSpan(text: '. They '),
                TextSpan(text: 'used ', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                TextSpan(text: 'to '),
                TextSpan(text: 'live ', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                TextSpan(text: 'and play together. The squirrel was very sporty and always won the game. The puppy used to feel bad and '),
                TextSpan(text: 'thought ', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                TextSpan(text: 'that it was of no use. One day, it started raining '),
                TextSpan(text: 'heavily', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                TextSpan(text: '. The squirrel was in '),
                TextSpan(text: 'high ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                TextSpan(text: 'spirits. He started doing '),
                TextSpan(text: 'antics ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                TextSpan(text: 'but '),
                TextSpan(text: 'suddenly ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                TextSpan(text: 'lost ', style: TextStyle(color: Colors.green, decoration: TextDecoration.underline)),
                TextSpan(text: 'his balance and fell in the rain water. ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                TextSpan(text: 'He '),
                TextSpan(text: 'called ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                TextSpan(text: 'his friend, the puppy for help. The puppy '),
                TextSpan(text: 'came ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                TextSpan(text: 'to his rescue. The squirrel climbed on its back and '),
                TextSpan(text: 'reached ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                TextSpan(text: 'a safe place. He thanked his friend for saving his life.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/teacher_provider.dart';
import '../../../models/teacher_models.dart';
import '../../../theme/app_theme.dart';

class DashboardMobileBody extends StatelessWidget {
  final Function(StudentProgress) onSelectStudent;
  const DashboardMobileBody({super.key, required this.onSelectStudent});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TeacherProvider>();

    return Container(
      color: TeacherTheme.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard header
              Text(
                'Hello, Teacher Ana',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: TeacherTheme.text,
                ),
              ),
              const SizedBox(height: 16),

              _buildClassesAndOverview(context, prov),
              const SizedBox(height: 20),
              _buildPerformanceChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassesAndOverview(BuildContext context, TeacherProvider prov) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Classes',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: TeacherTheme.text,
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal list of classes
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: prov.classes.map((cls) => _buildClassCard(cls)).toList(),
          ),
        ),
        const SizedBox(height: 24),
        // Student Progress lists quick view
        Container(
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
                'Student Progress Overview',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              ...prov.students.map(
                (student) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    student.name,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Accuracy: ${(student.readingAccuracy * 100).toInt()}% • Progress: ${student.progressCurrent}/${student.progressTotal}',
                  ),
                  trailing: TextButton(
                    onPressed: () => onSelectStudent(student),
                    child: const Text('Review'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(ClassStats cls) {
    Color accentColor = Colors.green;
    if (cls.grade.contains('5')) accentColor = Colors.purple;
    if (cls.grade.contains('6')) accentColor = Colors.orange;

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              cls.grade,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Total Students: ${cls.totalStudents}',
            style: GoogleFonts.inter(fontSize: 12),
          ),
          Text(
            'Completion: ${(cls.completionRate * 100).toInt()}%',
            style: GoogleFonts.inter(fontSize: 12),
          ),
          Text(
            'Total Lessons: ${cls.totalLessons}',
            style: GoogleFonts.inter(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
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
            'Performance Metric Distributions',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.blue.shade600,
                    value: 55,
                    title: '55%',
                    radius: 30,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.purple.shade400,
                    value: 25,
                    title: '25%',
                    radius: 30,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.orange.shade400,
                    value: 15,
                    title: '15%',
                    radius: 30,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.yellow.shade600,
                    value: 5,
                    title: '5%',
                    radius: 30,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          _buildLegendRow(Colors.blue.shade600, 'INDEPENDENT (90-100%)', '55%'),
          _buildLegendRow(Colors.purple.shade400, 'INSTRUCTIONAL (75-89%)', '25%'),
          _buildLegendRow(Colors.orange.shade400, 'STRUGGLING (50-74%)', '15%'),
          _buildLegendRow(Colors.yellow.shade600, 'NON-READER (0-49%)', '5%'),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String text, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            val,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/teacher_provider.dart';
import '../../../models/teacher_models.dart';

class DashboardMobileBody extends StatelessWidget {
  final Function(StudentProgress) onSelectStudent;
  const DashboardMobileBody({super.key, required this.onSelectStudent});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TeacherProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard header
            Text(
              'Hello, ${prov.teacherName}',
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dashboard overview of your classes',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            _buildClassesAndOverview(context, prov),
            const SizedBox(height: 24),
            _buildPerformanceChart(),
          ],
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
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
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
        const SizedBox(height: 28),
        
        // Student Progress lists quick view
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student Progress Overview',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.white.withValues(alpha: 0.15), thickness: 1.5),
              const SizedBox(height: 12),
              ...prov.students.map(
                (student) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    student.name,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    'Accuracy: ${(student.readingAccuracy * 100).toInt()}% • Progress: ${student.progressCurrent}/${student.progressTotal}',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () => onSelectStudent(student),
                    child: Text(
                      'Review',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF60A5FA),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
    Color accentColor = const Color(0xFF4ADE80); // Green
    if (cls.grade.contains('5')) accentColor = const Color(0xFFC084FC); // Purple
    if (cls.grade.contains('6')) accentColor = const Color(0xFFFBBF24); // Gold

    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
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
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              cls.grade,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: accentColor,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildClassStatRow('Total Students', '${cls.totalStudents}'),
          const SizedBox(height: 4),
          _buildClassStatRow('Completion', '${(cls.completionRate * 100).toInt()}%'),
          const SizedBox(height: 4),
          _buildClassStatRow('Total Lessons', '${cls.totalLessons}'),
        ],
      ),
    );
  }

  Widget _buildClassStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Distributions',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 35,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF60A5FA),
                    value: 55,
                    title: '55%',
                    radius: 25,
                    titleStyle: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFC084FC),
                    value: 25,
                    title: '25%',
                    radius: 25,
                    titleStyle: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFFBBF24),
                    value: 15,
                    title: '15%',
                    radius: 25,
                    titleStyle: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFF87171),
                    value: 5,
                    title: '5%',
                    radius: 25,
                    titleStyle: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Legend
          _buildLegendRow(const Color(0xFF60A5FA), 'INDEPENDENT (90-100%)', '55%'),
          _buildLegendRow(const Color(0xFFC084FC), 'INSTRUCTIONAL (75-89%)', '25%'),
          _buildLegendRow(const Color(0xFFFBBF24), 'STRUGGLING (50-74%)', '15%'),
          _buildLegendRow(const Color(0xFFF87171), 'NON-READER (0-49%)', '5%'),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String text, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
          Text(
            val,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

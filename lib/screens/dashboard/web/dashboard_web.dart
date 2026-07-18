import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/teacher_provider.dart';
import '../../../models/teacher_models.dart';

class DashboardWebBody extends StatelessWidget {
  final Function(StudentProgress) onSelectStudent;
  const DashboardWebBody({super.key, required this.onSelectStudent});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TeacherProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Glassmorphic Dashboard Header
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
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
              ),
              child: Text(
                'Dashboard',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        // Scrollable content area
        Expanded(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Glass Theme Welcome Header
                  Text(
                    'Welcome back, Teacher Anas! 👋',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Here's a detailed overview of your classes and student reading progress.",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  if (prov.teacherDataError != null) ...[
                    const SizedBox(height: 16),
                    _buildDataWarning(prov.teacherDataError!),
                  ],
                  const SizedBox(height: 32),

                  // Classes Section Header
                  Row(
                    children: [
                      Text(
                        'Active Classes',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${prov.classes.length} Classes',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Glassmorphic Classes Card Row
                  Row(
                    children: prov.classes
                        .map(
                          (cls) => Expanded(child: _buildGlassClassCard(cls)),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  // Glassmorphic Bottom Grid: Student Progress and Performance Chart
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildGlassStudentProgressList(context, prov),
                      ),
                      const SizedBox(width: 28),
                      Expanded(flex: 2, child: _buildGlassPerformanceChart()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataWarning(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.28)),
      ),
      child: Text(
        message,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildGlassClassCard(ClassStats cls) {
    Color accentColor = const Color(0xFF4ADE80); // Vibrant Green
    Color lightBg = const Color(0xFF4ADE80).withValues(alpha: 0.2);
    if (cls.grade.contains('5')) {
      accentColor = const Color(0xFFD8B4FE); // Vibrant Purple
      lightBg = const Color(0xFFC084FC).withValues(alpha: 0.2);
    }
    if (cls.grade.contains('6')) {
      accentColor = const Color(0xFFFDBA74); // Vibrant Orange
      lightBg = const Color(0xFFFB923C).withValues(alpha: 0.2);
    }

    return Container(
      margin: const EdgeInsets.only(right: 16),
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
          // Class Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: lightBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              cls.grade,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                color: accentColor,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Metrics
          _buildGlassMetricRow(
            'Total of Students',
            '${cls.totalStudents}',
            accentColor,
          ),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 24),

          _buildGlassMetricRow(
            'Completion',
            '${(cls.completionRate * 100).toInt()}%',
            accentColor,
          ),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 24),

          _buildGlassMetricRow(
            'Total Lessons',
            '${cls.totalLessons}',
            accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassMetricRow(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassStudentProgressList(
    BuildContext context,
    TeacherProvider prov,
  ) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Student Progress Overview',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                '${prov.students.length} Students',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.15), thickness: 1.5),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: prov.students.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final student = prov.students[index];
              final initials = student.name
                  .split(' ')
                  .map((e) => e.isNotEmpty ? e[0] : '')
                  .take(2)
                  .join()
                  .toUpperCase();
              final progressPct = student.progressTotal > 0
                  ? (student.progressCurrent / student.progressTotal)
                  : 0.0;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Text(
                        initials,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF0371C2),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                'Accuracy: ${(student.readingAccuracy * 100).toInt()}%',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '•',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Progress: ${student.progressCurrent}/${student.progressTotal}',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressPct.toDouble(),
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => onSelectStudent(student),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'Review',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlassPerformanceChart() {
    return Container(
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
            'Performance Metric Distributions',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 28),

          // Pie Chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 45,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF60A5FA), // Soft Blue
                    value: 35,
                    title: '35%',
                    radius: 30,
                    titleStyle: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF34D399), // Soft Green
                    value: 35,
                    title: '35%',
                    radius: 30,
                    titleStyle: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFFBBF24), // Soft Amber
                    value: 20,
                    title: '20%',
                    radius: 30,
                    titleStyle: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFF87171), // Soft Red
                    value: 10,
                    title: '10%',
                    radius: 30,
                    titleStyle: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Legend Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              children: [
                _buildLegendRow(
                  const Color(0xFF60A5FA),
                  'INDEPENDENT (90-100%)',
                  '35%',
                ),
                const SizedBox(height: 8),
                _buildLegendRow(
                  const Color(0xFF34D399),
                  'INSTRUCTIONAL (75-89%)',
                  '35%',
                ),
                const SizedBox(height: 8),
                _buildLegendRow(
                  const Color(0xFFFBBF24),
                  'STRUGGLING (50-74%)',
                  '20%',
                ),
                const SizedBox(height: 8),
                _buildLegendRow(
                  const Color(0xFFF87171),
                  'NON-READER (0-49%)',
                  '10%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String text, String val) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          val,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

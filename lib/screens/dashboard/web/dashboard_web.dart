import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
                    'Welcome back, ${prov.teacherName}',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
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
}

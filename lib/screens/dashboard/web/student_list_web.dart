import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/teacher_provider.dart';
import '../../../theme/app_theme.dart';

class StudentListWebBody extends StatelessWidget {
  const StudentListWebBody({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TeacherProvider>();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Student Progress Overview',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: TeacherTheme.text,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TeacherTheme.border),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Reading Level')),
                  DataColumn(label: Text('Vocabulary')),
                  DataColumn(label: Text('Progress')),
                  DataColumn(label: Text('Status')),
                ],
                rows: prov.students.map((student) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          student.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(
                        _buildStatusChip(
                          '${(student.readingAccuracy * 100).toInt()}% Accuracy',
                          TeacherTheme.primary,
                        ),
                      ),
                      DataCell(
                        Text('${(student.vocabularyLevel * 100).toInt()}%'),
                      ),
                      DataCell(
                        Text(
                          '${student.progressCurrent}/${student.progressTotal} (${(student.progressCurrent / student.progressTotal * 100).toInt()}%)',
                        ),
                      ),
                      DataCell(
                        Text(
                          student.status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: student.status == 'OUTSTANDING'
                                ? Colors.green
                                : Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

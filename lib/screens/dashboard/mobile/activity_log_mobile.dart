import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityLogMobileBody extends StatefulWidget {
  const ActivityLogMobileBody({super.key});

  @override
  State<ActivityLogMobileBody> createState() => _ActivityLogMobileBodyState();
}

class _ActivityLogMobileBodyState extends State<ActivityLogMobileBody> {
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {

    // Mock activities to show pagination clearly
    final List<Map<String, String>> mockActivities = [
      {
        'studentName': 'Kira Jhonson',
        'grade': 'Grade 4',
        'section': 'Section A',
        'bookRead': 'The Brave Little Squirrel',
        'date': '2026-03-10',
        'status': 'Finished'
      },
      {
        'studentName': 'Akame Tori',
        'grade': 'Grade 5',
        'section': 'Section B',
        'bookRead': 'Space Exploration',
        'date': '2026-02-09',
        'status': 'Finished'
      },
      {
        'studentName': 'Asta Orfai',
        'grade': 'Grade 6',
        'section': 'Section A',
        'bookRead': 'Nature Words',
        'date': '2026-03-01',
        'status': 'Finished'
      },
      {
        'studentName': 'Kei Adamson',
        'grade': 'Grade 4',
        'section': 'Section B',
        'bookRead': 'Action Verbs',
        'date': '2026-02-01',
        'status': 'Finished'
      },
      {
        'studentName': 'Kira Jhonson',
        'grade': 'Grade 4',
        'section': 'Section A',
        'bookRead': 'The Whispering Trees',
        'date': '2026-01-20',
        'status': 'Finished'
      },
      {
        'studentName': 'Akame Tori',
        'grade': 'Grade 5',
        'section': 'Section B',
        'bookRead': 'Tales of the Ocean',
        'date': '2026-01-15',
        'status': 'Finished'
      },
      {
        'studentName': 'Asta Orfai',
        'grade': 'Grade 6',
        'section': 'Section A',
        'bookRead': 'Volcano Wonders',
        'date': '2025-12-18',
        'status': 'In Progress'
      },
      {
        'studentName': 'Kei Adamson',
        'grade': 'Grade 4',
        'section': 'Section B',
        'bookRead': 'Amazing Animals',
        'date': '2025-12-10',
        'status': 'Finished'
      },
      {
        'studentName': 'Kira Jhonson',
        'grade': 'Grade 4',
        'section': 'Section A',
        'bookRead': 'The Wind in the Willows',
        'date': '2025-12-01',
        'status': 'In Progress'
      },
      {
        'studentName': 'Akame Tori',
        'grade': 'Grade 5',
        'section': 'Section B',
        'bookRead': 'Stars and Galaxies',
        'date': '2025-11-20',
        'status': 'Finished'
      },
    ];

    // Compute paginated items
    final totalItems = mockActivities.length;
    final totalPages = (totalItems / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage < totalItems) ? startIndex + _itemsPerPage : totalItems;
    final paginatedItems = mockActivities.sublist(startIndex, endIndex);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 12.0),
            child: Text(
              'Activity Log',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),

          // Log Container Panel
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 32.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activities',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${startIndex + 1}-$endIndex of $totalItems',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.white.withValues(alpha: 0.15), thickness: 1),
                    const SizedBox(height: 12),

                    // Log list items paged
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: paginatedItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final act = paginatedItems[idx];
                        final initials = act['studentName']!.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top info line
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      initials,
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF0371C2),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      act['studentName']!,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (act['status'] == 'Finished'
                                              ? const Color(0xFF4ADE80)
                                              : const Color(0xFFFBBF24))
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: (act['status'] == 'Finished'
                                                ? const Color(0xFF4ADE80)
                                                : const Color(0xFFFBBF24))
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Text(
                                      act['status']!,
                                      style: GoogleFonts.outfit(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: act['status'] == 'Finished'
                                            ? const Color(0xFF4ADE80)
                                            : const Color(0xFFFBBF24),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                              const SizedBox(height: 8),

                              // Grade / Section / Book info
                              _buildLogDetailRow('Class', '${act['grade']} • ${act['section']}'),
                              const SizedBox(height: 4),
                              _buildLogDetailRow('Book', act['bookRead']!, isHighlight: true),
                              const SizedBox(height: 4),
                              _buildLogDetailRow('Date', act['date']!),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Pagination Control Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _currentPage > 1
                              ? () => setState(() => _currentPage--)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white.withValues(alpha: 0.02),
                            disabledForegroundColor: Colors.white24,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: _currentPage > 1
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : Colors.white10,
                              ),
                            ),
                          ),
                          child: Text(
                            'Prev',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        Text(
                          '$_currentPage / $totalPages',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _currentPage < totalPages
                              ? () => setState(() => _currentPage++)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white.withValues(alpha: 0.02),
                            disabledForegroundColor: Colors.white24,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: _currentPage < totalPages
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : Colors.white10,
                              ),
                            ),
                          ),
                          child: Text(
                            'Next',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
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

  Widget _buildLogDetailRow(String label, String value, {bool isHighlight = false}) {
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
            color: isHighlight ? const Color(0xFF60A5FA) : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/teacher_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_layout.dart';
import 'mobile/dashboard_mobile.dart';
import 'web/dashboard_web.dart';
import 'mobile/student_list_mobile.dart';
import 'web/student_list_web.dart';
import 'mobile/activity_log_mobile.dart';
import 'web/activity_log_web.dart';
import 'mobile/badges_mobile.dart';
import 'web/badges_web.dart';
import 'mobile/profile_mobile.dart';
import 'web/profile_web.dart';
import 'mobile/detailed_progress_mobile.dart';
import 'web/detailed_progress_web.dart';

class TeacherMainScaffold extends StatefulWidget {
  const TeacherMainScaffold({super.key});

  @override
  State<TeacherMainScaffold> createState() => _TeacherMainScaffoldState();
}

class _TeacherMainScaffoldState extends State<TeacherMainScaffold> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileBody: _buildMobileScaffold(context),
        webBody: _buildWebScaffold(context),
      ),
    );
  }

  // --- MOBILE LAYOUT ---
  Widget _buildMobileScaffold(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _getMobileTabBody(_currentTab)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentTab > 4 ? 0 : _currentTab,
            onTap: (index) => setState(() => _currentTab = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: TeacherTheme.primary,
            unselectedItemColor: TeacherTheme.mutedText,
            selectedLabelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_outlined),
                label: 'Students',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Activity',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.workspace_premium),
                label: 'Badges',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- WEB LAYOUT ---
  Widget _buildWebScaffold(BuildContext context) {
    final prov = context.watch<TeacherProvider>();
    return Row(
      children: [
        // Sidebar Navigation Rail
        Container(
          width: 250,
          decoration: const BoxDecoration(color: Color(0xFF111827)),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Image.asset('lib/assets/logo-icon.png', height: 70, width: 70),
              const SizedBox(height: 8),
              Text(
                'ReadBloom',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'TEACHER PORTAL',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              _buildSidebarItem(0, Icons.dashboard_outlined, 'Dashboard'),
              _buildSidebarItem(1, Icons.list_alt_outlined, 'Students Progress'),
              _buildSidebarItem(2, Icons.history, 'Activity Log'),
              _buildSidebarItem(3, Icons.workspace_premium, 'Earn Badges'),
              _buildSidebarItem(4, Icons.settings_outlined, 'Settings'),
              const Spacer(),
              // Teacher User Indicator at bottom
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white24,
                      child: Text(
                        prov.teacherName.substring(0, 2).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            prov.teacherName,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'ADMINISTRATOR',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: Colors.white60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Main Content Area
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/bg-web.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: _getWebTabBody(_currentTab),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    final isActive = _currentTab == index;
    return InkWell(
      onTap: () => setState(() => _currentTab = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? TeacherTheme.primary : Colors.white70),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isActive ? TeacherTheme.text : Colors.white70,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToStudentDetail(dynamic student) {
    context.read<TeacherProvider>().selectStudentForEvaluation(student);
    setState(() {
      _currentTab = 5; // Direct to Detail Evaluation Page
    });
  }

  void _navigateBackToDashboard() {
    setState(() {
      _currentTab = 0; // Return to Dashboard
    });
  }

  Widget _getMobileTabBody(int index) {
    switch (index) {
      case 0:
        return DashboardMobileBody(onSelectStudent: _navigateToStudentDetail);
      case 1:
        return const StudentListMobileBody();
      case 2:
        return const ActivityLogMobileBody();
      case 3:
        return const BadgesMobileBody();
      case 4:
        return const ProfileMobileBody();
      case 5:
        return DetailedProgressMobileBody(onBack: _navigateBackToDashboard);
      default:
        return DashboardMobileBody(onSelectStudent: _navigateToStudentDetail);
    }
  }

  Widget _getWebTabBody(int index) {
    switch (index) {
      case 0:
        return DashboardWebBody(onSelectStudent: _navigateToStudentDetail);
      case 1:
        return const StudentListWebBody();
      case 2:
        return const ActivityLogWebBody();
      case 3:
        return const BadgesWebBody();
      case 4:
        return const ProfileWebBody();
      case 5:
        return DetailedProgressWebBody(onBack: _navigateBackToDashboard);
      default:
        return DashboardWebBody(onSelectStudent: _navigateToStudentDetail);
    }
  }
}

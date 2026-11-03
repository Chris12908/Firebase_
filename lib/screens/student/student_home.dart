import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../profile_tab.dart';
import '../reports_tab.dart';
import 'home_tab.dart';
import 'submit_report_screen.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    context.read<IncidentProvider>().start();
  }

  void _openReport() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const SubmitReportScreen()));

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label,
      {int flex = 1}) {
    final selected = _index == index;
    final color = selected ? AppColors.primary : AppColors.muted;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => setState(() => _index = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11.5,
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeTab(onReport: _openReport, onSeeAll: () => setState(() => _index = 1)),
          const ReportsTab(),
          const ProfileTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openReport,
        tooltip: 'Report an issue',
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 64,
        padding: EdgeInsets.zero,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          children: [
            _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
            _navItem(1, Icons.description_outlined, Icons.description, 'Reports'),
            const SizedBox(width: 72), // space for the center button
            _navItem(2, Icons.person_outline, Icons.person, 'Profile', flex: 2),
          ],
        ),
      ),
    );
  }
}
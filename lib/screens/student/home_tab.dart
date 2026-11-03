import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_style.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/summary_tile.dart';
import '../incident_detail_screen.dart';
import 'submit_report_screen.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback onReport;
  final VoidCallback onSeeAll;
  const HomeTab({super.key, required this.onReport, required this.onSeeAll});

  Widget _categoryShortcut(BuildContext context, String c) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SubmitReportScreen(initialCategory: c)),
        ),
        child: Container(
          width: 88,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(categoryIcon(c),
                    size: 20, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(c,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser;
    final p = context.watch<IncidentProvider>();
    final mine = p.filter(reporterId: user?.uid);
    int count(List<String> s) => mine.where((i) => s.contains(i.status)).length;
    final recent = mine.take(3).toList(); // already newest first
    final fullName = (user?.name ?? '').trim();
    final firstName = fullName.isEmpty ? 'there' : fullName.split(' ').first;
    final initial = firstName[0].toUpperCase();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 90),
        children: [
          // Greeting
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, $firstName ',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink)),
                      const SizedBox(height: 4),
                      const Text(
                          'Help make our campus safer.\nReport issues and track their resolution.',
                          style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 13.5,
                              height: 1.35)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Text(initial,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Hero card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24)),
              child: Stack(
                children: [
                  Positioned(
                    right: -16,
                    top: -8,
                    child: Icon(Icons.apartment_rounded,
                        size: 130,
                        color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('See an issue\non campus?',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.15)),
                      const SizedBox(height: 6),
                      const SizedBox(
                        width: 220,
                        child: Text(
                            'Report it and help improve our learning environment.',
                            style:
                                TextStyle(color: Colors.white70, height: 1.3)),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onReport,
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Icon(Icons.add_circle_outline),
                                SizedBox(width: 8),
                                Text('Report an Issue'),
                              ]),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Summary
          const SectionHeader('Report Summary'),
          SummaryRow(tiles: [
            SummaryTile(
                icon: Icons.description_outlined,
                count: mine.length,
                label: 'My reports',
                color: AppColors.primary),
            SummaryTile(
                icon: Icons.hourglass_empty_rounded,
                count: count(['Submitted', 'Under Review']),
                label: 'Pending',
                color: StatusChip.colorFor('Submitted')),
            SummaryTile(
                icon: Icons.timelapse_rounded,
                count: count(['In Progress']),
                label: 'In progress',
                color: StatusChip.colorFor('In Progress')),
            SummaryTile(
                icon: Icons.check_circle_outline,
                count: count(['Resolved']),
                label: 'Resolved',
                color: StatusChip.colorFor('Resolved')),
          ]),

          // Category shortcuts
          const SectionHeader('Report by category'),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: AppConstants.categories
                  .map((c) => _categoryShortcut(context, c))
                  .toList(),
            ),
          ),

          // Recent
          SectionHeader('Recent Reports', onSeeAll: onSeeAll),
          if (p.loading)
            const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()))
          else if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: EmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'No reports yet',
                  message: 'Tap "Report an Issue" to submit your first one.'),
            )
          else
            ...recent.map((i) => IncidentCard(
                  incident: i,
                  onTap: () => openIncident(context, i.id),
                )),
        ],
      ),
    );
  }
}
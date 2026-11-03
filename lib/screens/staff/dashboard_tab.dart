import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/summary_tile.dart';
import '../incident_detail_screen.dart';

class DashboardTab extends StatelessWidget {
  final VoidCallback onSeeAll;
  const DashboardTab({super.key, required this.onSeeAll});

  static const _icons = {
    'Submitted': Icons.inbox_outlined,
    'Under Review': Icons.visibility_outlined,
    'In Progress': Icons.timelapse_rounded,
    'Resolved': Icons.check_circle_outline,
  };

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser;
    final p = context.watch<IncidentProvider>();
    final counts = p.countByStatus();
    final needs = p.all.where((i) => i.status == 'Submitted').take(5).toList();
    final firstName = (user?.name ?? '').trim().split(' ').first;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Staff Dashboard',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink)),
                const SizedBox(height: 4),
                Text('Hello, $firstName. Here is what needs your attention.',
                    style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          const SectionHeader('Overview'),
          SummaryRow(
            tiles: counts.entries
                .map((e) => SummaryTile(
                      icon: _icons[e.key] ?? Icons.circle_outlined,
                      count: e.value,
                      label: e.key,
                      color: StatusChip.colorFor(e.key),
                    ))
                .toList(),
          ),
          SectionHeader('Needs attention', onSeeAll: onSeeAll),
          if (p.loading)
            const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()))
          else if (needs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: EmptyState(
                  icon: Icons.done_all_rounded,
                  title: 'All caught up',
                  message: 'No new reports are waiting for review.'),
            )
          else
            ...needs.map((i) => IncidentCard(
                  incident: i,
                  onTap: () => openIncident(context, i.id),
                )),
        ],
      ),
    );
  }
}
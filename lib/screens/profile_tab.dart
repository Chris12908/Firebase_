import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/info_card.dart';
import '../widgets/status_chip.dart';
import '../widgets/summary_tile.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                  Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.ink)),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final p = context.watch<IncidentProvider>();
    final user = auth.appUser;
    final list = auth.isStaff ? p.all : p.filter(reporterId: user?.uid);
    int count(String s) => list.where((i) => i.status == s).length;
    final name = (user?.name ?? '').trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    final roleLabel = auth.isStaff ? 'Staff' : 'Student';

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        children: [
          const Text('Profile',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink)),
          const SizedBox(height: 16),

          // Identity
          InfoCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary,
                  child: Text(initial,
                      style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),
                Text(name.isEmpty ? 'Unknown user' : name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(user?.email ?? '',
                    style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(roleLabel,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats
          Text(auth.isStaff ? 'All reports' : 'My activity',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink)),
          const SizedBox(height: 10),
          SummaryRow(
            padding: EdgeInsets.zero,
            tiles: [
              SummaryTile(
                  icon: Icons.description_outlined,
                  count: list.length,
                  label: 'Total',
                  color: AppColors.primary),
              SummaryTile(
                  icon: Icons.timelapse_rounded,
                  count: count('In Progress'),
                  label: 'In progress',
                  color: StatusChip.colorFor('In Progress')),
              SummaryTile(
                  icon: Icons.check_circle_outline,
                  count: count('Resolved'),
                  label: 'Resolved',
                  color: StatusChip.colorFor('Resolved')),
            ],
          ),
          const SizedBox(height: 16),

          // Account details
          InfoCard(
            title: 'Account',
            child: Column(
              children: [
                _row(Icons.badge_outlined, 'Role', roleLabel),
                _row(Icons.mail_outline, 'Email', user?.email ?? '-'),
                _row(
                    auth.isVerified
                        ? Icons.verified_outlined
                        : Icons.warning_amber_rounded,
                    'Email status',
                    auth.isVerified ? 'Verified' : 'Not verified'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
            onPressed: () async {
              context.read<IncidentProvider>().stop();
              await context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
    );
  }
}
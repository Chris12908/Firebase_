import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/app_theme.dart';
import '../utils/category_style.dart';
import '../utils/constants.dart';
import '../widgets/info_card.dart';
import '../widgets/status_chip.dart';
import '../widgets/status_timeline.dart';
import 'student/submit_report_screen.dart';

void openIncident(BuildContext context, String id) {
  Navigator.push(context,
      MaterialPageRoute(builder: (_) => IncidentDetailScreen(incidentId: id)));
}

class IncidentDetailScreen extends StatelessWidget {
  final String incidentId;
  const IncidentDetailScreen({super.key, required this.incidentId});

  Future<void> _delete(BuildContext context) async {
    final provider = context.read<IncidentProvider>();
    final incident = provider.byId(incidentId);
    if (incident == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    final ok = await provider.delete(incident);
    messenger.showSnackBar(SnackBar(
        content: Text(ok ? 'Report deleted' : provider.error ?? 'Failed')));
    if (ok) navigator.pop();
  }

  Future<void> _changeStatus(
      BuildContext context, String status, String staffName) async {
    final provider = context.read<IncidentProvider>();
    final ok = await provider.updateStatus(incidentId, status, staffName);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Status updated to $status' : 'Update failed')));
  }

  Widget _info(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final incident = context.watch<IncidentProvider>().byId(incidentId);
    final auth = context.watch<AuthProvider>();
    final fmt = DateFormat('d MMM y, HH:mm');

    if (incident == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Incident Details')),
        body: const Center(child: Text('This report no longer exists')),
      );
    }

    final isOwner = incident.reporterId == auth.appUser?.uid;
    final canDelete = isOwner && incident.status == 'Submitted';
    final canEdit = canDelete; // same condition: owner, still 'Submitted'

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          if (canEdit)
            IconButton(
              tooltip: 'Edit report',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SubmitReportScreen(existing: incident)),
              ),
            ),
          if (canDelete)
            IconButton(
                tooltip: 'Delete report',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (incident.photoUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                incident.photoUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        height: 220,
                        child: Center(child: CircularProgressIndicator())),
                errorBuilder: (_, __, ___) => const SizedBox(
                    height: 120, child: Center(child: Icon(Icons.broken_image))),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(incident.title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink)),
              ),
              const SizedBox(width: 8),
              StatusChip(incident.status),
            ],
          ),
          const SizedBox(height: 12),
          InfoCard(
            child: Column(children: [
              _info(categoryIcon(incident.category), incident.category),
              _info(Icons.place_outlined, incident.location),
              _info(Icons.person_outline,
                  'Reported by ${incident.reporterName}'),
              _info(Icons.schedule,
                  'Submitted ${fmt.format(incident.createdAt)}'),
            ]),
          ),
          const SizedBox(height: 12),
          InfoCard(
            title: 'Status Timeline',
            child: StatusTimeline(
                status: incident.status, history: incident.history),
          ),
          const SizedBox(height: 12),
          InfoCard(
            title: 'Description',
            child: Text(incident.description,
                style: const TextStyle(height: 1.45)),
          ),
          // Staff-only controls (also enforced by Firestore rules)
          if (auth.isStaff) ...[
            const SizedBox(height: 12),
            InfoCard(
              title: 'Update status',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.statuses.map((s) {
                  final sel = incident.status == s;
                  return ChoiceChip(
                    label: Text(s),
                    selected: sel,
                    showCheckmark: false,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                        color: sel ? AppColors.primary : AppColors.border),
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : AppColors.ink,
                        fontWeight: FontWeight.w600),
                    onSelected: sel
                        ? null
                        : (_) => _changeStatus(
                            context, s, auth.appUser?.name ?? 'Staff'),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          InfoCard(
            title: 'Activity',
            child: Column(
              children: incident.history.reversed
                  .map((h) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.circle,
                            size: 12, color: StatusChip.colorFor(h.status)),
                        title: Text(h.status,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${h.by} • ${fmt.format(h.at)}'),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/incident_provider.dart';
import '../screens/incident_detail_screen.dart';
import '../utils/app_theme.dart';
import '../utils/category_style.dart';
import '../utils/constants.dart';
import 'empty_state.dart';
import 'incident_card.dart';

/// Reusable list with search + filters. Pass reporterId to show "My reports".
class IncidentListView extends StatefulWidget {
  final String? reporterId;
  const IncidentListView({super.key, this.reporterId});

  @override
  State<IncidentListView> createState() => _IncidentListViewState();
}

class _IncidentListViewState extends State<IncidentListView> {
  String _query = '';
  String? _category;
  String? _status;

  Future<void> _pickCategory() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter by category',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', ...AppConstants.categories].map((c) {
                  final sel =
                      (c == 'All' && _category == null) || c == _category;
                  return ChoiceChip(
                    avatar: c == 'All'
                        ? null
                        : Icon(categoryIcon(c),
                            size: 18,
                            color: sel ? Colors.white : AppColors.primary),
                    label: Text(c),
                    selected: sel,
                    showCheckmark: false,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                        color: sel ? AppColors.primary : AppColors.border),
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : AppColors.ink,
                        fontWeight: FontWeight.w600),
                    onSelected: (_) => Navigator.pop(sheetCtx, c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      setState(() => _category = picked == 'All' ? null : picked);
    }
  }

  Widget _statusChip(String label, String? value) {
    final selected = _status == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
        labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.ink,
            fontWeight: FontWeight.w600,
            fontSize: 13),
        onSelected: (_) => setState(() => _status = value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search reports',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: 8),
              Badge(
                smallSize: 9,
                isLabelVisible: _category != null,
                backgroundColor: AppColors.accent,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryTint,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(52, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  tooltip: 'Filter by category',
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: _pickCategory,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _statusChip('All', null),
              ...AppConstants.statuses.map((s) => _statusChip(s, s)),
            ],
          ),
        ),
        Expanded(
          child: Consumer<IncidentProvider>(
            builder: (context, p, _) {
              if (p.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (p.error != null && p.all.isEmpty) {
                return EmptyState(
                    icon: Icons.wifi_off_rounded,
                    title: 'Something went wrong',
                    message: p.error!);
              }
              final items = p.filter(
                query: _query,
                category: _category,
                status: _status,
                reporterId: widget.reporterId,
              );
              if (items.isEmpty) {
                return const EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'No reports found',
                    message: 'Try a different search or filter.');
              }
              return RefreshIndicator(
                color: AppColors.primary,
                // Data is a live Firestore stream; this just gives feedback.
                onRefresh: () =>
                    Future.delayed(const Duration(milliseconds: 600)),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  itemCount: items.length,
                  itemBuilder: (_, i) => IncidentCard(
                    incident: items[i],
                    onTap: () => openIncident(context, items[i].id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
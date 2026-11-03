import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/incident_list_view.dart';

class ReportsTab extends StatelessWidget {
  final bool showMine;
  const ReportsTab({super.key, this.showMine = true});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().appUser?.uid;

    final body = showMine
        ? DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.muted,
                  indicatorColor: AppColors.primary,
                  dividerColor: AppColors.border,
                  tabs: [Tab(text: 'All reports'), Tab(text: 'My reports')],
                ),
                Expanded(
                  child: TabBarView(children: [
                    const IncidentListView(),
                    IncidentListView(reporterId: uid),
                  ]),
                ),
              ],
            ),
          )
        : const IncidentListView();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Reports',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink)),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
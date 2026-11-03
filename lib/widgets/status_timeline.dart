import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/incident.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class StatusTimeline extends StatelessWidget {
  final String status;
  final List<StatusEntry> history;
  const StatusTimeline(
      {super.key, required this.status, required this.history});

  Widget _dot(bool done, bool current) {
    if (done) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
            color: AppColors.primary, shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
            color: current ? AppColors.primary : AppColors.border,
            width: current ? 3 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = AppConstants.statuses;
    final idx = steps.indexOf(status);
    final current = idx < 0 ? 0 : idx;
    final last = steps.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (i) {
        final done = i < current || (i == current && i == last);
        final isCurrent = i == current && !done;
        final reached = i <= current;
        final entries = history.where((h) => h.status == steps[i]);
        final date =
            entries.isEmpty ? null : DateFormat('d MMM').format(entries.last.at);

        return Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 26,
                child: Row(
                  children: [
                    Expanded(
                      child: i == 0
                          ? const SizedBox()
                          : Container(
                              height: 3,
                              color: reached
                                  ? AppColors.primary
                                  : AppColors.border),
                    ),
                    _dot(done, isCurrent),
                    Expanded(
                      child: i == last
                          ? const SizedBox()
                          : Container(
                              height: 3,
                              color: i < current
                                  ? AppColors.primary
                                  : AppColors.border),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(steps[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: reached ? FontWeight.w700 : FontWeight.w500,
                      color: reached ? AppColors.ink : AppColors.muted)),
              if (date != null)
                Text(date,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.muted)),
            ],
          ),
        );
      }),
    );
  }
}
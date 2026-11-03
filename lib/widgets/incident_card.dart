import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../utils/app_theme.dart';
import '../utils/category_style.dart';
import '../utils/formatters.dart';
import 'status_chip.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;
  const IncidentCard({super.key, required this.incident, required this.onTap});

  Widget _meta(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: AppColors.muted),
          const SizedBox(width: 4),
          Expanded(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
          ),
        ],
      );

  Widget _thumb() {
    final placeholder = Container(
      width: 56,
      height: 56,
      color: AppColors.primaryTint,
      child: Icon(categoryIcon(incident.category), color: AppColors.primary),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: incident.photoUrl == null
          ? placeholder
          : Image.network(incident.photoUrl!,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _thumb(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(incident.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink)),
                    const SizedBox(height: 4),
                    _meta(Icons.place_outlined, incident.location),
                    const SizedBox(height: 2),
                    _meta(Icons.schedule, timeAgo(incident.createdAt)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(incident.status),
            ],
          ),
        ),
      ),
    );
  }
}
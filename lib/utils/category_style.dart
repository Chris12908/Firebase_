import 'package:flutter/material.dart';

IconData categoryIcon(String category) {
  switch (category) {
    case 'Facilities':
      return Icons.apartment_rounded;
    case 'Water':
      return Icons.water_drop_outlined;
    case 'Electricity':
      return Icons.bolt_rounded;
    case 'Furniture':
      return Icons.chair_alt_outlined;
    case 'Sanitation':
      return Icons.delete_outline_rounded;
    case 'Safety':
      return Icons.shield_outlined;
    default:
      return Icons.report_problem_outlined;
  }
}
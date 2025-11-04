import 'package:intl/intl.dart';

/// Formats a game map to display a readable title.
/// If title is empty or null, generates a readable date/time from schedules.
/// Example: "November 9, 2025 | 5:00AM-1:00PM"
String formatGameTitle(Map game) {
  final title = game['title']?.toString().trim() ?? '';
  if (title.isNotEmpty) return title;
  
  // Generate readable date/time from schedules
  final schedules = game['schedules'] as List?;
  if (schedules == null || schedules.isEmpty) {
    return game['createdAt']?.toString() ?? 'Game';
  }
  
  // Use the first schedule for the date
  final firstSchedule = schedules.first;
  final start = DateTime.parse(firstSchedule['start']);
  final end = DateTime.parse(firstSchedule['end']);
  
  final dateFormat = DateFormat('MMMM d, y');
  final timeFormat = DateFormat('h:mma');
  
  return '${dateFormat.format(start)} | ${timeFormat.format(start)}-${timeFormat.format(end)}';
}

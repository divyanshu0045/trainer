import 'package:intl/intl.dart';

class AppHelpers {
  // Formats a DateTime object into a user-friendly string (e.g., "September 28, 2025")
  static String formatDate(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  // Formats a DateTime object into a shorter string (e.g., "Sep 28")
  static String formatShortDate(DateTime date) {
    return DateFormat.MMMd().format(date);
  }

  // Capitalizes the first letter of a string
  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
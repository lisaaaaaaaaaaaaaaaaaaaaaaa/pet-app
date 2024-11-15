import 'package:intl/intl.dart';

class DateFormatter {
  // Date Formats
  static final DateFormat _fullDate = DateFormat('MMMM d, y');
  static final DateFormat _shortDate = DateFormat('MMM d, y');
  static final DateFormat _monthDay = DateFormat('MMM d');
  static final DateFormat _dayMonth = DateFormat('d MMM');
  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _timeShort = DateFormat('h:mm');
  static final DateFormat _dateTime = DateFormat('MMM d, y h:mm a');
  static final DateFormat _apiDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _apiDateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");

  // Format date to full format (e.g., "September 15, 2023")
  static String toFullDate(DateTime date) {
    return _fullDate.format(date);
  }

  // Format date to short format (e.g., "Sep 15, 2023")
  static String toShortDate(DateTime date) {
    return _shortDate.format(date);
  }

  // Format to month and day (e.g., "Sep 15")
  static String toMonthDay(DateTime date) {
    return _monthDay.format(date);
  }

  // Format to day and month (e.g., "15 Sep")
  static String toDayMonth(DateTime date) {
    return _dayMonth.format(date);
  }

  // Format time (e.g., "2:30 PM")
  static String toTime(DateTime date) {
    return _time.format(date);
  }

  // Format time without period (e.g., "14:30")
  static String toTimeShort(DateTime date) {
    return _timeShort.format(date);
  }

  // Format date and time (e.g., "Sep 15, 2023 2:30 PM")
  static String toDateTime(DateTime date) {
    return _dateTime.format(date);
  }

  // Format for API (e.g., "2023-09-15")
  static String toApiDate(DateTime date) {
    return _apiDate.format(date);
  }

  // Format for API with time (e.g., "2023-09-15T14:30:00.000Z")
  static String toApiDateTime(DateTime date) {
    return _apiDateTime.format(date.toUtc());
  }

  // Get relative time (e.g., "2 hours ago", "5 minutes ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Get next occurrence of time
  static DateTime getNextOccurrence(TimeOfDay time) {
    final now = DateTime.now();
    var nextDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (nextDate.isBefore(now)) {
      nextDate = nextDate.add(const Duration(days: 1));
    }

    return nextDate;
  }

  // Format duration (e.g., "2h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Get age from date of birth
  static String getAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    final age = now.difference(dateOfBirth);
    final years = (age.inDays / 365).floor();
    final months = ((age.inDays % 365) / 30).floor();

    if (years > 0) {
      return '$years ${years == 1 ? 'year' : 'years'}';
    } else {
      return '$months ${months == 1 ? 'month' : 'months'}';
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Get readable date (Today, Yesterday, or formatted date)
  static String getReadableDate(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return toShortDate(date);
    }
  }

  // Format date range (e.g., "Sep 15 - Sep 20, 2023")
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${_monthDay.format(start)} - ${_dayMonth.format(end)}, ${start.year}';
    } else if (start.year == end.year) {
      return '${_monthDay.format(start)} - ${_monthDay.format(end)}, ${start.year}';
    } else {
      return '${_shortDate.format(start)} - ${_shortDate.format(end)}';
    }
  }

  // Do not instantiate this class
  DateFormatter._();
}
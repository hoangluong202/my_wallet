class DateFormatter {
  static String formatDate(DateTime date) {
    const monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${monthNames[date.month]} ${date.year}';
  }

  static String formatDateRange(DateTime start, DateTime end) {
    const monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (start.year == end.year && start.month == end.month) {
      return '${start.day}–${end.day} ${monthNames[start.month]} ${start.year}';
    }
    if (start.year == end.year) {
      return '${start.day} ${monthNames[start.month]} – '
          '${end.day} ${monthNames[end.month]} ${end.year}';
    }
    return '${formatDate(start)} – ${formatDate(end)}';
  }

  static String formatDuration(DateTime lastUpdated) {
    final duration = DateTime.now().difference(lastUpdated);

    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minutes ago';
    }
    if (duration.inHours < 24) {
      return '${duration.inHours} hours ago';
    }
    if (duration.inDays < 7) {
      return '${duration.inDays} days ago';
    }
    return '${duration.inDays ~/ 7} weeks ago';
  }
}

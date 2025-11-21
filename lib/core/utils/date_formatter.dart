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

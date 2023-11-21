class LogNameUtil {
  final String _prefix;

  LogNameUtil(this._prefix);

  String logNameFromDate(DateTime now) {
    final date = '${now.year}_${now.month}_${now.day}';
    return '$_prefix-logs-$date';
  }

  DateTime? dateFromLogName(String log) {
    try {
      final date = log.split('-').last;
      final parts = date.split('_');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } catch (e) {
      return null;
    }
  }
}

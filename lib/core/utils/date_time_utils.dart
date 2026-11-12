/// Date formatting and maths shared across the app.
abstract final class DateTimeUtils {
  static const months = [
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

  static const fullMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// Midnight of [d], so comparisons ignore the time of day.
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime get today => dateOnly(DateTime.now());

  /// "5 Oct 2026".
  static String day(DateTime d) => '${d.day} ${months[d.month - 1]} ${d.year}';

  /// "Oct 2026".
  static String monthYear(DateTime d) => '${months[d.month - 1]} ${d.year}';

  /// "Mon".
  static String weekday(DateTime d) => weekdays[d.weekday - 1];

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  /// [d] moved by [years], clamping Feb 29 to Feb 28 when needed.
  static DateTime addYears(DateTime d, int years) {
    final year = d.year + years;
    final day = d.day.clamp(1, daysInMonth(year, d.month));
    return DateTime(year, d.month, day);
  }

  /// How far [d] is from today: "Today", "In 3 days", "In 1 yr 11 mos",
  /// "2 mos ago".
  static String relative(DateTime d) {
    final now = today;
    final target = dateOnly(d);
    if (target == now) return 'Today';
    final future = target.isAfter(now);
    final from = future ? now : target;
    final to = future ? target : now;

    var monthsApart = (to.year - from.year) * 12 + to.month - from.month;
    if (to.day < from.day) monthsApart--;

    String text;
    if (monthsApart < 1) {
      final days = to.difference(from).inDays;
      text = days == 1 ? '1 day' : '$days days';
    } else {
      final y = monthsApart ~/ 12;
      final m = monthsApart % 12;
      text = [
        if (y > 0) y == 1 ? '1 yr' : '$y yrs',
        if (m > 0) m == 1 ? '1 mo' : '$m mos',
      ].join(' ');
    }
    return future ? 'In $text' : '$text ago';
  }
}

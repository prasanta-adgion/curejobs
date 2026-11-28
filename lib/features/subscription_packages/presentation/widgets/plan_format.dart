/// Formatting helpers for plan prices, durations and dates.
abstract final class PackageFormat {
  static String price(int amountMinor, {String currency = 'INR'}) {
    final symbol = currency == 'INR' ? '₹' : '$currency ';
    final value = amountMinor / 100;
    final whole = value == value.roundToDouble();
    return '$symbol${_group(whole ? value.round().toString() : value.toStringAsFixed(2))}';
  }

  static String duration(int days) {
    if (days <= 0) return '';
    if (days % 365 == 0) return days == 365 ? '1 year' : '${days ~/ 365} years';
    if (days % 30 == 0) return days == 30 ? '1 month' : '${days ~/ 30} months';
    if (days % 7 == 0) return days == 7 ? '1 week' : '${days ~/ 7} weeks';
    return days == 1 ? '1 day' : '$days days';
  }

  static String count(int? n) => n == null ? '—' : _group(n.toString());

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String date(DateTime d) {
    final l = d.toLocal();
    return '${l.day} ${_months[l.month - 1]} ${l.year}';
  }

  /// "Free Candidate Plan" → "Free", "Candidate Starter Plan" → "Starter".
  static String shortName(String name) {
    final s = name.replaceAll(RegExp(r'\b(Candidate|Plan)\b'), '').trim();
    return s.replaceAll(RegExp(r'\s+'), ' ').isEmpty ? name : s;
  }

  /// Indian digit grouping: 100000 → 1,00,000.
  static String _group(String s) {
    final parts = s.split('.');
    final digits = parts.first;
    if (digits.length <= 3) return s;
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    final grouped = '${groups.join(',')},$last3';
    return parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
  }
}

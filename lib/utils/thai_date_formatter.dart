const _thaiMonths = <String>[
  'มกราคม',
  'กุมภาพันธ์',
  'มีนาคม',
  'เมษายน',
  'พฤษภาคม',
  'มิถุนายน',
  'กรกฎาคม',
  'สิงหาคม',
  'กันยายน',
  'ตุลาคม',
  'พฤศจิกายน',
  'ธันวาคม',
];

String formatThaiDate(DateTime date) {
  final localDate = date.toLocal();
  final day = localDate.day.toString().padLeft(2, '0');
  final month = _thaiMonths[localDate.month - 1];
  final buddhistYear = localDate.year + 543;
  return '$day $month $buddhistYear';
}

String formatThaiDateRange(DateTime start, DateTime? end) {
  final startText = formatThaiDate(start);
  if (end == null) return startText;
  return '$startText - ${formatThaiDate(end)}';
}

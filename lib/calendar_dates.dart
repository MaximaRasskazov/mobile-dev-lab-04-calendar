//Обычные функции, то есть без виджетов

int daysInMonth(int year, int month) {
  // Нулевой день следующего месяца — последний день текущего
  return DateTime(year, month + 1, 0).day;
}

int firstDayOffset(int year, int month) {
  // понедельник = 1. Для сетки нужен отступ от 0 до 6
  return DateTime(year, month, 1).weekday - 1;
}

bool sameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year.toString().padLeft(4, '0')}';
}

String formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

DateTime? parseDate(String text) {
  final parts = text.trim().split('.');
  if (parts.length != 3 ||
      parts[0].length != 2 ||
      parts[1].length != 2 ||
      parts[2].length != 4) {
    return null;
  }
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) {
    return null;
  }
  if (year < 1 || month < 1 || month > 12 || day < 1) {
    return null;
  }
  if (day > daysInMonth(year, month)) {
    return null;
  }
  return DateTime(year, month, day);
}

int? parseTime(String text) {
  final parts = text.trim().split(':');
  if (parts.length != 2 || parts[0].length != 2 || parts[1].length != 2) {
    return null;
  }
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return null;
  }
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    return null;
  }
  return hour * 60 + minute;
}

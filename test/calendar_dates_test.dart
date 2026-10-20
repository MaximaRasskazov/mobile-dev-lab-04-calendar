import 'package:flutter_test/flutter_test.dart';
import 'package:l4_calendar/calendar_dates.dart';

void main() {
  test('Months contain 28, 29, 30 or 31 days', () {
    expect(daysInMonth(2026, 2), 28);
    expect(daysInMonth(2024, 2), 29);
    expect(daysInMonth(2026, 4), 30);
    expect(daysInMonth(2026, 1), 31);
    expect(daysInMonth(1900, 2), 28);
    expect(daysInMonth(2000, 2), 29);
    expect(daysInMonth(2100, 2), 28);
    expect(daysInMonth(2026, 12), 31);
  });

  test('Week starts on Monday and Sunday has six empty cells', () {
    expect(firstDayOffset(2026, 6), 0);
    expect(firstDayOffset(2026, 2), 6);
  });

  test('Day comparison ignores hours but includes month and year', () {
    expect(
      sameDay(DateTime(2026, 10, 20, 8), DateTime(2026, 10, 20, 21)),
      isTrue,
    );
    expect(sameDay(DateTime(2026, 10, 20), DateTime(2026, 11, 20)), isFalse);
    expect(sameDay(DateTime(2026, 10, 20), DateTime(2025, 10, 20)), isFalse);
  });

  test('Date parser rejects nonexistent days and invalid formats', () {
    expect(parseDate('29.02.2024'), DateTime(2024, 2, 29));
    for (final value in [
      '',
      '29.02.2026',
      '31.04.2026',
      '00.10.2026',
      '01.13.2026',
      '01.00.2026',
      '01.01.0000',
      '1.01.2026',
      '2026-10-20',
      'aa.bb.cccc',
    ]) {
      expect(parseDate(value), isNull, reason: value);
    }
  });

  test('Time parser accepts day boundaries and rejects impossible time', () {
    expect(parseTime('00:00'), 0);
    expect(parseTime('23:59'), 1439);
    expect(parseTime('09:05'), 545);
    for (final value in ['', '24:00', '09:60', '9:00', '10.30', 'aa:bb']) {
      expect(parseTime(value), isNull, reason: value);
    }
  });

  test('Formatting preserves leading zeros', () {
    expect(formatDate(DateTime(2026, 2, 3)), '03.02.2026');
    expect(formatTime(DateTime(2026, 2, 3, 9, 5)), '09:05');
  });
}

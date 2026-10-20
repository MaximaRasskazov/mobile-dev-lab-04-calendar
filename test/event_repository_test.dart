import 'package:flutter_test/flutter_test.dart';
import 'package:l4_calendar/models/calendar_event.dart';
import 'package:l4_calendar/repositories/event_repository.dart';

void main() {
  test(
    'Events of one day are separated from other dates and sorted by time',
    () {
      final repository = EventRepository();
      repository.addEvent(
        CalendarEvent(title: 'Вечер', start: DateTime(2026, 10, 20, 19)),
      );
      repository.addEvent(
        CalendarEvent(title: 'Утро', start: DateTime(2026, 10, 20, 8)),
      );
      repository.addEvent(
        CalendarEvent(title: 'Другой день', start: DateTime(2026, 10, 21, 8)),
      );
      final events = repository.getEventsForDay(DateTime(2026, 10, 20));
      expect(events.map((event) => event.title), ['Утро', 'Вечер']);
      expect(repository.getEventsForDay(DateTime(2026, 11, 20)), isEmpty);
      expect(repository.getEventsForDay(DateTime(2025, 10, 20)), isEmpty);
    },
  );

  test('Duplicate titles have different IDs and only the selected event is deleted', () {
    final repository = EventRepository();
    final first = CalendarEvent(
      title: 'Событие',
      start: DateTime(2026, 10, 20),
    );
    final second = CalendarEvent(
      title: 'Событие',
      start: DateTime(2026, 10, 20),
    );
    repository.addEvent(first);
    repository.addEvent(second);
    expect(first.id, isNot(second.id));
    repository.deleteEvent(first);
    expect(repository.getEventsForDay(first.start).single.id, second.id);
  });

  test('Editing retains ID and moves the event to its new day', () {
    final repository = EventRepository();
    final original = CalendarEvent(
      title: 'Учёба',
      start: DateTime(2026, 10, 20, 9),
    );
    repository.addEvent(original);
    final updated = CalendarEvent(
      id: original.id,
      title: 'Работа',
      start: DateTime(2026, 10, 21, 10),
      end: DateTime(2026, 10, 21, 11),
      category: 'Работа',
    );
    repository.updateEvent(updated);
    expect(repository.getEventsForDay(original.start), isEmpty);
    final restored = repository.getEventsForDay(updated.start).single;
    expect(restored.id, original.id);
    expect(restored.title, 'Работа');
    expect(restored.category, 'Работа');
    expect(restored.end, DateTime(2026, 10, 21, 11));
  });
}

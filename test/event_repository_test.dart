import 'package:flutter_test/flutter_test.dart';
import 'package:l4_calendar/models/calendar_event.dart';
import 'package:l4_calendar/repositories/event_repository.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('Reload restores all event fields and the next available ID', () async {
    final repository = EventRepository();
    final first = CalendarEvent(
      title: 'Первое',
      start: DateTime(2026, 10, 20, 8),
    );
    final second = CalendarEvent(
      title: 'Второе',
      start: DateTime(2026, 10, 20, 12),
      end: DateTime(2026, 10, 20, 13, 30),
      colorName: 'Оранжевый',
    );
    repository.addEvent(first);
    repository.addEvent(second);
    await repository.saveEvents();
    final restored = EventRepository();
    await restored.loadEvents();
    final events = restored.getEventsForDay(first.start);
    expect(events.first.end, isNull);
    expect(events.last.toJson(), second.toJson());
    final third = CalendarEvent(title: 'Третье', start: first.start);
    restored.addEvent(third);
    expect(third.id, greaterThan(second.id));
    await restored.loadEvents();
    expect(restored.getEventsForDay(first.start), hasLength(2));
  });

  test(
    'Edits and deletion are saved including moving an event to another date',
    () async {
      final repository = EventRepository();
      final event = CalendarEvent(
        title: 'Событие',
        start: DateTime(2026, 10, 20, 9),
      );
      repository.addEvent(event);
      await repository.saveEvents();
      final updated = CalendarEvent(
        id: event.id,
        title: 'Изменено',
        start: DateTime(2026, 10, 21, 10),
        colorName: 'Зелёный',
      );
      repository.updateEvent(updated);
      await repository.saveEvents();
      final restored = EventRepository();
      await restored.loadEvents();
      expect(restored.getEventsForDay(event.start), isEmpty);
      final saved = restored.getEventsForDay(updated.start).single;
      expect(saved.toJson(), updated.toJson());
      restored.deleteEvent(saved);
      await restored.saveEvents();
      await repository.loadEvents();
      expect(repository.getEventsForDay(updated.start), isEmpty);
    },
  );
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
      colorName: 'Зелёный',
    );
    repository.updateEvent(updated);
    expect(repository.getEventsForDay(original.start), isEmpty);
    final restored = repository.getEventsForDay(updated.start).single;
    expect(restored.id, original.id);
    expect(restored.title, 'Работа');
    expect(restored.colorName, 'Зелёный');
    expect(restored.end, DateTime(2026, 10, 21, 11));
  });
}

import '../calendar_dates.dart';
import '../models/calendar_event.dart';

class EventRepository {
  final List<CalendarEvent> _events = [];
  int nextId = 1;

  List<CalendarEvent> getEventsForDay(DateTime date) {
    final List<CalendarEvent> result = [];
    for (final event in _events) {
      if (sameDay(event.start, date)) {
        result.add(event);
      }
    }
    result.sort((first, second) {
      return first.start.compareTo(second.start);
    });
    return result;
  }

  void addEvent(CalendarEvent event) {
    event.id = nextId;
    nextId++;
    _events.add(event);
  }

  void updateEvent(CalendarEvent updatedEvent) {
    for (int index = 0; index < _events.length; index++) {
      if (_events[index].id == updatedEvent.id) {
        _events[index] = updatedEvent;
        return;
      }
    }
  }

  void deleteEvent(CalendarEvent event) {
    _events.remove(event);
  }
}

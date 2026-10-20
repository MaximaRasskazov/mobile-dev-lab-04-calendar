import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../calendar_dates.dart';
import '../models/calendar_event.dart';

class EventRepository {
  final List<CalendarEvent> _events = [];
  int nextId = 1;
  final preferences = SharedPreferencesAsync();
  final storageKey = 'calendar_events';

  Future<void> loadEvents() async {
    final saved = await preferences.getString(storageKey);
    final List<CalendarEvent> loaded = [];
    int loadedNextId = 1;
    if (saved != null) {
      final List<dynamic> data = jsonDecode(saved);
      for (final item in data) {
        final event = CalendarEvent.fromJson(item as Map<String, dynamic>);
        loaded.add(event);
        if (event.id >= loadedNextId) {
          loadedNextId = event.id + 1;
        }
      }
    }
    // Меняем список только после успешного чтения всех событий.
    _events.clear();
    _events.addAll(loaded);
    nextId = loadedNextId;
  }

  Future<void> saveEvents() async {
    final List<Map<String, dynamic>> data = [];
    for (final event in _events) {
      data.add(event.toJson());
    }
    await preferences.setString(storageKey, jsonEncode(data));
  }

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

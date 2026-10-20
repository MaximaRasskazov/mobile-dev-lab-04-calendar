class CalendarEvent {
  int id;
  String title;
  DateTime start;
  DateTime? end;

  CalendarEvent({
    this.id = 0,
    required this.title,
    required this.start,
    this.end,
  });
}

class CalendarEvent {
  int id;
  String title;
  DateTime start;
  DateTime? end;
  String category;

  CalendarEvent({
    this.id = 0,
    required this.title,
    required this.start,
    this.end,
    this.category = 'Учёба',
  });
}

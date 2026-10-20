class CalendarEvent {
  int id;
  String title;
  DateTime start;
  DateTime? end;
  String colorName;

  CalendarEvent({
    this.id = 0,
    required this.title,
    required this.start,
    this.end,
    this.colorName = 'Синий',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start': start.toIso8601String(),
      'end': end?.toIso8601String(),
      'colorName': colorName,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> data) {
    DateTime? end;
    if (data['end'] != null) {
      end = DateTime.parse(data['end'] as String);
    }
    return CalendarEvent(
      id: data['id'] as int,
      title: data['title'] as String,
      start: DateTime.parse(data['start'] as String),
      end: end,
      colorName: data['colorName'] as String,
    );
  }
}

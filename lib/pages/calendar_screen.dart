import 'package:flutter/material.dart';

import '../calendar_dates.dart';
import '../models/calendar_event.dart';
import '../repositories/event_repository.dart';
import 'event_form_page.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() {
    return CalendarState();
  }
}

class CalendarState extends State<CalendarScreen> {
  final repository = EventRepository();
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  final monthNames = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];
  final weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  void changeMonth(int step) {
    final next = DateTime(currentMonth.year, currentMonth.month + step);
    if (next.year < 1 || next.year > 9999) {
      return;
    }
    setState(() {
      currentMonth = next;
      selectedDate = next;
    });
  }

  Future<void> openForm(CalendarEvent? event) async {
    final result = await Navigator.push<CalendarEvent>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EventFormPage(selectedDate: selectedDate, event: event);
        },
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    setState(() {
      if (event == null) {
        repository.addEvent(result);
      } else {
        repository.updateEvent(result);
      }
      selectedDate = DateTime(
        result.start.year,
        result.start.month,
        result.start.day,
      );
      currentMonth = DateTime(result.start.year, result.start.month);
    });
  }

  Widget buildCalendar() {
    final offset = firstDayOffset(currentMonth.year, currentMonth.month);
    final count = daysInMonth(currentMonth.year, currentMonth.month);
    final cellCount = ((offset + count + 6) ~/ 7) * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 48,
      ),
      itemCount: cellCount,
      itemBuilder: (context, index) {
        final day = index - offset + 1;
        if (day < 1 || day > count) {
          return const SizedBox.shrink();
        }
        final date = DateTime(currentMonth.year, currentMonth.month, day);
        Color background = Colors.transparent;
        Color textColor = Colors.black87;
        if (sameDay(date, selectedDate)) {
          background = Colors.blue;
          textColor = Colors.white;
        }
        return Padding(
          padding: const EdgeInsets.all(2),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: background,
              foregroundColor: textColor,
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              setState(() {
                selectedDate = date;
              });
            },
            child: Text('$day'),
          ),
        );
      },
    );
  }

  Widget buildEventCard(CalendarEvent event) {
    String time = formatTime(event.start);
    final end = event.end;
    if (end != null) {
      time = '$time — ${formatTime(end)}';
    }
    return Card(
      child: ListTile(
        title: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(time),
        onTap: () {
          openForm(event);
        },
        trailing: PopupMenuButton<String>(
          tooltip: 'Действия с событием',
          onSelected: (action) {
            if (action == 'edit') {
              openForm(event);
            } else if (action == 'delete') {
              setState(() {
                repository.deleteEvent(event);
              });
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(value: 'edit', child: Text('Редактировать')),
              PopupMenuItem(value: 'delete', child: Text('Удалить')),
            ];
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = repository.getEventsForDay(selectedDate);
    return Scaffold(
      appBar: AppBar(title: const Text('Календарь')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Предыдущий месяц',
                  onPressed: () {
                    changeMonth(-1);
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    '${monthNames[currentMonth.month - 1]} ${currentMonth.year}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Следующий месяц',
                  onPressed: () {
                    changeMonth(1);
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final day in weekDays)
                  Expanded(child: Text(day, textAlign: TextAlign.center)),
              ],
            ),
            const SizedBox(height: 8),
            buildCalendar(),
            const SizedBox(height: 16),
            Text(
              'События на ${formatDate(selectedDate)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (events.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('На этот день событий нет'),
              ),
            for (final event in events) buildEventCard(event),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Добавить событие',
        onPressed: () {
          openForm(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

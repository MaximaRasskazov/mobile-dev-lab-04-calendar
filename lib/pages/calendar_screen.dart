import 'package:flutter/material.dart';

import '../calendar_dates.dart';
import '../event_colors.dart';
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
  bool isLoading = true;
  bool isSaving = false;
  String? loadError;
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

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });
    String? error;
    try {
      await repository.loadEvents();
    } catch (exception) {
      error = 'Не удалось загрузить события. Нажмите «Повторить».';
    }
    if (!mounted) {
      return;
    }
    setState(() {
      isLoading = false;
      loadError = error;
    });
  }

  Future<void> saveEvents() async {
    setState(() {
      isSaving = true;
    });
    try {
      await repository.saveEvents();
    } catch (exception) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Не удалось сохранить. Изменения пока только в памяти.',
            ),
            action: SnackBarAction(label: 'Повторить', onPressed: saveEvents),
          ),
        );
      }
    }
    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  void selectToday() {
    setState(() {
      selectedDate = DateTime.now();
      currentMonth = DateTime(selectedDate.year, selectedDate.month);
    });
  }

  void changeMonth(int step) {
    final next = DateTime(currentMonth.year, currentMonth.month + step);
    if (next.year < 1 || next.year > 9999) {
      return;
    }
    setState(() {
      currentMonth = next;
    });
  }

  Widget buildYearDropdown() {
    final currentYear = currentMonth.year;
    int firstYear = currentYear - 100;
    int lastYear = currentYear + 100;

    return DropdownButton<int>(
      value: currentYear,
      isDense: true,
      menuMaxHeight: 320,
      underline: const SizedBox.shrink(),
      items: [
        // две сотни
        for (int year = firstYear; year <= lastYear; year++)
          DropdownMenuItem<int>(value: year, child: Text('$year')),
      ],
      onChanged: (int? year) {
        if (year == null || year == currentYear) {
          return;
        }

        // учитываем, что в некоторых месяцах дней меньше
        int day = selectedDate.day;
        int maxDay = daysInMonth(year, currentMonth.month);
        if (day > maxDay) {
          day = maxDay;
        }

        setState(() {
          currentMonth = DateTime(year, currentMonth.month);
          selectedDate = DateTime(year, currentMonth.month, day);
        });
      },
    );
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
    await saveEvents();
  }

  Widget buildCalendar() {
    final today = DateTime.now();
    // посчитаем, кол-во ячеек перед ПЕРВЫМ числом, чтобы покрасить в серый
    // для этого возращаем today-1
    final offset = firstDayOffset(currentMonth.year, currentMonth.month);
    final count = daysInMonth(currentMonth.year, currentMonth.month);
    // считаем общее кол-во ячеек (+6 для округления вверх)
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
        // DateTime сам переводит день 0 и отрицательные дни в прошлый месяц.
        final date = DateTime(currentMonth.year, currentMonth.month, day);
        Color background = Colors.transparent;
        Color textColor = const Color(0xFFE8EAED);
        if (date.month != currentMonth.month) {
          textColor = const Color(0xFF777B82);
        }
        Color markerColor = Colors.transparent;
        BorderSide border = BorderSide.none;
        if (sameDay(date, today)) {
          border = const BorderSide(color: Colors.blue);
        }
        if (repository.getEventsForDay(date).isNotEmpty) {
          markerColor = Colors.blue;
        }
        if (sameDay(date, selectedDate)) {
          background = Colors.blue;
          textColor = Colors.white;
          if (markerColor != Colors.transparent) {
            markerColor = Colors.white;
          }
        }
        return Padding(
          padding: const EdgeInsets.all(2),
          child: TextButton(
            key: ValueKey(date),
            style: TextButton.styleFrom(
              backgroundColor: background,
              foregroundColor: textColor,
              side: border,
              padding: EdgeInsets.zero,
            ),
            onPressed: date.year < 1 || date.year > 9999
                ? null
                : () {
                    setState(() {
                      selectedDate = date;
                      currentMonth = DateTime(date.year, date.month);
                    });
                  },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('${date.day}', maxLines: 1),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: markerColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
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
        leading: Icon(
          Icons.circle,
          color: eventColors[event.colorName],
          size: 14,
        ),
        title: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(time),
        onTap: isSaving
            ? null
            : () {
                openForm(event);
              },
        trailing: PopupMenuButton<String>(
          enabled: !isSaving,
          tooltip: 'Действия с событием',
          onSelected: (action) async {
            if (action == 'edit') {
              openForm(event);
            } else if (action == 'delete') {
              setState(() {
                repository.deleteEvent(event);
              });
              await saveEvents();
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
      appBar: AppBar(
        title: const Text('Календарь'),
        actions: [
          TextButton(onPressed: selectToday, child: const Text('Сегодня')),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
          children: [
            if (isLoading || isSaving) const LinearProgressIndicator(),
            if (loadError != null)
              Column(
                children: [
                  Text(loadError!),
                  TextButton(
                    onPressed: loadEvents,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          monthNames[currentMonth.month - 1],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      buildYearDropdown(), //звоним брату, просим выпадаюзий список
                    ],
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
        onPressed: isLoading || isSaving || loadError != null
            ? null
            : () {
                openForm(null);
              },
        child: const Icon(Icons.add),
      ),
    );
  }
}

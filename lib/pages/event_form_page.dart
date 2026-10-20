import 'package:flutter/material.dart';

import '../calendar_dates.dart';
import '../models/calendar_event.dart';

class EventFormPage extends StatefulWidget {
  final DateTime selectedDate;
  final CalendarEvent? event;

  const EventFormPage({super.key, required this.selectedDate, this.event});

  @override
  State<EventFormPage> createState() {
    return _EventFormPageState();
  }
}

class _EventFormPageState extends State<EventFormPage> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final startController = TextEditingController(text: '09:00');
  final endController = TextEditingController();
  String category = 'Учёба';

  @override
  void initState() {
    super.initState();
    dateController.text = formatDate(widget.selectedDate);
    final event = widget.event;
    if (event != null) {
      category = event.category;
      titleController.text = event.title;
      dateController.text = formatDate(event.start);
      startController.text = formatTime(event.start);
      final end = event.end;
      if (end != null) {
        endController.text = formatTime(end);
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    dateController.dispose();
    startController.dispose();
    endController.dispose();
    super.dispose();
  }

  void saveEvent() {
    if (!formKey.currentState!.validate()) {
      return;
    }
    final date = parseDate(dateController.text)!;
    final startMinutes = parseTime(startController.text)!;
    final start = DateTime(
      date.year,
      date.month,
      date.day,
      startMinutes ~/ 60,
      startMinutes % 60,
    );
    DateTime? end;
    if (endController.text.trim().isNotEmpty) {
      final endMinutes = parseTime(endController.text)!;
      end = DateTime(
        date.year,
        date.month,
        date.day,
        endMinutes ~/ 60,
        endMinutes % 60,
      );
    }
    int id = 0;
    final original = widget.event;
    if (original != null) {
      id = original.id;
    }
    final result = CalendarEvent(
      id: id,
      title: titleController.text.trim(),
      start: start,
      end: end,
      category: category,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = 'Новое событие';
    if (widget.event != null) {
      pageTitle = 'Редактирование события';
    }
    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Название'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите название события';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Дата (ДД.ММ.ГГГГ)',
                  ),
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || parseDate(value) == null) {
                      return 'Введите существующую дату: ДД.ММ.ГГГГ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: startController,
                  decoration: const InputDecoration(
                    labelText: 'Начало (ЧЧ:ММ)',
                  ),
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || parseTime(value) == null) {
                      return 'Введите время начала: ЧЧ:ММ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: endController,
                  decoration: const InputDecoration(
                    labelText: 'Окончание (ЧЧ:ММ)',
                    helperText: 'В тот же день, необязательно',
                  ),
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }
                    final end = parseTime(value);
                    final start = parseTime(startController.text);
                    if (end == null) {
                      return 'Введите время окончания: ЧЧ:ММ';
                    }
                    if (start != null && end <= start) {
                      return 'Окончание должно быть позже начала';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Категория'),
                  items: const [
                    DropdownMenuItem(value: 'Учёба', child: Text('Учёба')),
                    DropdownMenuItem(value: 'Работа', child: Text('Работа')),
                    DropdownMenuItem(value: 'Личное', child: Text('Личное')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        category = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: saveEvent,
                  child: const Text('Сохранить'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Отмена'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

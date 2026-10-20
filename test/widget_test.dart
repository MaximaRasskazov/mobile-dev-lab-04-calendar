import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l4_calendar/calendar_dates.dart';
import 'package:l4_calendar/main.dart';
import 'package:l4_calendar/pages/calendar_screen.dart';

Future<void> fillEvent(
  WidgetTester tester,
  String title, {
  String? date,
  String start = '09:00',
  String end = '',
}) async {
  await tester.enterText(find.byType(TextFormField).at(0), title);
  if (date != null) {
    await tester.enterText(find.byType(TextFormField).at(1), date);
  }
  await tester.enterText(find.byType(TextFormField).at(2), start);
  await tester.enterText(find.byType(TextFormField).at(3), end);
}

Future<void> saveEvent(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Сохранить'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Сохранить'));
  await tester.pumpAndSettle();
}

Future<void> openNewEvent(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

Future<void> chooseCategory(WidgetTester tester, String category) async {
  await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(category).last);
  await tester.pumpAndSettle();
}

Future<void> eventAction(
  WidgetTester tester,
  String title,
  String action,
) async {
  await tester.ensureVisible(find.text(title));
  await tester.pumpAndSettle();
  final card = find.ancestor(of: find.text(title), matching: find.byType(Card));
  await tester.tap(
    find.descendant(of: card, matching: find.byType(PopupMenuButton<String>)),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(action));
  await tester.pumpAndSettle();
}

Future<void> selectDay(WidgetTester tester, int day) async {
  final button = find.descendant(
    of: find.byType(GridView),
    matching: find.widgetWithText(TextButton, '$day'),
  );
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Manual grid handles leap February, date selection and year boundary',
    (tester) async {
      await tester.pumpWidget(const CalendarApp());
      final state = tester.state<CalendarState>(find.byType(CalendarScreen));
      state.changeMonth(
        (2024 - state.currentMonth.year) * 12 + 2 - state.currentMonth.month,
      );
      await tester.pumpAndSettle();
      expect(find.text('Февраль 2024'), findsOneWidget);
      final grid = tester.widget<GridView>(find.byType(GridView));
      expect(grid.childrenDelegate.estimatedChildCount, 35);
      expect(find.text('29'), findsOneWidget);
      expect(find.text('30'), findsNothing);
      await selectDay(tester, 29);
      expect(find.text('События на 29.02.2024'), findsOneWidget);
      await tester.tap(find.byTooltip('Следующий месяц'));
      await tester.pumpAndSettle();
      expect(find.text('Март 2024'), findsOneWidget);
      state.changeMonth(
        (2025 - state.currentMonth.year) * 12 + 12 - state.currentMonth.month,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Следующий месяц'));
      await tester.pumpAndSettle();
      expect(find.text('Январь 2026'), findsOneWidget);
      await tester.tap(find.byTooltip('Предыдущий месяц'));
      await tester.pumpAndSettle();
      expect(find.text('Декабрь 2025'), findsOneWidget);
      await tester.tap(find.text('Сегодня'));
      await tester.pumpAndSettle();
      expect(sameDay(state.selectedDate, DateTime.now()), isTrue);
    },
  );

  testWidgets(
    'Form rejects empty title, impossible dates, invalid times and end before start',
    (tester) async {
      await tester.pumpWidget(const CalendarApp());
      await openNewEvent(tester);
      await fillEvent(
        tester,
        '   ',
        date: '31.02.2026',
        start: '25:00',
        end: 'aa:bb',
      );
      await saveEvent(tester);
      expect(find.text('Введите название события'), findsOneWidget);
      expect(
        find.text('Введите существующую дату: ДД.ММ.ГГГГ'),
        findsOneWidget,
      );
      expect(find.text('Введите время начала: ЧЧ:ММ'), findsOneWidget);
      expect(find.text('Введите время окончания: ЧЧ:ММ'), findsOneWidget);
      await fillEvent(
        tester,
        'Лекция',
        date: '28.02.2026',
        start: '09:00',
        end: '09:00',
      );
      await saveEvent(tester);
      expect(find.text('Окончание должно быть позже начала'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(3), '08:59');
      await saveEvent(tester);
      expect(find.text('Окончание должно быть позже начала'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(3), '09:30');
      await saveEvent(tester);
      expect(find.text('Лекция'), findsOneWidget);
      expect(find.text('09:00 — 09:30 · Учёба'), findsOneWidget);
    },
  );

  testWidgets(
    'Several events, categories, moving a date, cancellation and deletion',
    (tester) async {
      await tester.pumpWidget(const CalendarApp());
      await openNewEvent(tester);
      await fillEvent(tester, 'Вечер', date: '20.10.2026', start: '18:00');
      await chooseCategory(tester, 'Личное');
      await saveEvent(tester);
      await openNewEvent(tester);
      await fillEvent(tester, '  Лекция  ', start: '09:00', end: '10:00');
      await saveEvent(tester);
      expect(find.text('Лекция'), findsOneWidget);
      expect(find.text('Вечер'), findsOneWidget);
      await tester.ensureVisible(find.text('Вечер'));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Лекция')).dy,
        lessThan(tester.getTopLeft(find.text('Вечер')).dy),
      );
      await selectDay(tester, 21);
      expect(find.text('Лекция'), findsNothing);
      expect(find.text('Вечер'), findsNothing);
      await selectDay(tester, 20);
      await eventAction(tester, 'Лекция', 'Редактировать');
      await fillEvent(
        tester,
        'Практика',
        date: '21.10.2026',
        start: '11:00',
        end: '12:00',
      );
      await chooseCategory(tester, 'Работа');
      await saveEvent(tester);
      expect(find.text('События на 21.10.2026'), findsOneWidget);
      expect(find.text('Практика'), findsOneWidget);
      expect(find.text('11:00 — 12:00 · Работа'), findsOneWidget);
      await eventAction(tester, 'Практика', 'Редактировать');
      await fillEvent(tester, 'Не сохранять', start: '15:00');
      await tester.ensureVisible(find.text('Отмена'));
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect(find.text('Практика'), findsOneWidget);
      await eventAction(tester, 'Практика', 'Удалить');
      expect(find.text('Практика'), findsNothing);
      await selectDay(tester, 20);
      expect(find.text('Вечер'), findsOneWidget);
    },
  );

  testWidgets(
    'Chosen day prefills the form and end time may be omitted or removed',
    (tester) async {
      await tester.pumpWidget(const CalendarApp());
      await selectDay(tester, 10);
      final state = tester.state<CalendarState>(find.byType(CalendarScreen));
      await openNewEvent(tester);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(1))
            .controller!
            .text,
        formatDate(state.selectedDate),
      );
      await fillEvent(tester, 'Встреча', start: '00:00', end: '23:59');
      await saveEvent(tester);
      await eventAction(tester, 'Встреча', 'Редактировать');
      await tester.enterText(find.byType(TextFormField).at(3), '');
      await saveEvent(tester);
      expect(find.text('00:00 · Учёба'), findsOneWidget);
      expect(
        state.repository.getEventsForDay(state.selectedDate).single.end,
        isNull,
      );
    },
  );

  testWidgets(
    'Small screen with six weeks, large text, long title and keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const CalendarApp());
      final state = tester.state<CalendarState>(find.byType(CalendarScreen));
      state.changeMonth(
        (2021 - state.currentMonth.year) * 12 + 8 - state.currentMonth.month,
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<GridView>(find.byType(GridView))
            .childrenDelegate
            .estimatedChildCount,
        42,
      );
      expect(tester.takeException(), isNull);
      await openNewEvent(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      await tester.pumpAndSettle();
      await fillEvent(tester, 'Очень длинное название события ' * 10);
      await saveEvent(tester);
      expect(find.byType(TextFormField), findsNothing);
      expect(
        state.repository.getEventsForDay(state.selectedDate),
        hasLength(1),
      );
      expect(tester.takeException(), isNull);
    },
  );
}

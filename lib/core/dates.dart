/// Calendar-day helpers. Google Tasks due values are date-only.
DateTime calendarDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime calendarToday([DateTime? now]) => calendarDay(now ?? DateTime.now());

bool isDueBeforeDay(DateTime? due, DateTime day) {
  if (due == null) return false;
  return calendarDay(due).isBefore(calendarDay(day));
}

bool isOverdue(DateTime? due, [DateTime? now]) {
  return isDueBeforeDay(due, calendarToday(now));
}

bool isDueOnDay(DateTime? due, DateTime day) {
  if (due == null) return false;
  return calendarDay(due) == calendarDay(day);
}

bool isDueToday(DateTime? due, [DateTime? now]) {
  return isDueOnDay(due, calendarToday(now));
}

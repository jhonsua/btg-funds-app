/// Value object inmutable con 2 campos. No usa Freezed
/// intencionalmente — no requiere copyWith, union types ni pattern
/// matching. Equality por valor implementada manualmente.
class DateRange {
  const DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  /// `true` si [date] cae dentro del rango con ambos extremos
  /// inclusivos: una transacción en exactamente [start] o en
  /// exactamente [end] cuenta como dentro.
  bool contains(DateTime date) => !date.isBefore(start) && !date.isAfter(end);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange($start → $end)';
}

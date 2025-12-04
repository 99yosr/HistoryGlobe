class HistoricalEvent {
  final String id;
  final String title;
  final String? description;
  final String? startDate;
  final String? endDate;

  HistoricalEvent({
    required this.id,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
  });
}

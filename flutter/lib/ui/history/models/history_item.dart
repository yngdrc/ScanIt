class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.title,
    required this.scannedAt,
  });

  final int id;
  final String title;
  final DateTime scannedAt;
}

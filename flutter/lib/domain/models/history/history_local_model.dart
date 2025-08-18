
import '../core/local_model.dart';

class HistoryLocalModel implements LocalModel {
  const HistoryLocalModel({
    required this.id,
    required this.title,
    required this.scannedAtMillis,
  });

  @override
  final int id;

  final String title;
  final int scannedAtMillis;

  HistoryLocalModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      title = json['title'] as String,
      scannedAtMillis = json['scannedAtMillis'] as int;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'scannedAtMillis': scannedAtMillis,
  };
}

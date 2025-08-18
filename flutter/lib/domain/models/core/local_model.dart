import 'package:uuid/uuid.dart';

abstract class LocalModel {
  const LocalModel({required this.uuid});

  final UuidValue uuid;
}
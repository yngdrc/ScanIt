import 'package:scanit/domain/models/core/local_model.dart';
import 'package:uuid/uuid.dart';

abstract class LocalRepository<T extends LocalModel> {
  const LocalRepository({required this.tableName});

  final String tableName;

  Future<T?> getById(UuidValue uuid);
  Future<List<T>> getAll();
  Future<int> insertOrReplace(T item);
  Future<int> delete(UuidValue uuid);
}

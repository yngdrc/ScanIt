import 'package:scanit/domain/models/core/local_model.dart';

abstract class LocalRepository<T extends LocalModel> {
  const LocalRepository({required this.tableName});

  final String tableName;

  Future<T?> getById(int id);
  Future<List<T>> getAll();
  Future<int> insertOrReplace(T item);
  Future<int> delete(int id);
}

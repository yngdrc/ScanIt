import 'package:scanit/domain/models/core/local_model.dart';
import 'package:scanit/utils/result.dart';

abstract class LocalRepository<T extends LocalModel> {
  const LocalRepository({required this.tableName});

  final String tableName;

  Future<Result<T>> getById(int id);
  Future<Result<List<T>>> getAll();
  Future<Result<int>> insertOrReplace(T item);
  Future<Result<int>> delete(int id);
}

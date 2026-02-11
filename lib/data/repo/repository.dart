import 'package:flutter/material.dart';
import 'package:flutter_todo_list/data/source/source.dart';

class Repository<T> extends ChangeNotifier implements DataSource {
  final DataSource<T> localDataSource;

  Repository(this.localDataSource);
  @override
  Future<T> createOrUpdate(data) async {
    final result = await localDataSource.createOrUpdate(data);
    notifyListeners();
    return result;
  }

  @override
  Future<void> delete(data) async {
    return await localDataSource.delete(data);
  }

  @override
  Future<void> deleteAll() async {
    await localDataSource.deleteAll();
    notifyListeners();
  }

  @override
  Future<void> deleteById(id) async {
    await localDataSource.deleteById(id);
  }

  @override
  Future<T> findById(id) async {
    return await localDataSource.findById(id);
  }

  @override
  Future<List<T>> getAll({String searchKeyWord = ''}) async {
    return await localDataSource.getAll(searchKeyWord: searchKeyWord);
  }
}

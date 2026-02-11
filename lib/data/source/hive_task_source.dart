import 'package:flutter_todo_list/data/data.dart';
import 'package:flutter_todo_list/data/source/source.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveTaskSource implements DataSource<TaskData>{
  final Box<TaskData> box;

  HiveTaskSource({required this.box});
  @override
  Future<TaskData> createOrUpdate(data) async{
    if (data.isInBox) {
      await data.save();
    } else {
      data.id = await box.add(data);
    }
    return data;
  }

  @override
  Future<void> delete(data) {
    return data.delete();
  }

  @override
  Future<void> deleteAll() {
    return box.clear();
  }

  @override
  Future<void> deleteById(id) {
    return box.delete(id);
  }

  @override
  Future<TaskData> findById(id) async {
    return box.values.firstWhere((element)=> element.id == id);
  }

  @override
  Future<List<TaskData>> getAll({String searchKeyWord = ''}) async{
    return box.values.where((task) => task.name.contains(searchKeyWord)).toList();
  }

}
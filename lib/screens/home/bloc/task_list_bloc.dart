import 'package:bloc/bloc.dart';
import 'package:flutter_todo_list/data/data.dart';
import 'package:flutter_todo_list/data/repo/repository.dart';
import 'package:meta/meta.dart';

part 'task_list_event.dart';
part 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final Repository<TaskData> repository;
  TaskListBloc(this.repository) : super(TaskListInitial()) {
    on<TaskListEvent>((event, emit) async {
      if (event is TaskListStarted || event is TaskListSearch) {
        emit(TaskListLoading());
        final String searchKeyword;
        if (event is TaskListSearch) {
          searchKeyword = event.searchPhrase;
        } else {
          searchKeyword = '';
        }

        try {
          final items = await repository.getAll(searchKeyWord: searchKeyword);
          if (items.isNotEmpty) {
            emit(TaskListSuccess(items));
          } else {
            emit(TaskListEmpty());
          }
        } catch (e) {
          emit(TaskListError(e.toString()));
        }
      }

      if (event is TaskListDeleteAll) {
        await repository.deleteAll();
        emit(TaskListEmpty());
      }

      if (event is TaskListDelete) {
        await repository.delete(event.task);
        final items = await repository.getAll(searchKeyWord: ''); 
        emit(TaskListSuccess(items));
      }
    });
  }
}

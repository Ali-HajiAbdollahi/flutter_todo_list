part of 'task_list_bloc.dart';

@immutable
sealed class TaskListEvent {}

final class TaskListStarted extends TaskListEvent{}

final class TaskListSearch extends TaskListEvent{
  final String searchPhrase;

  TaskListSearch(this.searchPhrase);
}

final class TaskListDeleteAll extends TaskListEvent{
}

final class TaskListDelete extends TaskListEvent{
  final TaskData task;

  TaskListDelete(this.task);

}
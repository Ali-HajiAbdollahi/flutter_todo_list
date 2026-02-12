import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todo_list/data/data.dart';
import 'package:flutter_todo_list/data/repo/repository.dart';
import 'package:flutter_todo_list/main.dart';
import 'package:flutter_todo_list/screens/edit/edit.dart';
import 'package:flutter_todo_list/screens/home/bloc/task_list_bloc.dart';
import 'package:flutter_todo_list/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) =>
                        TaskScreen(task: TaskData(), state: "Add Task"),
              ),
            );
          },
          label: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Add New Task"),
              SizedBox(width: 8),
              Icon(CupertinoIcons.add, size: 18),
            ],
          ),
        ),
        body: BlocProvider<TaskListBloc>(
          create:
              (context) => TaskListBloc(context.read<Repository<TaskData>>()),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeData.colorScheme.primary,
                        themeData.colorScheme.primaryContainer,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "To Do List",
                                style: themeData.textTheme.titleLarge!.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                CupertinoIcons.share,
                                color: themeData.colorScheme.surface,
                              ),
                            ],
                          ),
                        ),
                        const Expanded(flex: 2, child: SizedBox()),
                        Expanded(
                          flex: 3,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double availableHeight = constraints.maxHeight;

                              return Container(
                                padding: const EdgeInsets.fromLTRB(2, 6, 6, 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    availableHeight / 2,
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  cursorHeight: 20,
                                  cursorWidth: 1,
                                  onChanged: (value) {
                                    context.read<TaskListBloc>().add(
                                      TaskListSearch(value),
                                    );
                                  },
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      CupertinoIcons.search,
                                      size: 22,
                                    ),
                                    labelText: "Search",
                                    border: InputBorder.none,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer<Repository<TaskData>>(
                    builder: (
                      context,
                      Repository<TaskData> value,
                      Widget? child,
                    ) {
                      context.read<TaskListBloc>().add(TaskListStarted());
                      return BlocBuilder<TaskListBloc, TaskListState>(
                        builder: (context, state) {
                          if (state is TaskListSuccess) {
                            return TaskList(
                              items: state.items,
                              themeData: themeData,
                            );
                          } else if (state is TaskListEmpty) {
                            return const EmptyState();
                          } else if (state is TaskListLoading ||
                              state is TaskListInitial) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is TaskListError) {
                            return Center(child: Text(state.errorMessage));
                          } else {
                            throw Exception('State is not Valid.');
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  const TaskList({super.key, required this.items, required this.themeData});

  final List<TaskData> items;
  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today",
                    style: themeData.textTheme.titleLarge!.apply(
                      fontSizeFactor: 0.8,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 50,
                    height: 3,
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: () {
                  final bloc = context.read<TaskListBloc>();
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        insetPadding: const EdgeInsets.all(20),
                        title: const Text('Delete All Tasks'),
                        content: const Text(
                          'Are you sure you want to delete all tasks? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              bloc.add(
                                TaskListDeleteAll(),
                              );
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Row(
                  children: [
                    Text("Delete All"),
                    SizedBox(width: 4),
                    Icon(CupertinoIcons.delete_solid, size: 18),
                  ],
                ),
              ),
            ],
          );
        } else {
          final sortedItems =
              items.toList()
                ..sort((a, b) => b.priority.index.compareTo(a.priority.index));
          final TaskData task = sortedItems[index - 1];

          return TaskItem(task: task);
        }
      },
    );
  }
}

class TaskItem extends StatefulWidget {
  const TaskItem({super.key, required this.task});
  static const double height = 74;
  static const double borderRadius = 8;
  final TaskData task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    final Color priorityColor;
    switch (widget.task.priority) {
      case Priority.low:
        priorityColor = lowPriority;
      case Priority.normal:
        priorityColor = normalPriority;
      case Priority.high:
        priorityColor = highPriority;
    }
    return InkWell(
      onTap: () {
        setState(() {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) =>
                      TaskScreen(task: widget.task, state: "Edit Task"),
            ),
          );
        });
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
        height: TaskItem.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TaskItem.borderRadius),
          color: themeData.colorScheme.onSecondary,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                final repository = Provider.of<Repository<TaskData>>(
                  context,
                  listen: false,
                );
                setState(() {
                  widget.task.isCompleted = !widget.task.isCompleted;
                  repository.createOrUpdate(widget.task);
                });
              },
              child: MyCheckBox(value: widget.task.isCompleted),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.task.name,
                style: TextStyle(
                  decoration:
                      widget.task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(CupertinoIcons.delete, size: 20),
              color: Colors.red.withValues(alpha: 0.7),
              onPressed: () {
                final bloc = context.read<TaskListBloc>();
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      insetPadding: const EdgeInsets.all(20),
                      title: const Text('Delete Task'),
                      content: Text(
                        'Are you sure you want to delete "${widget.task.name}"?',
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            bloc.add(
                              TaskListDelete(widget.task),
                            );
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Container(
              width: 6,
              height: TaskItem.height,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(TaskItem.borderRadius),
                  bottomRight: Radius.circular(TaskItem.borderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

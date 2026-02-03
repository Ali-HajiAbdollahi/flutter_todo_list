import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_todo_list/data.dart';
import 'package:flutter_todo_list/edit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

const taskBoxName = "tasks";

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<TaskData>(taskBoxName);
  runApp(const MyApp());
}

const primaryColor = Color(0xff794CFF);
const primaryContainerColor = Color(0xff5C0AFF);
const secondaryTextColor = Color(0xffAFBED0);
const Color highPriority = primaryColor;
const Color normalPriority = Color(0xffF09819);
const Color lowPriority = Color(0xff3BE1F1);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final primaryTextColor = Color(0xff1D2830);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          TextTheme(titleLarge: TextStyle(fontWeight: FontWeight.bold)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor, // Explicit color
          foregroundColor: Colors.white, // Text/Icon color
        ),

        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: secondaryTextColor),
          iconColor: secondaryTextColor,
          prefixIconColor: secondaryTextColor,
        ),
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          primaryContainer: primaryContainerColor,
          surface: Color(0xffF3F5F8),
          onSurface: primaryTextColor,
          secondary: primaryColor,
          onSecondary: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TaskData>(taskBoxName);
    final themeData = Theme.of(context);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: primaryContainerColor),
    );
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(task: TaskData()),
            ),
          );
        },
        label: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Add New Task"),
            SizedBox(width: 8),
            Icon(CupertinoIcons.add, size: 18),
          ],
        ),
      ),
      body: SafeArea(
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
                    Expanded(flex: 2, child: SizedBox()),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(CupertinoIcons.search),
                            label: Text("Search Tasks..."),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (
                  BuildContext context,
                  Box<TaskData> value,
                  Widget? child,
                ) {
                  if (box.isNotEmpty) {
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: box.values.length + 1,
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
                                    style: themeData.textTheme.titleLarge!
                                        .apply(fontSizeFactor: 0.8),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    width: 50,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: themeData.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              MaterialButton(
                                color: Color(0xffEAEFF5),
                                textColor: secondaryTextColor,
                                elevation: 0,
                                onPressed: () {
                                  box.clear();
                                },
                                child: Row(
                                  children: const [
                                    Text("Delete All"),
                                    SizedBox(width: 4),
                                    Icon(CupertinoIcons.delete_solid, size: 18),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          final TaskData task = box.values.toList()[index - 1];
                          return TaskItem(task: task);
                        }
                      },
                    );
                  } else {
                    return EmptyState();
                  }
                },
              ),
            ),
          ],
        ),
      ),
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
              builder: (context) => EditTaskScreen(task: widget.task),
            ),
          );
        });
      },
      onLongPress: () {
        widget.task.delete();
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
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
                setState(() {
                  widget.task.isCompleted = !widget.task.isCompleted;
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
            Container(
              width: 6,
              height: TaskItem.height,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.only(
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

class MyCheckBox extends StatelessWidget {
  final bool value;

  const MyCheckBox({super.key, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: value ? null : Border.all(color: secondaryTextColor, width: 2),
        color: value ? primaryColor : null,
      ),
      child:
          value
              ? Center(
                child: Icon(
                  CupertinoIcons.check_mark,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 16,
                ),
              )
              : null,
    );
  }
}

class EmptyState extends StatelessWidget{
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/empty_state.svg', width: 140,),
        SizedBox(height: 12,),
        Text("Your task list is empty...", style: Theme.of(context).textTheme.bodyLarge,)
      ],
    );
  }

}
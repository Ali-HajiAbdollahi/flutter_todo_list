import 'package:flutter/material.dart';
import 'package:flutter_todo_list/data.dart';
import 'package:hive_flutter/hive_flutter.dart';

const taskBoxName = "tasks";

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<Task>(taskBoxName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Task>(taskBoxName);
    return Scaffold(
      appBar: AppBar(title: Text("To Do List")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => EditTaskScreen()));
        },
        label: Text("Add New Task"),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (BuildContext context, Box<Task> value, Widget? child) {
            return ListView.builder(
              itemCount: box.values.length,
              itemBuilder: (context, index) { 
                final Task task = box.values.toList()[index];
                return Container(child: Text(task.name));
              },
            );
          },
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatelessWidget {
  final TextEditingController _editController = TextEditingController();

  EditTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Task")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final task = Task();
          task.name = _editController.text;
          task.priority = Priority.low;
          if (task.isInBox) {
            task.save();
          } else {
            final Box<Task> box = Hive.box(taskBoxName);
            box.add(task);
          }
          task.save();
          Navigator.of(context).pop();
        },
        label: Text("Save Changes"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: _editController,
              decoration: InputDecoration(label: Text("Add task for today...")),
            ),
          ],
        ),
      ),
    );
  }
}

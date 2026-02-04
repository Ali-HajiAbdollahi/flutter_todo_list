import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_list/data.dart';
import 'package:flutter_todo_list/main.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskScreen extends StatefulWidget {
  final TaskData task;
  final String state;
  const TaskScreen({super.key, required this.task, required this.state});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late final TextEditingController _editController = TextEditingController(
    text: widget.task.name,
  );

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.colorScheme.onSecondary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeData.colorScheme.onSecondary,
        foregroundColor: themeData.colorScheme.onSurface,
        title: Text(widget.state),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          widget.task.name = _editController.text;
          widget.task.priority = widget.task.priority;
            if (widget.task.name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text("Please enter a task name."),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }

          if (widget.task.isInBox) {
            widget.task.save();
          } else {
            final Box<TaskData> box = Hive.box(taskBoxName);
            box.add(widget.task);
          }
          widget.task.save();
          Navigator.of(context).pop();
        },
        label: const Row(
          children: [
            Text("Save Changes"),
            SizedBox(width: 4),
            Icon(CupertinoIcons.check_mark, size: 18),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: PriorityCheckBox(
                      label: "High",
                      color: primaryColor,
                      isSelected: widget.task.priority == Priority.high,
                      onTap: () {
                        setState(() {
                          widget.task.priority = Priority.high;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PriorityCheckBox(
                      label: "Normal",
                      color: const Color(0xffF09819),
                      isSelected: widget.task.priority == Priority.normal,
                      onTap: () {
                        setState(() {
                          widget.task.priority = Priority.normal;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PriorityCheckBox(
                      label: "Low",
                      color: const Color(0xff3BE1F1),
                      isSelected: widget.task.priority == Priority.low,
                      onTap: () {
                        setState(() {
                          widget.task.priority = Priority.low;
                        });
                      },
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _editController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  label: Text(
                    "Add task for today...",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.apply(fontSizeFactor: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PriorityCheckBox extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final GestureTapCallback onTap;

  const PriorityCheckBox({
    super.key,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            width: 2,
            color:
                !isSelected ? secondaryTextColor.withValues(alpha: 0.2) : color,
          ),
        ),
        child: Stack(
          children: [
            Center(child: Text(label)),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: CheckBoxShape(value: isSelected, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckBoxShape extends StatelessWidget {
  final bool value;
  final Color color;

  const CheckBoxShape({super.key, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color,
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_todo_list/main.dart';

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

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/empty_state.svg', width: 140),
        const SizedBox(height: 12),
        Text(
          "Your task list is empty...",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_todo_list/data/data.dart';
import 'package:flutter_todo_list/data/repo/repository.dart';
import 'package:flutter_todo_list/data/source/hive_task_source.dart';
import 'package:flutter_todo_list/screens/home/home.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

const taskBoxName = "tasks";

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<TaskData>(taskBoxName);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: primaryContainerColor),
  );
  runApp(
    ChangeNotifierProvider<Repository<TaskData>>(
      create:
          (context) =>
              Repository<TaskData>(HiveTaskSource(box: Hive.box(taskBoxName))),
      child: const MyApp(),
    ),
  );
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
    const primaryTextColor = Color(0xff1D2830);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          const TextTheme(titleLarge: TextStyle(fontWeight: FontWeight.bold)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor, // Explicit color
          foregroundColor: Colors.white, // Text/Icon color
        ),

        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(color: secondaryTextColor),
          iconColor: secondaryTextColor,
          prefixIconColor: secondaryTextColor,
        ),
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          primaryContainer: primaryContainerColor,
          surface: Color(0xffF3F5F8),
          onSurface: primaryTextColor,
          secondary: primaryColor,
          onSecondary: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

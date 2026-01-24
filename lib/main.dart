import 'package:flutter/material.dart';
import 'screens/notes_list_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Notes',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const NotesListScreen(),
    );
  }
}

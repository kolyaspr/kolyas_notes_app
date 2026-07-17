import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/notes_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки Степана',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C6AF7),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E30),
          background: const Color(0xFF16162A),
          primary: const Color(0xFF9D8FFF),
        ),
        scaffoldBackgroundColor: const Color(0xFF16162A),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E30),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF2A2A45), width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16162A),
          foregroundColor: Color(0xFFE8E8FF),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFE8E8FF),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF252540),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2A2A45)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2A2A45)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF9D8FFF), width: 1.5),
          ),
          hintStyle: const TextStyle(color: Color(0xFF555580)),
          labelStyle: const TextStyle(color: Color(0xFF8888AA)),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF2A2A45),
          thickness: 1,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF1E1E30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: const NotesPage(),
    );
  }
}

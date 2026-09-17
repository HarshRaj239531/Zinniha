import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/bookshelf_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZinnihaApp());
}

class ZinnihaApp extends StatelessWidget {
  const ZinnihaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zinnia Creative Journal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F5EE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2A9D8F),
          primary: const Color(0xFF2C3E50),
          secondary: const Color(0xFFB5838D),
          surface: const Color(0xFFFAF8F5),
        ),
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF8F5),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const BookshelfScreen(),
    );
  }
}

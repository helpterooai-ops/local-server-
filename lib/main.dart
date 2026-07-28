import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PocketCloudApp());
}

class PocketCloudApp extends StatelessWidget {
  const PocketCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Cloud Host',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // استخدام نظام ألوان هادئ يعتمد على لون واحد
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // أزرق ملكي هادئ
          brightness: Brightness.light,
        ).copyWith(
          // لون التمييز (Accent) واحد أنيق وجذاب
          secondary: const Color(0xFFD4AF37), // ذهبي هادئ
        ),
        // استخدام خط "Cairo" العربي الحديث في كل عناصر الواجهة
        textTheme: GoogleFonts.cairoTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFF2D3748), // نص داكن ناعم
          displayColor: const Color(0xFF1A202C),
        ),
        // تخصيص بعض العناصر الأساسية للفخامة والبساطة
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1A202C),
          titleTextStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A202C),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          shadowColor: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC), // خلفية هادئة جداً
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            // انتقالات سلسة وهادئة بين الصفحات
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
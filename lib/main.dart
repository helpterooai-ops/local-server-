import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.light,
        ).copyWith(
          secondary: const Color(0xFFD4AF37),
        ),
        textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFF2D3748),
          displayColor: const Color(0xFF1A202C),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF1A202C),
          titleTextStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A202C),
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
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        useMaterial3: true,
        splashFactory: InkRipple.splashFactory,
        highlightColor: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
        splashColor: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // ✅ تم التغيير إلى userChanges لتتبع تحديثات emailVerified
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data!;
          if (user.emailVerified) {
            return const HomeScreen();
          }
          return const VerificationScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/html.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

class WebHostingScreen extends StatefulWidget {
  const WebHostingScreen({super.key});

  @override
  State<WebHostingScreen> createState() => _WebHostingScreenState();
}

class _WebHostingScreenState extends State<WebHostingScreen> {
  late CodeController _codeController;

  @override
  void initState() {
    super.initState();
    // كود HTML افتراضي
    const initialCode = '''<!DOCTYPE html>
<html>
<head>
  <title>مرحباً بالعالم</title>
</head>
<body>
  <h1>مرحباً!</h1>
  <p>هذه صفحتي المستضافة من هاتفي.</p>
</body>
</html>''';

    _codeController = CodeController(
      text: initialCode,
      language: html,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _hostWebsite() {
    // TODO: استضافة الكود عبر الخادم المحلي
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'سيتم استضافة الموقع قريباً!',
          style: GoogleFonts.ibmPlexSansArabic(),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // خلفية داكنة تشبه VS Code
      appBar: AppBar(
        title: Text(
          'محرر الأكواد',
          style: GoogleFonts.ibmPlexSansArabic(
            textStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF252526),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: Column(
        children: [
          // شريط تبويب اللغة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF2D2D2D),
            child: Row(
              children: [
                Icon(Icons.html, color: Colors.orange[300], size: 18),
                const SizedBox(width: 8),
                Text(
                  'index.html',
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // المحرر
          Expanded(
            child: CodeTheme(
              data: CodeThemeData(styles: monokaiSublimeTheme),
              child: SingleChildScrollView(
                child: CodeField(
                  controller: _codeController,
                  textStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
          // شريط الحالة السفلي
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF007ACC),
            child: Row(
              children: [
                const Spacer(),
                Text(
                  'HTML',
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _hostWebsite,
        backgroundColor: const Color(0xFF38A169),
        icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
        label: Text(
          'استضافة',
          style: GoogleFonts.ibmPlexSansArabic(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
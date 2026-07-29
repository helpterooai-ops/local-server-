import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/html.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

class WebHostingScreen extends StatefulWidget {
  const WebHostingScreen({super.key});

  @override
  State<WebHostingScreen> createState() => _WebHostingScreenState();
}

class _WebHostingScreenState extends State<WebHostingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CodeController _htmlController;
  late CodeController _cssController;
  late CodeController _jsController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    const htmlCode = '''<!DOCTYPE html>
<html>
<head>
  <title>مرحباً بالعالم</title>
</head>
<body>
  <h1>مرحباً!</h1>
  <p>هذه صفحتي المستضافة من هاتفي.</p>
</body>
</html>''';

    const cssCode = '''body {
  background-color: #f0f0f0;
  font-family: Arial, sans-serif;
}
h1 {
  color: #1E3A8A;
}''';

    const jsCode = '''console.log('مرحباً من JavaScript!');''';

    _htmlController = CodeController(
      text: htmlCode,
      language: html,
    );
    _cssController = CodeController(
      text: cssCode,
      language: css,
    );
    _jsController = CodeController(
      text: jsCode,
      language: javascript,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _htmlController.dispose();
    _cssController.dispose();
    _jsController.dispose();
    super.dispose();
  }

  void _hostWebsite() {
    // سنقوم هنا لاحقاً بتجميع الأكواد وإرسالها للخادم المحلي
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.ibmPlexSansArabic(fontSize: 14),
          tabs: const [
            Tab(text: 'HTML'),
            Tab(text: 'CSS'),
            Tab(text: 'JavaScript'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCodeEditor(_htmlController),
          _buildCodeEditor(_cssController),
          _buildCodeEditor(_jsController),
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

  Widget _buildCodeEditor(CodeController controller) {
    return CodeTheme(
      data: CodeThemeData(styles: monokaiSublimeTheme),
      child: SingleChildScrollView(
        child: CodeField(
          controller: controller,
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
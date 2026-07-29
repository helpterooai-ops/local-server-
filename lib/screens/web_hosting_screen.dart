import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import '../services/local_server_service.dart';

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
  final LocalServerService _serverService = LocalServerService();
  bool _isServerRunning = false;
  String? _serverUrl;
  bool _isLoading = false;

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

    _htmlController = CodeController(text: htmlCode, language: xml);
    _cssController = CodeController(text: cssCode, language: css);
    _jsController = CodeController(text: jsCode, language: javascript);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _htmlController.dispose();
    _cssController.dispose();
    _jsController.dispose();
    _serverService.stop();
    super.dispose();
  }

  String _buildFullHtml() {
    final html = _htmlController.text;
    final css = _cssController.text;
    final js = _jsController.text;

    // دمج CSS و JavaScript في HTML
    String fullHtml = html;
    if (css.isNotEmpty) {
      final cssTag = '\n<style>\n$css\n</style>';
      if (fullHtml.contains('</head>')) {
        fullHtml = fullHtml.replaceFirst('</head>', '$cssTag\n</head>');
      } else if (fullHtml.contains('<body>')) {
        fullHtml = fullHtml.replaceFirst('<body>', '$cssTag\n<body>');
      } else {
        fullHtml += cssTag;
      }
    }
    if (js.isNotEmpty) {
      final jsTag = '\n<script>\n$js\n</script>';
      if (fullHtml.contains('</body>')) {
        fullHtml = fullHtml.replaceFirst('</body>', '$jsTag\n</body>');
      } else {
        fullHtml += jsTag;
      }
    }
    return fullHtml;
  }

  Future<void> _hostWebsite() async {
    setState(() => _isLoading = true);
    try {
      if (_isServerRunning) {
        await _serverService.stop();
        setState(() {
          _isServerRunning = false;
          _serverUrl = null;
        });
      } else {
        final fullHtml = _buildFullHtml();
        _serverService.updateWebsite(fullHtml);
        final url = await _serverService.start();
        setState(() {
          _isServerRunning = true;
          _serverUrl = url;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تشغيل الخادم: $e',
                style: GoogleFonts.ibmPlexSansArabic()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
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
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCodeEditor(_htmlController),
                _buildCodeEditor(_cssController),
                _buildCodeEditor(_jsController),
              ],
            ),
          ),
          // شريط حالة الخادم
          if (_isServerRunning && _serverUrl != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF38A169),
              child: Row(
                children: [
                  const Icon(Icons.link, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_serverUrl',
                      style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop_circle, color: Colors.white),
                    onPressed: _hostWebsite,
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _hostWebsite,
        backgroundColor: _isServerRunning ? const Color(0xFFE53E3E) : const Color(0xFF38A169),
        icon: Icon(
          _isServerRunning ? Icons.stop : Icons.cloud_upload_outlined,
          color: Colors.white,
        ),
        label: Text(
          _isServerRunning ? 'إيقاف' : 'استضافة',
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
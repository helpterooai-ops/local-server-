import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import '../services/background_service.dart';

class WebHostingScreen extends StatefulWidget {
  const WebHostingScreen({super.key});

  @override
  State<WebHostingScreen> createState() => _WebHostingScreenState();
}

class _WebHostingScreenState extends State<WebHostingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CodeController _htmlController;
  late CodeController _cssController;
  late CodeController _jsController;
  final BackgroundServerService _backgroundService = BackgroundServerService();
  bool _isServerRunning = false;
  String? _serverUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkServerStatus();

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
    super.dispose();
  }

  Future<void> _checkServerStatus() async {
    final isRunning = await _backgroundService.isServiceRunning();
    setState(() {
      _isServerRunning = isRunning;
      if (_isServerRunning) {
        _serverUrl = 'http://localhost:8080';
      }
    });
  }

  String _buildFullHtml() {
    final html = _htmlController.text;
    final css = _cssController.text;
    final js = _jsController.text;

    String fullHtml = html;
    if (css.isNotEmpty && css.trim() != '') {
      final cssTag = '\n<style>\n$css\n</style>';
      if (fullHtml.contains('</head>')) {
        fullHtml = fullHtml.replaceFirst('</head>', '$cssTag\n</head>');
      } else if (fullHtml.contains('<body>')) {
        fullHtml = fullHtml.replaceFirst('<body>', '$cssTag\n<body>');
      } else {
        fullHtml += cssTag;
      }
    }
    if (js.isNotEmpty && js.trim() != '') {
      final jsTag = '\n<script>\n$js\n</script>';
      if (fullHtml.contains('</body>')) {
        fullHtml = fullHtml.replaceFirst('</body>', '$jsTag\n</body>');
      } else {
        fullHtml += jsTag;
      }
    }
    return fullHtml;
  }

  void _showCopyMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ الرابط بنجاح',
          style: GoogleFonts.ibmPlexSansArabic(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تعليمات الاستضافة',
          style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInstructionItem(
                  '• سيتم دمج أكواد HTML و CSS و JavaScript في صفحة واحدة.'),
              const SizedBox(height: 12),
              _buildInstructionItem(
                  '• في حال لم تضف CSS أو JavaScript، سيتم استضافة هيكل HTML فقط.'),
              const SizedBox(height: 12),
              _buildInstructionItem(
                  '• الرابط يعمل فقط للأجهزة المتصلة بنفس شبكة الواي فاي.'),
              const SizedBox(height: 12),
              _buildInstructionItem(
                  '• الخادم يعمل في الخلفية حتى بعد إغلاق الشاشة.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'فهمت',
              style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Text(
      text,
      style: GoogleFonts.ibmPlexSansArabic(
        fontSize: 14,
        color: Colors.grey[800],
      ),
    );
  }

  Future<void> _hostWebsite() async {
    setState(() => _isLoading = true);
    try {
      if (_isServerRunning) {
        await _backgroundService.stopService();
        setState(() {
          _isServerRunning = false;
          _serverUrl = null;
        });
      } else {
        final fullHtml = _buildFullHtml();
        await _backgroundService.startService(fullHtml);
        setState(() {
          _isServerRunning = true;
          _serverUrl = 'http://localhost:8080';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل تشغيل الخادم',
              style: GoogleFonts.ibmPlexSansArabic(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
          'محرر الأكواد',
          style: GoogleFonts.ibmPlexSansArabic(
            textStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        shadowColor: Colors.black12,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              labelColor: colorScheme.primary,
              unselectedLabelColor: Colors.grey[500],
              labelStyle: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 14, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 14, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'HTML'),
                Tab(text: 'CSS'),
                Tab(text: 'JavaScript'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_isServerRunning && _serverUrl != null)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: colorScheme.primary.withValues(alpha: 0.03),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded,
                      color: Color(0xFF38A169), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الموقع يعمل الآن',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: const Color(0xFF38A169),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: _serverUrl!));
                            _showCopyMessage();
                          },
                          child: Text(
                            _serverUrl!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded, size: 18),
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    onPressed: _showInstructionsDialog,
                    tooltip: 'تعليمات الاستضافة',
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _serverUrl!));
                      _showCopyMessage();
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              color: const Color(0xFF1E1E1E),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCodeEditor(_htmlController),
                  _buildCodeEditor(_cssController),
                  _buildCodeEditor(_jsController),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _hostWebsite,
        backgroundColor:
            _isServerRunning ? const Color(0xFFE53E3E) : colorScheme.primary,
        icon: Icon(
          _isServerRunning ? Icons.stop : Icons.cloud_upload_outlined,
          color: Colors.white,
        ),
        label: Text(
          _isServerRunning ? 'إيقاف الاستضافة' : 'استضافة',
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
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RetrieveScreen extends StatefulWidget {
  const RetrieveScreen({super.key});

  @override
  State<RetrieveScreen> createState() => _RetrieveScreenState();
}

class _RetrieveScreenState extends State<RetrieveScreen> {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _content;
  bool _isLoading = false;
  bool _showPasswordField = false;

  Future<void> _retrieve() async {
    setState(() {
      _isLoading = true;
      _content = null;
    });

    try {
      final uri = Uri.tryParse(_linkController.text.trim());
      if (uri == null) {
        setState(() => _content = 'الرابط غير صالح.');
        return;
      }
      // إضافة هيدر التطبيق
      final response = await http.get(
        uri.replace(queryParameters: {
          ...uri.queryParameters,
          if (_passwordController.text.isNotEmpty) 'pass': _passwordController.text,
        }),
        headers: {'x-pocket-client': 'pocket_cloud_host'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _content = response.body;
          _showPasswordField = false;
        });
      } else if (response.statusCode == 403) {
        setState(() {
          _content = response.body;
          _showPasswordField = _content!.contains('كلمة المرور');
        });
      } else {
        setState(() => _content = 'خطأ: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _content = 'فشل الاتصال: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('استرداد المحتوى', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                labelText: 'أدخل رابط الاسترداد أو كود الجلسة',
                labelStyle: GoogleFonts.ibmPlexSansArabic(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_showPasswordField) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  labelStyle: GoogleFonts.ibmPlexSansArabic(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _retrieve,
              icon: const Icon(Icons.download),
              label: Text('استرداد', style: GoogleFonts.ibmPlexSansArabic()),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_content != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(_content!, style: const TextStyle(fontFamily: 'monospace')),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
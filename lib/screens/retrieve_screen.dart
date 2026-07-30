import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class RetrieveScreen extends StatefulWidget {
  const RetrieveScreen({super.key});

  @override
  State<RetrieveScreen> createState() => _RetrieveScreenState();
}

class _RetrieveScreenState extends State<RetrieveScreen> {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<Map<String, String>> _fileList = [];
  bool _isLoading = false;
  bool _showPasswordField = false;

  Future<void> _retrieve() async {
    setState(() {
      _isLoading = true;
      _fileList = [];
    });

    try {
      final uri = Uri.tryParse(_linkController.text.trim());
      if (uri == null) {
        _showMessage('الرابط غير صالح.');
        return;
      }
      
      final headers = <String, String>{
        'x-pocket-client': 'pocket_cloud_host',
      };
      
      var queryParams = Map<String, String>.from(uri.queryParameters);
      if (_passwordController.text.isNotEmpty) {
        queryParams['pass'] = _passwordController.text;
      }
      
      final response = await http.get(
        uri.replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = response.body;
        // تحليل النص المستلم إلى قائمة ملفات
        setState(() {
          _fileList = _parseFileList(body);
          _showPasswordField = false;
        });
      } else if (response.statusCode == 403) {
        _showMessage(response.body);
        setState(() => _showPasswordField = response.body.contains('كلمة المرور'));
      } else {
        _showMessage('خطأ: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('فشل الاتصال: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, String>> _parseFileList(String body) {
    // مثال صيغة: [{name: file1.jpg, download_url: http://...}, {name: file2.pdf, download_url: http://...}]
    List<Map<String, String>> files = [];
    try {
      // تنظيف النص قليلاً
      String cleanBody = body.replaceAll('{', '').replaceAll('}', '').replaceAll('[', '').replaceAll(']', '');
      List<String> items = cleanBody.split(', ');
      Map<String, String> currentFile = {};
      for (String item in items) {
        if (item.startsWith('name:')) {
          currentFile['name'] = item.substring(5).trim();
        } else if (item.startsWith('download_url:')) {
          currentFile['download_url'] = item.substring(13).trim();
          if (currentFile.containsKey('name')) {
            files.add(Map<String, String>.from(currentFile));
            currentFile = {};
          }
        }
      }
    } catch (e) {
      _showMessage('فشل تحليل البيانات: $e');
    }
    return files;
  }

  void _showMessage(String msg) {
    setState(() {
      // عرض رسالة الخطأ في الواجهة
      _fileList = [{'name': msg, 'download_url': ''}];
    });
  }

  Future<void> _downloadFile(String url, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';
      final response = await http.get(
        Uri.parse(url),
        headers: {'x-pocket-client': 'pocket_cloud_host'},
      );
      if (response.statusCode == 200) {
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        // محاولة فتح الملف بعد التحميل
        await OpenFile.open(filePath);
      } else {
        _showMessage('فشل تحميل الملف');
      }
    } catch (e) {
      _showMessage('فشل تحميل الملف: $e');
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
                labelText: 'أدخل رابط الاسترداد',
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
            if (_fileList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _fileList.length,
                  itemBuilder: (context, index) {
                    final file = _fileList[index];
                    final bool isDownloadable = file['download_url']?.isNotEmpty == true;
                    return ListTile(
                      leading: const Icon(Icons.insert_drive_file, color: Color(0xFF3182CE)),
                      title: Text(file['name'] ?? 'ملف', style: GoogleFonts.ibmPlexSansArabic(fontSize: 14)),
                      trailing: isDownloadable ? IconButton(
                        icon: const Icon(Icons.file_download, color: Colors.blue),
                        onPressed: () => _downloadFile(file['download_url']!, file['name']!),
                      ) : null,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
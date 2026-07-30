import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/live_tunnel_service.dart';
import '../screens/file_manager_screen.dart' show FileItem, FileCategory;

class LiveTunnelsScreen extends StatefulWidget {
  const LiveTunnelsScreen({super.key});

  @override
  State<LiveTunnelsScreen> createState() => _LiveTunnelsScreenState();
}

class _LiveTunnelsScreenState extends State<LiveTunnelsScreen> {
  final LiveTunnelService _tunnelService = LiveTunnelService();
  List<FileItem> _allFiles = [];
  double _durationHours = 1.0;
  String? _generatedLink;
  Timer? _expiryTimer;
  Duration _remaining = Duration.zero;
  bool _isServerRunning = false;
  bool _isLoading = false;
  bool _isGenerating = false; // مؤشر منفصل لعملية التوليد

  // إعدادات الأمان
  bool _useStaticPassword = false;
  bool _useOtp = false;
  bool _useIpRestriction = false;
  TextEditingController _staticPasswordController = TextEditingController();
  TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFiles();
    if (_tunnelService.isRunning) {
      _isServerRunning = true;
      _generatedLink = 'http://localhost:8080/retrieve?session=${_tunnelService.currentSession?.id}';
      _startExpiryTimer();
    }
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _staticPasswordController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('file_manager_data');
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        setState(() {
          _allFiles = jsonList.map((e) => FileItem.fromJson(e)).toList();
        });
      } catch (_) {}
    }
  }

  String _getLocalIp() => 'localhost'; // يتم التحديث لاحقاً

  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final session = _tunnelService.currentSession;
      if (session != null && session.isExpired) {
        _stopServer();
        timer.cancel();
      }
      setState(() {
        if (session != null) {
          _remaining = session.expiry.difference(DateTime.now());
          if (_remaining.isNegative) _remaining = Duration.zero;
        }
      });
    });
  }

  Future<void> _generateLink() async {
    if (_allFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا توجد ملفات مختارة. الرجاء الانتقال إلى مدير الملفات أولاً.', style: GoogleFonts.ibmPlexSansArabic())),
      );
      return;
    }
    setState(() => _isGenerating = true);
    try {
      // إيقاف مؤقت للخادم القديم إذا كان يعمل
      if (_tunnelService.isRunning) {
        await _tunnelService.stopServer();
      }
      final session = LiveSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePaths: _allFiles.map((f) => f.path).toList(),
        fileVisibility: {for (var f in _allFiles) f.path: !f.isHidden},
        durationMinutes: (_durationHours * 60).round(),
        staticPassword: _useStaticPassword ? _staticPasswordController.text : null,
        useOtp: _useOtp,
        allowedIps: _useIpRestriction && _ipController.text.isNotEmpty ? [_ipController.text] : [],
      );
      final link = await _tunnelService.startServer(session);
      setState(() {
        _generatedLink = link;
        _isServerRunning = true;
        _remaining = session.expiry.difference(DateTime.now());
      });
      _startExpiryTimer();
      await _saveSessionState();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل توليد الرابط: $e', style: GoogleFonts.ibmPlexSansArabic())),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _stopServer() async {
    await _tunnelService.stopServer();
    _expiryTimer?.cancel();
    setState(() {
      _isServerRunning = false;
      _generatedLink = null;
      _remaining = Duration.zero;
    });
    await _saveSessionState();
  }

  Future<void> _saveSessionState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('live_tunnel_active', _isServerRunning);
  }

  void _showSecurityBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إعدادات الأمان', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: Text('كلمة مرور ثابتة', style: GoogleFonts.ibmPlexSansArabic()),
                    value: _useStaticPassword,
                    onChanged: (val) => setSheetState(() {
                      _useStaticPassword = val;
                    }),
                  ),
                  if (_useStaticPassword)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _staticPasswordController,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text('كلمة مرور لمرة واحدة (OTP)', style: GoogleFonts.ibmPlexSansArabic()),
                    value: _useOtp,
                    onChanged: (val) => setSheetState(() {
                      _useOtp = val;
                    }),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text('تقييد عنوان IP', style: GoogleFonts.ibmPlexSansArabic()),
                    value: _useIpRestriction,
                    onChanged: (val) => setSheetState(() {
                      _useIpRestriction = val;
                    }),
                  ),
                  if (_useIpRestriction)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _ipController,
                        decoration: InputDecoration(
                          labelText: 'عنوان IP المسموح به',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('حفظ الإعدادات', style: GoogleFonts.ibmPlexSansArabic()),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'الأنفاق الحية',
          style: GoogleFonts.ibmPlexSansArabic(
            textStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- القسم العلوي: إعدادات الأمان والمدة ---
            Text('إعدادات الرابط', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            // مدة الصلاحية
            Text('مدة الصلاحية: ${_durationHours.toStringAsFixed(1)} ساعة', style: GoogleFonts.ibmPlexSansArabic(color: colorScheme.primary)),
            Slider(
              value: _durationHours,
              min: 0.5,
              max: 24,
              divisions: 47,
              onChanged: _isServerRunning ? null : (val) => setState(() => _durationHours = val),
            ),
            const SizedBox(height: 12),
            // زر إعدادات الأمان (يظهر قبل توليد الرابط)
            OutlinedButton.icon(
              onPressed: _isServerRunning ? null : _showSecurityBottomSheet,
              icon: const Icon(Icons.security),
              label: Text('إعدادات الأمان', style: GoogleFonts.ibmPlexSansArabic()),
            ),
            const SizedBox(height: 20),
            
            // --- قسم محتوى الجلسة ---
            if (_allFiles.isNotEmpty) ...[
              Text('الملفات المحددة للمشاركة:', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...(_allFiles.map((file) => ListTile(
                leading: Icon(Icons.insert_drive_file, color: colorScheme.primary),
                title: Text(file.name, style: GoogleFonts.ibmPlexSansArabic()),
                subtitle: Text(file.isHidden ? 'مخفي' : 'ظاهر', style: GoogleFonts.ibmPlexSansArabic(color: file.isHidden ? Colors.red : Colors.green)),
              ))),
              const SizedBox(height: 20),
            ] else ...[
              Text('لا توجد ملفات. انتقل إلى مدير الملفات لإضافة ملفات.', style: GoogleFonts.ibmPlexSansArabic(color: Colors.grey)),
              const SizedBox(height: 20),
            ],

            // --- قسم توليد الرابط / عرض الرابط الحي ---
            if (!_isServerRunning)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateLink,
                  icon: _isGenerating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.link),
                  label: Text(_isGenerating ? 'جارٍ إنشاء الرابط...' : 'إنشاء رابط', style: GoogleFonts.ibmPlexSansArabic()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  ),
                ),
              )
            else ...[
              // عرض الرابط الحي
              Text('الرابط الحي:', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(_generatedLink!, style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _generatedLink!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('تم نسخ الرابط', style: GoogleFonts.ibmPlexSansArabic())),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('الوقت المتبقي: ${_remaining.inMinutes} دقيقة و ${_remaining.inSeconds % 60} ثانية',
                style: GoogleFonts.ibmPlexSansArabic(color: Colors.orange)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _stopServer,
                icon: const Icon(Icons.stop),
                label: Text('إيقاف وإغلاق الرابط', style: GoogleFonts.ibmPlexSansArabic()),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
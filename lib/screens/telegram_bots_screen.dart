import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/telegram_service.dart';

class TelegramBotsScreen extends StatefulWidget {
  const TelegramBotsScreen({super.key});

  @override
  State<TelegramBotsScreen> createState() => _TelegramBotsScreenState();
}

class _TelegramBotsScreenState extends State<TelegramBotsScreen> {
  final TelegramBotService _botService = TelegramBotService();
  final TextEditingController _tokenController = TextEditingController();
  bool _isLoading = false;
  bool _isRunning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isRunning = _botService.isRunning;
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _toggleBot() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isRunning) {
        await _botService.stopBot();
        setState(() {
          _isRunning = false;
        });
      } else {
        final token = _tokenController.text.trim();
        if (token.isEmpty) {
          setState(() {
            _errorMessage = 'الرجاء إدخال Token البوت من BotFather.';
          });
          return;
        }
        await _botService.startBot(token);
        setState(() {
          _isRunning = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تشغيل البوت. تأكد من التوكن واتصالك بالإنترنت.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'بوتات تيليجرام',
          style: GoogleFonts.ibmPlexSansArabic(
            textStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أيقونة
            Center(
              child: Icon(
                Icons.smart_toy_outlined,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'إدارة بوتات تيليجرام',
              style: GoogleFonts.ibmPlexSansArabic(
                textStyle: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أدخل Token البوت من BotFather ثم اضغط تشغيل.',
              style: GoogleFonts.ibmPlexSansArabic(
                textStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // حقل التوكن
            TextField(
              controller: _tokenController,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'Bot Token',
                labelStyle: GoogleFonts.ibmPlexSansArabic(),
                hintText: '123456:ABC-DEF1234gh...',
                hintStyle: GoogleFonts.ibmPlexSansArabic(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // رسالة خطأ
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFE53E3E), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.ibmPlexSansArabic(
                          color: const Color(0xFFE53E3E),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // زر التشغيل / الإيقاف
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _toggleBot,
                icon: Icon(
                  _isRunning ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                  size: 20,
                ),
                label: Text(
                  _isRunning ? 'إيقاف البوت' : 'تشغيل البوت',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? const Color(0xFFE53E3E) : colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // حالة البوت
            if (_isRunning)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF38A169).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF38A169), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'البوت يعمل الآن في الخلفية.',
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: const Color(0xFF38A169),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
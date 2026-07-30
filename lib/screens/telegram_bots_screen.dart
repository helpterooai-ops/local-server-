import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class TelegramBotsScreen extends StatefulWidget {
  const TelegramBotsScreen({super.key});

  @override
  State<TelegramBotsScreen> createState() => _TelegramBotsScreenState();
}

class _TelegramBotsScreenState extends State<TelegramBotsScreen> {
  static const platform = MethodChannel('com.bot_maker/python_channel');
  
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isRunning = false;
  String? _consoleMessage;

  @override
  void initState() {
    super.initState();
    // قالب كود بايثون جاهز لبوت تيليجرام
    _codeController.text = '''import telebot

# ضع التوكن الخاص بك هنا
TOKEN = "ضع_التوكن_هنا"
bot = telebot.TeleBot(TOKEN)

@bot.message_handler(commands=['start'])
def send_welcome(message):
    bot.reply_to(message, "مرحباً! أنا أعمل من داخل تطبيق فلاتر! 🚀")

@bot.message_handler(func=lambda message: True)
def echo_all(message):
    bot.reply_to(message, "أنت قلت: " + message.text)

# تشغيل البوت
bot.infinity_polling()''';
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _toggleBot() async {
    setState(() {
      _isLoading = true;
      _consoleMessage = null;
    });

    try {
      if (_isRunning) {
        // إيقاف البوت
        final result = await platform.invokeMethod('stopPythonBot');
        setState(() {
          _isRunning = false;
          _consoleMessage = result;
        });
      } else {
        // تشغيل البوت
        final code = _codeController.text.trim();
        if (code.isEmpty) {
          setState(() => _consoleMessage = 'الرجاء إدخال كود بايثون.');
          return;
        }
        
        final result = await platform.invokeMethod('runPythonBot', {'code': code});
        setState(() {
          _isRunning = true;
          _consoleMessage = result;
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _consoleMessage = 'خطأ: ${e.message}';
        _isRunning = false;
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
          'محرر بوتات بايثون',
          style: GoogleFonts.ibmPlexSansArabic(
            textStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اكتب كود البوت (Python):',
              style: GoogleFonts.ibmPlexSansArabic(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // محرر الكود
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  expands: true,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.greenAccent,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                    hintText: 'اكتب كود بايثون هنا...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // شاشة الكونسول (الرسائل)
            if (_consoleMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _isRunning
                      ? const Color(0xFF38A169).withValues(alpha: 0.1)
                      : const Color(0xFFE53E3E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _consoleMessage!,
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: _isRunning ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),

            // زر التشغيل/الإيقاف
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
                  _isRunning ? 'إيقاف البوت' : 'تشغيل الكود',
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

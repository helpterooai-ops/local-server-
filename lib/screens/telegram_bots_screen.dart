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

  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  
  bool _isLoading = false;
  bool _isRunning = false;
  bool _isTestMode = false;
  String? _consoleMessage;

  @override
  void initState() {
    super.initState();
    // قالب الكود الافتراضي (بدون تعريف التوكن لأنه سيُحقن تلقائياً)
    _codeController.text = '''import telebot

# المتغير TOKEN يتم حقنه تلقائياً في الخلفية من الحقل العلوي
# يمكنك استخدامه مباشرة كما في السطر التالي:
bot = telebot.TeleBot(TOKEN)

@bot.message_handler(commands=['start'])
def send_welcome(message):
    bot.reply_to(message, "مرحباً! البوت يعمل بنجاح بكودك الخاص! 🚀")

@bot.message_handler(func=lambda message: True)
def echo_all(message):
    bot.reply_to(message, "أنت قلت: " + message.text)

# تشغيل البوت
bot.infinity_polling()''';
  }

  @override
  void dispose() {
    _tokenController.dispose();
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
        // التحقق من التوكن
        final token = _tokenController.text.trim();
        if (token.isEmpty) {
          setState(() => _consoleMessage = 'الرجاء إدخال توكن البوت أولاً.');
          return;
        }

        String finalCodeToRun = "";

        // تحديد الكود الذي سيتم تشغيله بناءً على وضع التجربة
        if (_isTestMode) {
          // كود تجريبي مدمج لتجربة البوت فقط
          finalCodeToRun = '''
import telebot
TOKEN = "$token"
bot = telebot.TeleBot(TOKEN)

@bot.message_handler(commands=['start'])
def send_welcome(message):
    bot.reply_to(message, "مرحباً! البوت يعمل بنجاح من داخل [وضع التجربة]! 🧪🚀")

@bot.message_handler(func=lambda message: True)
def echo_all(message):
    bot.reply_to(message, "[وضع التجربة].. أنت قلت: " + message.text)

bot.infinity_polling()
          ''';
        } else {
          // استخدام كود المستخدم مع حقن التوكن في بدايته
          final userCode = _codeController.text.trim();
          if (userCode.isEmpty) {
            setState(() => _consoleMessage = 'الرجاء إدخال كود بايثون.');
            return;
          }
          finalCodeToRun = 'TOKEN = "$token"\n' + userCode;
        }

        // تشغيل الكود المختار
        final result = await platform.invokeMethod('runPythonBot', {'code': finalCodeToRun});
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
          'استضافة بوت بايثون',
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
            // 1. حقل إدخال التوكن (منفصل)
            TextField(
              controller: _tokenController,
              textDirection: TextDirection.ltr,
              enabled: !_isRunning,
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
            const SizedBox(height: 16),

            // 2. مفتاح وضع التجربة (Switch)
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isTestMode ? colorScheme.primary : Colors.transparent,
                  width: 1,
                ),
              ),
              child: SwitchListTile(
                title: Text(
                  'وضع التجربة (اختبار الاتصال)',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'تجاهل الكود بالأسفل وتشغيل كود افتراضي للرد على الرسائل.',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                value: _isTestMode,
                activeColor: colorScheme.primary,
                onChanged: _isRunning
                    ? null
                    : (val) {
                        setState(() {
                          _isTestMode = val;
                        });
                      },
              ),
            ),
            const SizedBox(height: 16),

            // 3. محرر الأكواد
            Row(
              children: [
                Icon(Icons.code, size: 20, color: colorScheme.onSurface.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Text(
                  'كود البوت (Python):',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontWeight: FontWeight.w600,
                    color: _isTestMode
                        ? colorScheme.onSurface.withValues(alpha: 0.4)
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: IgnorePointer(
                ignoring: _isTestMode || _isRunning,
                child: AnimatedOpacity(
                  opacity: _isTestMode ? 0.4 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isTestMode ? Colors.transparent : colorScheme.outlineVariant.withValues(alpha: 0.2),
                      ),
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
                        height: 1.5,
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
              ),
            ),
            const SizedBox(height: 16),

            // 4. شاشة الكونسول (الرسائل)
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
                  border: Border.all(
                    color: _isRunning
                        ? const Color(0xFF38A169).withValues(alpha: 0.3)
                        : const Color(0xFFE53E3E).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isRunning ? Icons.check_circle_outline : Icons.error_outline,
                      color: _isRunning ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _consoleMessage!,
                        style: GoogleFonts.ibmPlexSansArabic(
                          color: _isRunning ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 5. زر التشغيل/الإيقاف
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _toggleBot,
                icon: Icon(
                  _isRunning ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                  size: 22,
                ),
                label: Text(
                  _isRunning ? 'إيقاف البوت' : 'تشغيل البوت',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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
          ],
        ),
      ),
    );
  }
}
import 'dart:async';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

class TelegramBotService {
  static final TelegramBotService _instance = TelegramBotService._internal();
  factory TelegramBotService() => _instance;
  TelegramBotService._internal();

  TeleDart? _bot;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<void> startBot(String token) async {
    // منع محاولة تشغيل البوت إذا كان يعمل مسبقاً
    if (_isRunning) return;

    try {
      // 1. جلب بيانات البوت للتعرف على اسمه (خطوة إجبارية للنسخ الحديثة)
      final telegram = Telegram(token);
      final me = await telegram.getMe();
      
      // 2. إنشاء كائن Event باستخدام اسم البوت الذي جلبناه
      final event = Event(me.username!);

      // 3. تمرير التوكن والـ Event معاً لتجنب خطأ الترجمة
      _bot = TeleDart(token, event);

      // 4. تشغيل البوت (بدون await لأنها void)
      _bot!.start();
      _isRunning = true;

      // 5. الرد الاحترافي على أمر محدد فقط لتجنب الإزعاج
      _bot!.onCommand('start').listen((message) {
        message.reply('مرحباً! خادمك يعمل الآن بنجاح عبر Pocket Cloud Host 🚀');
      });

    } catch (e) {
      _isRunning = false;
      throw Exception('فشل تشغيل البوت. تأكد من التوكن أو اتصال الإنترنت.');
    }
  }

  Future<void> stopBot() async {
    if (_bot != null) {
      // إغلاق البوت وتفريغ المتغير
      _bot!.close();
      _bot = null;
    }
    _isRunning = false;
  }
}

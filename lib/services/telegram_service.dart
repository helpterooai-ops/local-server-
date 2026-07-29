import 'dart:async';
import 'package:teledart/teledart.dart';

class TelegramBotService {
  static final TelegramBotService _instance = TelegramBotService._internal();
  factory TelegramBotService() => _instance;
  TelegramBotService._internal();

  TeleDart? _bot;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<void> startBot(String token) async {
    if (_isRunning) return;
    _bot = TeleDart(token, Event.telegram);
    try {
      await _bot!.start();
      _isRunning = true;
      _bot!.onMessage().listen((message) {
        // رد بسيط عند استقبال أي رسالة
        message.reply('مرحباً! أنا بوت Pocket Cloud Host.');
      });
    } catch (e) {
      _isRunning = false;
      throw Exception('فشل تشغيل البوت. تأكد من التوكن.');
    }
  }

  Future<void> stopBot() async {
    if (_bot != null) {
      await _bot!.close();
      _bot = null;
    }
    _isRunning = false;
  }
}
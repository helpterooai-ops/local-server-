import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/widgets.dart' hide Router;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// ---------------------------------------------------------
// المتغيرات والدوال الخاصة بالخلفية (يجب أن تكون خارج الكلاس)
// ---------------------------------------------------------
HttpServer? _backgroundServer;
String? _backgroundHtml;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // إلزامي لتفعيل الـ Plugins داخل عزلة الخلفية (Background Isolate)
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  if (service is AndroidServiceInstance) {
    // ترقية فورية لـ Foreground Service — تمنع أندرويد من قتل التطبيق
    // بسبب تجاوز مهلة الـ 5 ثوانٍ (ForegroundServiceDidNotStartInTimeException)
    service.setAsForegroundService();

    service.on('stopService').listen((event) async {
      await _backgroundServer?.close(force: true);
      service.stopSelf();
    });

    service.on('updateWebsite').listen((event) async {
      // استلام البيانات كـ Map بشكل صحيح
      if (event != null && event.containsKey('html')) {
        _backgroundHtml = event['html'].toString();
        await _startBackgroundServer();
      }
    });

    service.on('stopServer').listen((event) async {
      await _backgroundServer?.close(force: true);
      _backgroundServer = null;
    });
  }
}

// دالة تشغيل الخادم الفعلي داخل العزلة (Isolate)
Future<void> _startBackgroundServer() async {
  await _backgroundServer?.close(force: true);
  if (_backgroundHtml == null) return;

  try {
    final router = Router();
    router.get('/', (Request request) {
      return Response.ok(
        _backgroundHtml!,
        headers: {'Content-Type': 'text/html; charset=utf-8'},
      );
    });

    _backgroundServer = await io.serve(router, InternetAddress.anyIPv4, 8080);
  } catch (e) {
    // تجاهل الأخطاء في الخلفية
  }
}

// ---------------------------------------------------------
// الكلاس الخاص بواجهة المستخدم (UI Isolate)
// ---------------------------------------------------------
class BackgroundServerService {
  static final BackgroundServerService _instance = BackgroundServerService._internal();
  factory BackgroundServerService() => _instance;
  BackgroundServerService._internal();

  final FlutterBackgroundService _service = FlutterBackgroundService();

  Future<void> initialize() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart, // استدعاء الدالة الخارجية
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'pocket_cloud_server',
        initialNotificationTitle: 'Pocket Cloud Host',
        initialNotificationContent: 'الخادم المحلي قيد التشغيل...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground, // دالة مطلوبة لـ iOS
      ),
    );
  }

  Future<void> startService(String htmlContent) async {
    // طلب صلاحية الإشعارات - إلزامية من أندرويد 13+
    await Permission.notification.request();

    final isRunning = await _service.isRunning();

    if (!isRunning) {
      await _service.startService();
      // إعطاء مهلة بسيطة جداً للخلفية لكي تبدأ قبل إرسال البيانات
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // إرسال البيانات بصيغة Map صحيحة
    _service.invoke('updateWebsite', {'html': htmlContent});
  }

  Future<void> stopService() async {
    _service.invoke('stopServer');
    _service.invoke('stopService');
  }

  Future<bool> isServiceRunning() async {
    return await _service.isRunning();
  }
}

// دالة ضرورية لتشغيل الخلفية في نظام iOS (حتى لو كان تركيزك على الأندرويد)
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}
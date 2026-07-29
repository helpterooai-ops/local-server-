import 'dart:async';
import 'dart:io';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

class BackgroundServerService {
  static final BackgroundServerService _instance = BackgroundServerService._internal();
  factory BackgroundServerService() => _instance;
  BackgroundServerService._internal();

  final FlutterBackgroundService _service = FlutterBackgroundService();
  HttpServer? _server;
  String? _currentHtml;

  Future<void> initialize() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'pocket_cloud_server',
        initialNotificationTitle: 'Pocket Cloud Host',
        initialNotificationContent: 'الخادم المحلي قيد التشغيل...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onStart,
      ),
    );
  }

  @pragma('vm:entry-point')
  Future<bool> _onStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    
    if (service is AndroidServiceInstance) {
      service.on('stopService').listen((event) {
        service.stopSelf();
      });

      service.on('updateWebsite').listen((event) {
        if (event != null) {
          _currentHtml = event.toString();
          _startServer();
        }
      });

      service.on('stopServer').listen((event) {
        _stopServer();
      });
    }

    _startServer();
    return true;
  }

  Future<void> _startServer() async {
    await _stopServer();
    if (_currentHtml == null) return;

    try {
      final router = Router();
      router.get('/', (Request request) {
        return Response.ok(
          _currentHtml!,
          headers: {'Content-Type': 'text/html; charset=utf-8'},
        );
      });

      _server = await io.serve(router, InternetAddress.anyIPv4, 8080);
      _updateNotification();
    } catch (e) {
      // Ignore errors in background
    }
  }

  Future<void> _stopServer() async {
    await _server?.close(force: true);
    _server = null;
  }

  void _updateNotification() {
    _service.invoke('updateNotification', {
      'notificationTitle': 'Pocket Cloud Host',
      'notificationContent': _server != null
          ? 'الخادم المحلي يعمل على المنفذ 8080'
          : 'الخادم المحلي متوقف',
    });
  }

  Future<void> startService(String htmlContent) async {
    _currentHtml = htmlContent;
    final isRunning = await _service.isRunning();
    if (!isRunning) {
      await _service.startService();
    } else {
      _service.invoke('updateWebsite', {_currentHtml});
    }
  }

  Future<void> stopService() async {
    await _stopServer();
    _service.invoke('stopServer');
    _service.invoke('stopService');
  }

  Future<bool> isServiceRunning() async {
    return await _service.isRunning();
  }
}
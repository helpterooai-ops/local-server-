import 'dart:math';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

class LiveSession {
  final String id;
  final List<String> filePaths;
  final Map<String, bool> fileVisibility; // path -> isVisible
  final int durationMinutes;
  final String? staticPassword;
  final bool useOtp;
  String? otpPassword;
  final List<String> allowedIps;
  DateTime expiry;
  bool isOtpConsumed;

  LiveSession({
    required this.id,
    required this.filePaths,
    required this.fileVisibility,
    required this.durationMinutes,
    this.staticPassword,
    this.useOtp = false,
    this.otpPassword,
    this.allowedIps = const [],
    DateTime? expiry,
    this.isOtpConsumed = false,
  }) : expiry = expiry ?? DateTime.now().add(Duration(minutes: durationMinutes));

  bool get isExpired => DateTime.now().isAfter(expiry);
}

class LiveTunnelService {
  static final LiveTunnelService _instance = LiveTunnelService._internal();
  factory LiveTunnelService() => _instance;
  LiveTunnelService._internal();

  HttpServer? _server;
  LiveSession? _activeSession;

  // بدء الخادم بجلسة جديدة
  Future<String> startServer(LiveSession session) async {
    _activeSession = session;
    if (_server != null) {
      await _server!.close(force: true);
    }
    final router = Router();
    router.get('/retrieve', _handleRetrieveRequest);
    router.get('/file', _handleFileRequest);

    _server = await io.serve(router, InternetAddress.anyIPv4, 8080);
    return 'http://${_getLocalIp()}:8080/retrieve?session=${session.id}';
  }

  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
    _activeSession = null;
  }

  bool get isRunning => _server != null && _activeSession != null;
  LiveSession? get currentSession => _activeSession;

  // معالجة طلب الاسترداد (الصفحة الرئيسية للزائر)
  Future<Response> _handleRetrieveRequest(Request request) async {
    if (_activeSession == null) return Response.notFound('لا توجد جلسة نشطة.');
    // التحقق من هيدر التطبيق
    if (request.headers['x-pocket-client'] != 'pocket_cloud_host') {
      return Response.ok(
        '<html dir="rtl"><body style="font-family:sans-serif;text-align:center;padding-top:50px;">'
        '<h2>يرجى استخدام تطبيق Pocket Cloud Host لفتح هذا الرابط</h2>'
        '<p>هذا المحتوى لا يمكن الوصول إليه إلا من خلال التطبيق.</p>'
        '</body></html>',
        headers: {'Content-Type': 'text/html; charset=utf-8'},
      );
    }
    // التحقق من كود الجلسة
    final sessionId = request.url.queryParameters['session'];
    if (sessionId != _activeSession!.id) {
      return Response.forbidden('كود الجلسة غير صحيح.');
    }
    // التحقق من الصلاحية
    if (_activeSession!.isExpired) {
      return Response.forbidden('انتهت صلاحية الرابط.');
    }
    // التحقق من IP إذا كان مفعلاً
    if (_activeSession!.allowedIps.isNotEmpty) {
      final clientIp = request.headers['x-forwarded-for'] ?? request.connectionInfo?.remoteAddress.address ?? '';
      if (!_activeSession!.allowedIps.contains(clientIp)) {
        return Response.forbidden('عنوان IP غير مسموح به.');
      }
    }
    // التحقق من كلمة المرور الثابتة
    if (_activeSession!.staticPassword != null) {
      final password = request.url.queryParameters['pass'];
      if (password != _activeSession!.staticPassword) {
        return Response.forbidden('كلمة المرور غير صحيحة.');
      }
    }
    // التحقق من كلمة مرور OTP
    if (_activeSession!.useOtp) {
      final otp = request.url.queryParameters['otp'];
      if (_activeSession!.otpPassword == null) {
        // توليد OTP جديد عند أول طلب
        _activeSession!.otpPassword = _generateOtp();
      }
      if (otp != _activeSession!.otpPassword) {
        return Response.forbidden('كلمة المرور لمرة واحدة غير صحيحة.');
      }
      if (_activeSession!.isOtpConsumed) {
        return Response.forbidden('تم استخدام كلمة المرور لمرة واحدة مسبقاً.');
      }
      _activeSession!.isOtpConsumed = true;
    }
    // عرض قائمة الملفات المتاحة (المرئية فقط)
    final visibleFiles = _activeSession!.filePaths
        .where((path) => _activeSession!.fileVisibility[path] != false)
        .toList();
    return Response.ok(
      visibleFiles.join('\n'),
      headers: {'Content-Type': 'text/plain; charset=utf-8'},
    );
  }

  // طلب ملف محدد (للاستخدام المستقبلي)
  Future<Response> _handleFileRequest(Request request) async {
    return Response.notFound('غير مطبق بعد');
  }

  String _generateOtp() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  String _getLocalIp() {
    // محاولة الحصول على IP المحلي
    try {
      final interfaces = NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return 'localhost';
  }
}
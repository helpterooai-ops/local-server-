import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

class LocalServerService {
  // Singleton pattern
  static final LocalServerService _instance = LocalServerService._internal();
  factory LocalServerService() => _instance;
  LocalServerService._internal();

  HttpServer? _server;
  String? _currentHtml;

  Response _handler(Request request) {
    if (_currentHtml != null) {
      return Response.ok(
        _currentHtml!,
        headers: {'Content-Type': 'text/html; charset=utf-8'},
      );
    }
    return Response.notFound('لا يوجد موقع مستضاف حالياً.');
  }

  Future<String> start({int port = 8080}) async {
    if (_server != null) {
      return 'http://localhost:${_server!.port}';
    }
    try {
      _server = await shelf_io.serve(_handler, InternetAddress.anyIPv4, port);
      return 'http://localhost:${_server!.port}';
    } catch (e) {
      throw Exception('فشل تشغيل الخادم: $e');
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _currentHtml = null;
  }

  void updateWebsite(String htmlContent) {
    _currentHtml = htmlContent;
  }

  bool get isRunning => _server != null;
  int? get port => _server?.port;
}
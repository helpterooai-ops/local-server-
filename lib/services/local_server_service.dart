import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

class LocalServerService {
  // Singleton pattern
  static final LocalServerService _instance = LocalServerService._internal();
  factory LocalServerService() => _instance;
  LocalServerService._internal();

  HttpServer? _server;
  final Router _router = Router();
  String? _currentHtml;

  void _setupRouter() {
    // يجب مسح المسارات القديمة وإعادة بنائها
    _router.mount('/', (Request request) {
      if (_currentHtml != null) {
        return Response.ok(
          _currentHtml!,
          headers: {'Content-Type': 'text/html; charset=utf-8'},
        );
      }
      return Response.notFound('No website hosted yet.');
    });
  }

  Future<String> start({int port = 8080}) async {
    if (_server != null) {
      return 'http://localhost:${_server!.port}';
    }
    _setupRouter();
    try {
      _server = await io.serve(_router, InternetAddress.anyIPv4, port);
      return 'http://localhost:${_server!.port}';
    } catch (e) {
      throw Exception('Failed to start server: $e');
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _currentHtml = null;
  }

  void updateWebsite(String htmlContent) {
    _currentHtml = htmlContent;
    _setupRouter();
  }

  bool get isRunning => _server != null;
  int? get port => _server?.port;
}
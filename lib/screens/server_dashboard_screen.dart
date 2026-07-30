import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/local_server_service.dart';
import '../services/telegram_service.dart';

class ServerDashboardScreen extends StatefulWidget {
  const ServerDashboardScreen({super.key});

  @override
  State<ServerDashboardScreen> createState() => _ServerDashboardScreenState();
}

class _ServerDashboardScreenState extends State<ServerDashboardScreen> {
  // قيم ديناميكية يتم تحديثها
  int _activeHostings = 0;
  int _activeBots = 0;
  int _storedFiles = 0; // سيتم ربطه لاحقاً
  int _connectedVisitors = 0;
  double _cpuUsage = 0.0;
  double _memoryUsage = 0.0;
  double _dataTransfer = 0.0;
  bool _isServerRunning = false;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _updateData();
    // تحديث البيانات كل ثانيتين للحصول على قراءات شبه حية
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _updateData() {
    final server = LocalServerService();
    final botService = TelegramBotService();
    if (!mounted) return;
    setState(() {
      _isServerRunning = server.isRunning;
      _activeHostings = server.isRunning ? 1 : 0; // استضافة واحدة نشطة
      _activeBots = botService.isRunning ? 1 : 0; // بوت واحد نشط
      // الأرقام الأخرى تبقى صفرًا مؤقتًا حتى تتوفر مصادر حقيقية
      // يمكن تقدير CPU/RAM عبر نظام التشغيل لاحقًا
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'لوحة الخادم',
          style: GoogleFonts.ibmPlexSansArabic(
            textStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        actions: [
          // مؤشر حالة الخادم
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isServerRunning
                  ? const Color(0xFF38A169).withValues(alpha: 0.1)
                  : const Color(0xFFE53E3E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isServerRunning
                        ? const Color(0xFF38A169)
                        : const Color(0xFFE53E3E),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isServerRunning ? 'يعمل' : 'متوقف',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isServerRunning
                        ? const Color(0xFF38A169)
                        : const Color(0xFFE53E3E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            Text(
              'نظرة عامة',
              style: GoogleFonts.ibmPlexSansArabic(
                textStyle: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // صف الإحصائيات الأول
            Row(
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.web_outlined,
                  label: 'استضافات نشطة',
                  value: '$_activeHostings',
                  color: const Color(0xFF3182CE),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  icon: Icons.smart_toy_outlined,
                  label: 'بوتات عاملة',
                  value: '$_activeBots',
                  color: const Color(0xFF00A3C4),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // صف الإحصائيات الثاني
            Row(
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.folder_outlined,
                  label: 'ملفات مخزنة',
                  value: '$_storedFiles',
                  color: const Color(0xFFDD6B20),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  icon: Icons.people_outline,
                  label: 'زوار متصلون',
                  value: '$_connectedVisitors',
                  color: const Color(0xFF2F855A),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // عنوان المراقبة
            Text(
              'مراقبة الموارد',
              style: GoogleFonts.ibmPlexSansArabic(
                textStyle: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // بطاقة المعالج
            _buildResourceCard(
              context,
              icon: Icons.memory_outlined,
              label: 'المعالج (CPU)',
              usagePercent: _cpuUsage,
              color: const Color(0xFF805AD5),
            ),
            const SizedBox(height: 12),

            // بطاقة الذاكرة
            _buildResourceCard(
              context,
              icon: Icons.storage_outlined,
              label: 'الذاكرة (RAM)',
              usagePercent: _memoryUsage,
              color: const Color(0xFF3182CE),
            ),
            const SizedBox(height: 12),

            // بطاقة نقل البيانات
            _buildResourceCard(
              context,
              icon: Icons.swap_vert_outlined,
              label: 'نقل البيانات',
              usageValue: '${_dataTransfer.toStringAsFixed(1)} GB',
              color: const Color(0xFF38A169),
            ),
            const SizedBox(height: 32),

            // مساحة للرسم البياني مستقبلاً
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      size: 48,
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'رسم بياني لحظي',
                      style: GoogleFonts.ibmPlexSansArabic(
                        textStyle: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    Text(
                      'سيتم تفعيله مع البيانات الحقيقية',
                      style: GoogleFonts.ibmPlexSansArabic(
                        textStyle: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة إحصائية صغيرة
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.ibmPlexSansArabic(
                textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.ibmPlexSansArabic(
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة مراقبة الموارد مع شريط تقدم
  Widget _buildResourceCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    double? usagePercent,
    String? usageValue,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.ibmPlexSansArabic(
                    textStyle:
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                  ),
                ),
                const SizedBox(height: 8),
                if (usagePercent != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: usagePercent,
                      minHeight: 6,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            usageValue ?? '${((usagePercent ?? 0) * 100).toStringAsFixed(1)}%',
            style: GoogleFonts.ibmPlexSansArabic(
              textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
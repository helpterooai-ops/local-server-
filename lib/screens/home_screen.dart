import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_drawer.dart' as drawer_widget; // استيراد مستعار لتجنب التعارض
import '../services/local_server_service.dart';
import '../services/telegram_service.dart';
import 'web_hosting_screen.dart';
import 'telegram_bots_screen.dart';
import 'file_manager_screen.dart';
import 'live_tunnels_screen.dart' as live_tunnels;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final double _storageUsed = 0.0;
  final int _activeTunnels = 0;
  bool _isServerActive = LocalServerService().isRunning;
  bool _isBotActive = TelegramBotService().isRunning;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshServerStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshServerStatus();
    }
  }

  void _refreshServerStatus() {
    setState(() {
      _isServerActive = LocalServerService().isRunning;
      _isBotActive = TelegramBotService().isRunning;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'المستخدم';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const drawer_widget.AppDrawer(), // استخدام الاسم المستعار
      appBar: AppBar(
        title: Text(
          'لوحة التحكم',
          style: GoogleFonts.ibmPlexSansArabic(
            textStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً، $userName 👋',
              style: GoogleFonts.ibmPlexSansArabic(
                textStyle: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'منصة الاستضافة السحابية في جيبك',
              style: GoogleFonts.ibmPlexSansArabic(
                textStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'حالة الخادم',
                  value: _isServerActive ? 'يعمل' : 'متوقف',
                  icon: Icons.dns_outlined,
                  valueColor: _isServerActive
                      ? const Color(0xFF38A169)
                      : const Color(0xFFE53E3E),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  title: 'المساحة المستخدمة',
                  value: '${_storageUsed.toStringAsFixed(1)} GB',
                  icon: Icons.cloud_outlined,
                  valueColor: colorScheme.onSurface,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTunnelIndicator(context),
            const SizedBox(height: 32),
            Text(
              'الخدمات',
              style: GoogleFonts.ibmPlexSansArabic(
                textStyle: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.code_rounded,
              title: 'محرر الأكواد',
              subtitle: _isServerActive ? 'الخادم نشط الآن' : 'استضافة مواقع ويب تفاعلية',
              color: _isServerActive ? const Color(0xFF38A169) : const Color(0xFF3182CE),
              isActive: _isServerActive,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WebHostingScreen()),
                );
                _refreshServerStatus();
              },
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context,
              icon: Icons.smart_toy_outlined,
              title: 'بوتات تيليجرام',
              subtitle: _isBotActive ? 'بوت نشط يعمل الآن' : 'تشغيل بوتات محلية في الخلفية',
              color: _isBotActive ? const Color(0xFF38A169) : const Color(0xFF00A3C4),
              isActive: _isBotActive,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelegramBotsScreen()),
                );
                _refreshServerStatus();
              },
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context,
              icon: Icons.folder_outlined,
              title: 'مدير الملفات',
              subtitle: 'رفع، تخزين، ومشاركة الملفات',
              color: const Color(0xFFDD6B20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FileManagerScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context,
              icon: Icons.link_rounded,
              title: 'الأنفاق الحية',
              subtitle: 'روابط عامة مع مؤقت تدمير ذاتي',
              color: const Color(0xFF2F855A),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => live_tunnels.LiveTunnelsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary.withValues(alpha: 0.7), size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.ibmPlexSansArabic(
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.ibmPlexSansArabic(
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTunnelIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.04),
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
              color: const Color(0xFF2F855A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: Color(0xFF2F855A),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الروابط الحية النشطة',
                  style: GoogleFonts.ibmPlexSansArabic(
                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_activeTunnels روابط | لا توجد روابط نشطة',
                  style: GoogleFonts.ibmPlexSansArabic(
                    textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: 0.0,
              strokeWidth: 3.5,
              backgroundColor: colorScheme.outlineVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(
                color: const Color(0xFF38A169).withValues(alpha: 0.6),
                width: 2,
              )
            : null,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF38A169).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Card(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.ibmPlexSansArabic(
                          textStyle:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.ibmPlexSansArabic(
                          textStyle:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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
                if (isActive)
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF38A169),
                      shape: BoxShape.circle,
                    ),
                  ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
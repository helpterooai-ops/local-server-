import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_drawer.dart';
import 'web_hosting_screen.dart';
import 'telegram_bots_screen.dart';
import 'file_manager_screen.dart';
import 'live_tunnels_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bool _isServerRunning = false;
  final double _storageUsed = 0.0;
  final int _activeTunnels = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(),
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
              'مرحباً، ${user?.email?.split('@').first ?? 'المستخدم'} 👋',
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
                  value: _isServerRunning ? 'يعمل' : 'متوقف',
                  icon: Icons.dns_outlined,
                  valueColor: _isServerRunning
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
              subtitle: 'استضافة مواقع ويب تفاعلية',
              color: const Color(0xFF3182CE),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WebHostingScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context,
              icon: Icons.smart_toy_outlined,
              title: 'بوتات تيليجرام',
              subtitle: 'تشغيل بوتات محلية في الخلفية',
              color: const Color(0xFF00A3C4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelegramBotsScreen()),
                );
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
                  MaterialPageRoute(builder: (context) => const LiveTunnelsScreen()),
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
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.08),
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
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
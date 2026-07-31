import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/server_dashboard_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    // إعادة تحميل بيانات المستخدم لضمان تحديث displayName
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = _user ?? FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 12, bottom: 12, right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(4, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.person_2_outlined,
                        size: 30,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.displayName ?? 'المستخدم',
                      style: GoogleFonts.ibmPlexSansArabic(
                        textStyle: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? 'مستضيف سحابي',
                      style: GoogleFonts.ibmPlexSansArabic(
                        textStyle: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(height: 16),
              _buildDrawerItem(
                context,
                icon: Icons.dashboard_outlined,
                title: 'الرئيسية',
                onTap: () => Navigator.pop(context),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.analytics_outlined,
                title: 'لوحة الخادم',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ServerDashboardScreen()),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.person_outline,
                title: 'الملف الشخصي',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.dns_outlined,
                title: 'إدارة الاستضافات',
                onTap: () => Navigator.pop(context),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.storage_outlined,
                title: 'الملفات السحابية',
                onTap: () => Navigator.pop(context),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.link_outlined,
                title: 'الروابط الحية',
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(height: 8),
              _buildDrawerItem(
                context,
                icon: Icons.settings_outlined,
                title: 'الإعدادات',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.palette_outlined,
                title: 'تخصيص المظهر',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? textColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveIconColor = iconColor ?? colorScheme.onSurface.withValues(alpha: 0.7);
    final effectiveTextColor = textColor ?? colorScheme.onSurface.withValues(alpha: 0.8);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: effectiveIconColor, size: 22),
        title: Text(
          title,
          style: GoogleFonts.ibmPlexSansArabic(
            textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: effectiveTextColor,
                ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
        hoverColor: colorScheme.primary.withValues(alpha: 0.04),
        splashColor: colorScheme.primary.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }
}
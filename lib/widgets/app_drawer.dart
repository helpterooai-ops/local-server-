import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة المستخدم المصغرة في الأعلى
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.05),
                    colorScheme.primary.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة المستخدم
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
                    'محمد أحمد',
                    style: GoogleFonts.cairo(
                      textStyle: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'مطور ومستضيف سحابي',
                    style: GoogleFonts.cairo(
                      textStyle: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
            const SizedBox(height: 16),

            // عناصر القائمة
            _buildDrawerItem(
              context,
              icon: Icons.dashboard_outlined,
              title: 'الرئيسية',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.dns_outlined,
              title: 'إدارة الاستضافات',
              onTap: () {
                Navigator.pop(context);
                // TODO: الانتقال لصفحة الاستضافات
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.storage_outlined,
              title: 'الملفات السحابية',
              onTap: () {
                Navigator.pop(context);
                // TODO: الانتقال لمدير الملفات
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.link_outlined,
              title: 'الروابط الحية',
              onTap: () {
                Navigator.pop(context);
                // TODO: الانتقال للأنفاق
              },
            ),
            const Spacer(),

            // العناصر السفلية
            const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
            const SizedBox(height: 8),
            _buildDrawerItem(
              context,
              icon: Icons.settings_outlined,
              title: 'الإعدادات',
              onTap: () {
                Navigator.pop(context);
                // TODO: الانتقال للإعدادات
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.palette_outlined,
              title: 'تخصيص المظهر',
              onTap: () {
                Navigator.pop(context);
                // TODO: فتح مخصص المظهر
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.logout_rounded,
              title: 'تسجيل الخروج',
              textColor: const Color(0xFFE53E3E),
              iconColor: const Color(0xFFE53E3E),
              onTap: () {
                Navigator.pop(context);
                // TODO: عملية تسجيل الخروج
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // عنصر قائمة واحد بتصميم هادئ
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
          style: GoogleFonts.cairo(
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
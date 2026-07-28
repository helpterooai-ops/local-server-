import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TelegramBotsScreen extends StatelessWidget {
  const TelegramBotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'بوتات تيليجرام',
          style: GoogleFonts.cairo(
            textStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.smart_toy_outlined,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 24),
              Text(
                'بوتات تيليجرام',
                style: GoogleFonts.cairo(
                  textStyle: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'سيتم إضافة إمكانية تشغيل وإدارة بوتات\nتيليجرام مباشرة من هاتفك.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  textStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: فتح صفحة إضافة بوت جديد لاحقاً
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'إضافة بوت جديد',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
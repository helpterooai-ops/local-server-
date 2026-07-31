import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FileManagerScreen extends StatelessWidget {
  const FileManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'مدير الملفات',
          style: GoogleFonts.ibmPlexSansArabic(
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
                Icons.folder_outlined,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 24),
              Text(
                'مدير الملفات المرجعي',
                style: GoogleFonts.ibmPlexSansArabic(
                  textStyle: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'سيتم فهرسة ملفات جهازك مباشرة دون نسخها.\nاختر ما تريد مشاركته عبر الروابط الحية.',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansArabic(
                  textStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: فتح مستعرض ملفات الجهاز لاختيار ملفات للمشاركة
                },
                icon: const Icon(Icons.folder_open, size: 18),
                label: Text(
                  'استعراض ملفات الجهاز',
                  style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600),
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
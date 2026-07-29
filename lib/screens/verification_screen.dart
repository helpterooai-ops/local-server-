import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final AuthService _authService = AuthService();
  bool _isResending = false;
  bool _isChecking = false;
  String? _message;

  Future<void> _resendVerification() async {
    setState(() {
      _isResending = true;
      _message = null;
    });
    try {
      await _authService.resendVerificationEmail();
      setState(() {
        _message = 'تم إعادة إرسال رابط التحقق. تفقد بريدك الإلكتروني.';
      });
    } catch (e) {
      setState(() {
        _message = 'تعذر إرسال رابط التحقق. حاول مرة أخرى لاحقاً.';
      });
    } finally {
      setState(() => _isResending = false);
    }
  }

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
      _message = null;
    });
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        // ✅ تم التحقق - توجيه فوري إلى الصفحة الرئيسية
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
        return;
      }
      setState(() {
        _message = 'لم يتم التحقق بعد. الرجاء الضغط على الرابط المرسل إلى بريدك الإلكتروني.';
      });
    } catch (e) {
      setState(() {
        _message = 'تعذر التحقق من الحالة. تأكد من اتصالك بالإنترنت.';
      });
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: 50,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'تحقق من بريدك الإلكتروني',
                style: GoogleFonts.ibmPlexSansArabic(
                  textStyle: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'تم إرسال رابط تحقق إلى:\n${user?.email ?? 'بريدك الإلكتروني'}',
                style: GoogleFonts.ibmPlexSansArabic(
                  textStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'الرجاء الضغط على الرابط في الرسالة لتأكيد حسابك.\nإذا لم تجد الرسالة، تحقق من مجلد البريد المهمل.',
                style: GoogleFonts.ibmPlexSansArabic(
                  textStyle: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              if (_message != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _message!.contains('تم')
                        ? const Color(0xFF38A169).withValues(alpha: 0.1)
                        : const Color(0xFFE53E3E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _message!.contains('تم')
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        color: _message!.contains('تم')
                            ? const Color(0xFF38A169)
                            : const Color(0xFFE53E3E),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _message!,
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: _message!.contains('تم')
                                ? const Color(0xFF38A169)
                                : const Color(0xFFE53E3E),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkVerification,
                  icon: const Icon(Icons.verified_outlined, size: 20),
                  label: Text(
                    'تحققت من بريدي',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _isResending ? null : _resendVerification,
                  icon: _isResending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 20),
                  label: Text(
                    _isResending ? 'جارٍ الإرسال...' : 'إعادة إرسال الرابط',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _signOut,
                child: Text(
                  'تسجيل الخروج',
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: const Color(0xFFE53E3E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
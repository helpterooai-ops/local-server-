import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _message = 'الرجاء إدخال بريدك الإلكتروني.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _authService.resetPassword(email);
      setState(() {
        _isSuccess = true;
        _message = 'تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني.\nإذا لم تجده، تحقق من مجلد البريد المزعج.';
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _message = 'تعذر إرسال رابط الاستعادة. تأكد من البريد الإلكتروني وحاول مجدداً.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'نسيت كلمة المرور',
          style: GoogleFonts.ibmPlexSansArabic(
            textStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.lock_reset,
              size: 64,
              color: colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لاستعادة كلمة المرور.',
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSansArabic(
                textStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                labelStyle: GoogleFonts.ibmPlexSansArabic(),
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_message != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? const Color(0xFF38A169).withValues(alpha: 0.1)
                      : const Color(0xFFE53E3E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                      color: _isSuccess ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _message!,
                        style: GoogleFonts.ibmPlexSansArabic(
                          color: _isSuccess ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleResetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'إرسال رابط الاستعادة',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
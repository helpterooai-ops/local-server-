import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _newPasswordError;
  String? _confirmPasswordError;

  String? _validatePasswordStrength(String password) {
    if (password.length < 8) {
      return 'كلمة المرور يجب أن لا تقل عن 8 أحرف.';
    }
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    if (!hasUpper || !hasLower || !hasDigit) {
      return 'يجب أن تحتوي كلمة المرور على حروف كبيرة وصغيرة وأرقام.';
    }
    for (int i = 0; i < password.length - 2; i++) {
      if (password[i] == password[i+1] && password[i+1] == password[i+2]) {
        return 'لا يُسمح بتكرار نفس الحرف أو الرقم 3 مرات متتالية.';
      }
    }
    for (int i = 0; i < password.length - 2; i++) {
      final current = password.codeUnitAt(i);
      final next = password.codeUnitAt(i+1);
      final next2 = password.codeUnitAt(i+2);
      if (next == current + 1 && next2 == next + 1 && current >= 48 && current <= 57) {
        return 'لا يُسمح بتسلسل أرقام تصاعدي (مثل 123).';
      }
      if (next == current - 1 && next2 == next - 1 && current >= 48 && current <= 57) {
        return 'لا يُسمح بتسلسل أرقام تنازلي (مثل 987).';
      }
    }
    return null;
  }

  Future<void> _handleChangePassword() async {
    setState(() {
      _errorMessage = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty) {
      setState(() => _errorMessage = 'الرجاء إدخال كلمة المرور الحالية.');
      return;
    }

    final strengthError = _validatePasswordStrength(newPassword);
    if (strengthError != null) {
      setState(() => _newPasswordError = strengthError);
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _confirmPasswordError = 'كلمة المرور غير متطابقة.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تغيير كلمة المرور بنجاح. الرجاء تسجيل الدخول مجدداً.',
                style: GoogleFonts.ibmPlexSansArabic()),
            backgroundColor: const Color(0xFF38A169),
          ),
        );
        // تسجيل الخروج وإرسال المستخدم لصفحة تسجيل الدخول
        await _authService.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'كلمة المرور الحالية غير صحيحة، أو حدث خطأ. حاول مجدداً.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          'تغيير كلمة المرور',
          style: GoogleFonts.ibmPlexSansArabic(
            textStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لتغيير كلمة مرورك، أدخل كلمة المرور الحالية ثم كلمة المرور الجديدة.',
              style: GoogleFonts.ibmPlexSansArabic(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الحالية',
                labelStyle: GoogleFonts.ibmPlexSansArabic(),
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                labelStyle: GoogleFonts.ibmPlexSansArabic(),
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _newPasswordError,
                errorStyle: GoogleFonts.ibmPlexSansArabic(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور الجديدة',
                labelStyle: GoogleFonts.ibmPlexSansArabic(),
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _confirmPasswordError,
                errorStyle: GoogleFonts.ibmPlexSansArabic(),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53E3E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFE53E3E), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: const Color(0xFFE53E3E),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleChangePassword,
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
                        'تحديث كلمة المرور',
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
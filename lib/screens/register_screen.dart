import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _successMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

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
    // منع تكرار نفس الحرف أكثر من مرتين متتاليتين
    for (int i = 0; i < password.length - 2; i++) {
      if (password[i] == password[i+1] && password[i+1] == password[i+2]) {
        return 'لا يُسمح بتكرار نفس الحرف أو الرقم 3 مرات متتالية.';
      }
    }
    // منع التسلسل التصاعدي أو التنازلي لأكثر من 3 أرقام متتالية
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

  Future<void> _handleRegister() async {
    // إعادة تعيين الأخطاء
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _successMessage = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    bool valid = true;

    if (name.isEmpty) {
      setState(() => _nameError = 'الرجاء إدخال اسمك.');
      valid = false;
    }

    if (!_isEmailValid(email)) {
      setState(() => _emailError = 'صيغة البريد الإلكتروني غير صحيحة.');
      valid = false;
    }

    final passwordStrengthError = _validatePasswordStrength(password);
    if (passwordStrengthError != null) {
      setState(() => _passwordError = passwordStrengthError);
      valid = false;
    }

    if (confirm != password) {
      setState(() => _confirmPasswordError = 'كلمة المرور غير متطابقة.');
      valid = false;
    }

    if (!valid) return;

    setState(() => _isLoading = true);

    try {
      User? user = await _authService.signUp(email, password);
      if (user != null) {
        await user.updateDisplayName(name);
      }
      setState(() {
        _isLoading = false;
        _successMessage = 'تم إنشاء الحساب بنجاح! سيتم توجيهك لتسجيل الدخول.';
      });
      // انتظار لإظهار رسالة النجاح ثم العودة بالبريد
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context, email);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'البريد الإلكتروني مستخدم بالفعل.';
          break;
        case 'invalid-email':
          message = 'صيغة البريد الإلكتروني غير صحيحة.';
          break;
        case 'weak-password':
          message = 'كلمة المرور ضعيفة جداً.';
          break;
        default:
          message = 'حدث خطأ. حاول مرة أخرى.';
      }
      setState(() {
        _isLoading = false;
        _passwordError = message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _passwordError = 'تعذر الاتصال بالخادم. تأكد من اتصالك بالإنترنت.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.person_add_outlined,
                    size: 40,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'إنشاء حساب جديد',
                style: GoogleFonts.ibmPlexSansArabic(
                  textStyle: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'أنشئ حسابك للوصول إلى خادمك السحابي الشخصي',
                style: GoogleFonts.ibmPlexSansArabic(
                  textStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // رسالة نجاح
              if (_successMessage != null)
                _buildMessageBox(
                  message: _successMessage!,
                  icon: Icons.check_circle_outline,
                  backgroundColor: const Color(0xFF38A169).withValues(alpha: 0.1),
                  textColor: const Color(0xFF38A169),
                ),

              // حقل الاسم - جديد
              TextField(
                controller: _nameController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  labelStyle: GoogleFonts.ibmPlexSansArabic(),
                  hintText: 'أدخل اسمك الكامل',
                  hintStyle: GoogleFonts.ibmPlexSansArabic(
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _nameError != null ? const Color(0xFFE53E3E) : colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorText: _nameError,
                  errorStyle: GoogleFonts.ibmPlexSansArabic(fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),

              // حقل البريد الإلكتروني
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  labelStyle: GoogleFonts.ibmPlexSansArabic(),
                  hintText: 'example@mail.com',
                  hintStyle: GoogleFonts.ibmPlexSansArabic(
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _emailError != null ? const Color(0xFFE53E3E) : colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorText: _emailError,
                  errorStyle: GoogleFonts.ibmPlexSansArabic(fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),

              // حقل كلمة المرور
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  labelStyle: GoogleFonts.ibmPlexSansArabic(),
                  hintText: '••••••••',
                  hintStyle: GoogleFonts.ibmPlexSansArabic(
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _passwordError != null ? const Color(0xFFE53E3E) : colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              if (_passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildMessageBox(
                    message: _passwordError!,
                    icon: Icons.info_outline,
                    backgroundColor: const Color(0xFFE53E3E).withValues(alpha: 0.1),
                    textColor: const Color(0xFFE53E3E),
                  ),
                ),

              const SizedBox(height: 16),

              // حقل تأكيد كلمة المرور
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  labelStyle: GoogleFonts.ibmPlexSansArabic(),
                  hintText: '••••••••',
                  hintStyle: GoogleFonts.ibmPlexSansArabic(
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _confirmPasswordError != null ? const Color(0xFFE53E3E) : colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorText: _confirmPasswordError,
                  errorStyle: GoogleFonts.ibmPlexSansArabic(fontSize: 12),
                ),
              ),

              const SizedBox(height: 32),

              // زر إنشاء الحساب
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'إنشاء حساب',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟',
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'تسجيل الدخول',
                        style: GoogleFonts.ibmPlexSansArabic(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBox({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.ibmPlexSansArabic(
                color: textColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
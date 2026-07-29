import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'change_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _emailError;
  bool _needsVerification = false;
  bool _isResending = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _emailError = null;
      _needsVerification = false;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!_isEmailValid(email)) {
      setState(() {
        _emailError = 'صيغة البريد الإلكتروني غير صحيحة.';
        _isLoading = false;
      });
      return;
    }

    try {
      await _authService.signIn(email, password);
      // نجاح تسجيل الدخول - AuthGate سيتولى التوجيه
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'لا يوجد حساب بهذا البريد الإلكتروني.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        // نحاول معرفة إذا كان الحساب موجوداً لكنه غير مؤكد
        try {
          final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
          if (methods.isNotEmpty) {
            setState(() {
              _needsVerification = true;
              _errorMessage = 'حسابك غير مؤكد. الرجاء تفقد بريدك الإلكتروني للتحقق.';
            });
          } else {
            message = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
            setState(() => _errorMessage = message);
          }
        } catch (_) {
          message = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
          setState(() => _errorMessage = message);
        }
      } else {
        switch (e.code) {
          case 'invalid-email':
            message = 'صيغة البريد الإلكتروني غير صحيحة.';
            break;
          case 'too-many-requests':
            message = 'محاولات كثيرة. الرجاء المحاولة لاحقاً.';
            break;
          default:
            message = 'حدث خطأ غير متوقع. حاول مرة أخرى.';
        }
        setState(() => _errorMessage = message);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'تعذر الاتصال بالخادم. تأكد من اتصالك بالإنترنت.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);
    try {
      await _authService.resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إرسال رابط التحقق. تفقد بريدك الإلكتروني.',
              style: GoogleFonts.ibmPlexSansArabic(),
            ),
            backgroundColor: const Color(0xFF38A169),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر إرسال رابط التحقق. حاول لاحقاً.',
              style: GoogleFonts.ibmPlexSansArabic(),
            ),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _goToRegister() async {
    final email = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
    if (email != null && email is String && email.isNotEmpty) {
      _emailController.text = email;
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
                    Icons.cloud_outlined,
                    size: 40,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'أهلاً بعودتك',
                style: GoogleFonts.ibmPlexSansArabic(
                  textStyle: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'سجل دخولك للوصول إلى خادمك السحابي الشخصي',
                style: GoogleFonts.ibmPlexSansArabic(
                  textStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _needsVerification
                        ? const Color(0xFF3182CE).withValues(alpha: 0.1)
                        : const Color(0xFFE53E3E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _needsVerification
                                ? Icons.mark_email_unread_outlined
                                : Icons.error_outline,
                            color: _needsVerification
                                ? const Color(0xFF3182CE)
                                : const Color(0xFFE53E3E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.ibmPlexSansArabic(
                                color: _needsVerification
                                    ? const Color(0xFF3182CE)
                                    : const Color(0xFFE53E3E),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_needsVerification) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _isResending ? null : _resendVerificationEmail,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(
                            'إعادة إرسال رابط التحقق',
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // أزرار نسيت كلمة المرور وتغييرها
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'نسيت كلمة المرور؟',
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen()),
                      );
                    },
                    child: Text(
                      'تغيير كلمة المرور',
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
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
                          'تسجيل الدخول',
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
                      'ليس لديك حساب؟',
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    TextButton(
                      onPressed: _goToRegister,
                      child: Text(
                        'إنشاء حساب',
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
}
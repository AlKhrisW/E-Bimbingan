import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/themes/app_theme.dart';
import '../../admin/views/admin_main_screen.dart';
import '../../mahasiswa/views/mahasiswa_main_screen.dart';
import '../../dosen/views/dosen_main.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/login_alert.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeIn = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _modernInput(
    String hint,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(30));

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
    );
  }

  void _navigateToDashboard(BuildContext context, UserModel user) {
    Widget destination;

    switch (user.role) {
      case 'admin':
        destination = AdminMainScreen(user: user);
        break;
      case 'dosen':
        destination = DosenMain(user: user);
        break;
      case 'mahasiswa':
        destination = MahasiswaMainScreen(user: user);
        break;
      default:
        setState(() {
          _errorMessage = 'Peran pengguna tidak dikenali.';
        });
        return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destination),
      (_) => false,
    );
  }

  void _submitLogin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<AuthViewModel>(context, listen: false);

      final userModel = await viewModel.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userModel != null) {
        setState(() {
          _errorMessage = null;
        });
        _navigateToDashboard(context, userModel);
      } else if (viewModel.errorMessage != null) {
        setState(() {
          _errorMessage = viewModel.errorMessage!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeIn,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // LOGO
                  AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 800),
                    child: Image.asset(
                      'assets/images/login/logo_ebimbingan.png',
                      height: 140,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    'Selamat Datang',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Masuk ke akun Anda',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),

                  const SizedBox(height: 20),

                  // ===== ALERT MODERN OTOMATIS HILANG =====
                  if (_errorMessage != null)
                    LoginAlert(
                      message: _errorMessage!,
                      onDismissed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                    ),

                  const SizedBox(height: 8),

                  // EMAIL INPUT
                  TextFormField(
                    controller: _emailController,
                    decoration: _modernInput('Email', Icons.person_outline),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Email wajib diisi' : null,
                  ),

                  const SizedBox(height: 18),

                  // PASSWORD INPUT
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: _modernInput(
                      'Kata Sandi',
                      Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Minimal 6 karakter'
                        : null,
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _errorMessage = 'Fitur reset password belum aktif.';
                        });
                      },
                      child: const Text(
                        'Lupa Kata Sandi?',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () => _submitLogin(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Masuk",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Akun dibuat oleh Admin Jurusan.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

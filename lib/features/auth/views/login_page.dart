// lib/features/auth/views/login_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/themes/app_theme.dart';
// Import Placeholder Dashboards (akan dibuat sebentar lagi)
import '../../admin/views/admin_dashboard.dart';
import '../../dosen/views/dosen_dashboard.dart';
import '../../mahasiswa/views/mahasiswa_dashboard.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'adminjur1@gmail.com');
  final _passwordController = TextEditingController(text: 'passwordadmin123');
  final _formKey = GlobalKey<FormState>();

  // Custom decoration style (Style kapsul dari AppTheme sudah digunakan secara implisit)
  InputDecoration _kapsulInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: Colors.grey.shade500),
    );
  }
  
  void _showSnackbar(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  void _navigateToDashboard(BuildContext context, UserModel user) {
    Widget destination;
    if (user.role == 'admin') {
      destination = AdminDashboard(user: user);
    } else if (user.role == 'dosen') {
      destination = DosenDashboard(user: user);
    } else if (user.role == 'mahasiswa') {
      destination = MahasiswaDashboard(user: user);
    } else {
      _showSnackbar(context, 'Peran pengguna tidak dikenali.', isError: true);
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destination),
      (Route<dynamic> route) => false,
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
        _navigateToDashboard(context, userModel);
      } else if (viewModel.errorMessage != null) {
        _showSnackbar(context, viewModel.errorMessage!, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                // --- LOGO ---
                SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/logo_ebimbingan.png', 
                    height: 150, 
                    fit: BoxFit.contain, 
                  ),
                ),
                
                const SizedBox(height: 50), 

                // --- TEKS SELAMAT DATANG ---
                Text(
                  'Selamat Datang',
                  textAlign: TextAlign.center, 
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black, 
                  ),
                ),
                const SizedBox(height: 5),
                
                // --- TEKS SUBTITLE ---
                Text(
                  'Masuk ke akun Anda yang sudah ada',
                  textAlign: TextAlign.center, 
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 40),
                
                // --- INPUT NAMA PENGGUNA (Email Logic) ---
                TextFormField(
                  controller: _emailController,
                  decoration: _kapsulInputDecoration('Nama Pengguna', Icons.person_outline),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || value.isEmpty) ? 'Nama pengguna wajib diisi.' : null,
                ),
                
                const SizedBox(height: 18),
                
                // --- INPUT KATA SANDI ---
                TextFormField(
                  controller: _passwordController,
                  decoration: _kapsulInputDecoration('Kata Sandi', Icons.lock_outline),
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6) ? 'Kata sandi minimal 6 karakter.' : null,
                ),
                
                // --- LUPA KATA SANDI ---
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                         // TODO: Panggil reset password logic
                         _showSnackbar(context, 'Fitur reset password belum aktif.', isError: false);
                      }, 
                      child: const Text(
                        'Lupa Kata Sandi?',
                        style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w600), // Merah Cerah
                      ),
                    ),
                  ),
                ),

                // --- TOMBOL MASUK (Utama) ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading ? null : () => _submitLogin(context), 
                    // Style diambil dari AppTheme.lightTheme.elevatedButtonTheme
                    child: viewModel.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Masuk"),
                  ),
                ),
                
                // --- Pesan Keamanan ---
                const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Akun dibuat oleh Admin Jurusan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
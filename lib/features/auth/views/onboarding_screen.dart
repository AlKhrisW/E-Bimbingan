// lib/features/auth/views/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import '../../../../core/themes/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardData = [
    {
      'image': 'assets/images/login/onboard1.png',
      'title': 'Mengajukan Bimbingan',
      'description':
          'Ajukan permintaan bimbingan dengan mudah dan terorganisir.',
    },
    {
      'image': 'assets/images/login/onboard2.png',
      'title': 'Riwayat Bimbingan',
      'description':
          'Lacak dan lihat catatan bimbingan yang telah dilakukan secara menyeluruh.',
    },
    {
      'image': 'assets/images/login/onboard3.png',
      'title': 'Siap Belajar &\nSiap Dibimbing',
      'description':
          'Bimbingan magang, progres, dan komunikasi dalam satu platform yang praktis.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- LOGIC BARU: Simpan status dan navigasi ---
  void _completeOnboarding(BuildContext context) async {
    // 1. Simpan flag bahwa user sudah melihat onboarding
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);

    if (!mounted) return;

    // 2. Pindah ke Halaman Login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _skipOnboarding(BuildContext context) {
    _completeOnboarding(context);
  }

  void _goToNextPage() {
    if (_currentPage < _onboardData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Jika halaman terakhir, simpan status selesai
      _completeOnboarding(context);
    }
  }
  // ----------------------------------------------

  Widget _buildOnboardPage(BuildContext context, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 50),

          // Gambar Onboarding
          Image.asset(
            data['image'],
            height: 300,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 50),

          // Teks Judul
          Text(
            data['title'],
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 28,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 10),

          // Teks Deskripsi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              data['description'],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    height: 1.5,
                  ),
            ),
          ),

          const Spacer(),
          const SizedBox(height: 140),
        ],
      ),
    );
  }

  // Widget terpisah untuk Indikator Titik
  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardData.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: index == _currentPage ? 25 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentPage
                ? AppTheme.primaryColor
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _onboardData.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // --- PageView (Content Utama) ---
            PageView.builder(
              controller: _pageController,
              itemCount: _onboardData.length,
              itemBuilder: (context, index) {
                final data = _onboardData[index];
                return _buildOnboardPage(context, data);
              },
            ),

            // --- Tombol SKIP (Page 1 & 2): DIKANAN ATAS ---
            if (!isLastPage)
              Positioned(
                top: 10,
                right: 20,
                child: TextButton(
                  onPressed: () => _skipOnboarding(context),
                  child: Text(
                    'SKIP',
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            // --- Kontrol Navigasi (Bottom Layer) ---
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: isLastPage
                  ? Column(
                      // Halaman Terakhir: Tombol Masuk Besar
                      children: [
                        // Indikator Titik
                        _buildDotIndicators(),
                        const SizedBox(height: 30),

                        // Tombol Masuk (ElevatedButton)
                        ElevatedButton(
                          onPressed: _goToNextPage,
                          child: const Text('Masuk'),
                        ),
                      ],
                    )
                  : Row(
                      // Halaman 1 & 2: Dots + Floating Action Button
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 50),

                        // Indikator Titik
                        _buildDotIndicators(),

                        // Tombol NEXT (Floating Action Button)
                        FloatingActionButton(
                          heroTag: 'onboard_next',
                          backgroundColor: AppTheme.primaryColor,
                          onPressed: _goToNextPage,
                          child: const Icon(Icons.arrow_forward_ios,
                              color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
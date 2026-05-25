import 'package:change_life/features/settings/providers/setting_provider.dart';
import 'package:change_life/views/widgets/change_life_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigate sau 2 giây
    Future.delayed(const Duration(seconds: 2), _navigateNext);
  }

  void _navigateNext() {
    if (!mounted) return;
    final storage = ref.read(storageServiceProvider);

    final hasSeenOnboarding = storage.hasSeenOnboarding();
    final token = storage.getToken();

    if (!mounted) return;
    if (!hasSeenOnboarding) {
      context.go('/onboarding');
    } else if (token != null) {
      context.go('/habit');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Glow + Icon ──
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow halo
                        Opacity(
                          opacity: _glowAnim.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                                  blurRadius: 48,
                                  spreadRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Logo widget
                        const ChangeLifeLogo(size: 100),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── App Name ──
                    Text(
                      'CHANGE LIFE',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Thin divider ──
                    Container(
                      width: 180,
                      height: 1,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),

                    // ── Tagline ──
                    Opacity(
                      opacity: _glowAnim.value,
                      child: const Text(
                        'BUILD DISCIPLINE.',
                        style: TextStyle(
                          color: Color(0xFF555555),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bookshelf_screen.dart';

class AnimeIntroScreen extends StatefulWidget {
  const AnimeIntroScreen({super.key});

  @override
  State<AnimeIntroScreen> createState() => _AnimeIntroScreenState();
}

class _AnimeIntroScreenState extends State<AnimeIntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // 2.8-second punchy cinematic flash intro
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _controller.addListener(() {
      if (_controller.value >= 0.99 && !_hasNavigated) {
        _finishAndNavigate();
      }
    });

    _controller.forward();
  }

  void _finishAndNavigate() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const BookshelfScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: GestureDetector(
        onTap: _finishAndNavigate,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. "Harsh Raj" Cinematic Flash & Title Card
                _buildHarshRajFlash(t),

                // 2. Top-right Skip Button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 18,
                  child: _buildSkipButton(),
                ),

                // 3. Smooth Fade Out to White at End (t = 0.88 to 1.0)
                if (t >= 0.86)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.white.withValues(
                          alpha: ((t - 0.86) / 0.14).clamp(0.0, 1.0),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// "HARSH RAJ" Cinematic Flash & Title Card
  Widget _buildHarshRajFlash(double t) {
    // Opacity envelope: smooth fade-in, hold, fade-out
    double opacity = 1.0;
    if (t < 0.12) {
      opacity = (t / 0.12).clamp(0.0, 1.0);
    } else if (t > 0.82) {
      opacity = (1.0 - ((t - 0.82) / 0.14)).clamp(0.0, 1.0);
    }

    // Flash bloom at t = 0.08 to 0.32
    double flashIntensity = 0.0;
    if (t >= 0.08 && t <= 0.34) {
      flashIntensity = math.sin((t - 0.08) / 0.26 * math.pi);
    }

    // Camera scale push
    final scale = 1.0 + (t * 0.15);

    // Text shimmer sweep across golden letters
    final shimmerProgress = ((t - 0.15) / 0.50).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Celestial dark background with floating gold embers
          CustomPaint(
            painter: ParticleDustPainter(
              time: t * 6.0,
              particleColor: const Color(0xFFE5C07B),
              count: 35,
            ),
          ),

          // Central title card
          Center(
            child: Transform.scale(
              scale: scale,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'P R E S E N T S',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        letterSpacing: 9,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFE2B867).withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // "HARSH RAJ" with gold gradient and animated shimmer sweep
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: const [
                            Color(0xFFFFF6D6),
                            Color(0xFFFFDF73),
                            Color(0xFFE5A642),
                            Color(0xFFFFF6D6),
                            Color(0xFFD49335),
                          ],
                          stops: [
                            0.0,
                            shimmerProgress * 0.6,
                            shimmerProgress,
                            (shimmerProgress + 0.3).clamp(0.0, 1.0),
                            1.0,
                          ],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'HARSH RAJ',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          fontSize: 46,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 11,
                          color: Colors.white,
                          shadows: [
                            BoxShadow(
                              color: const Color(0xFFF4A261).withValues(alpha: 0.75),
                              blurRadius: 35,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Decorative golden divider line with diamond icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 65,
                          height: 1.2,
                          color: const Color(0xFFE5A642).withValues(alpha: 0.65),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.auto_awesome,
                            size: 15,
                            color: const Color(0xFFFFDF73).withValues(alpha: 0.95),
                          ),
                        ),
                        Container(
                          width: 65,
                          height: 1.2,
                          color: const Color(0xFFE5A642).withValues(alpha: 0.65),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'A  C I N E M A T I C   J O U R N A L   V I S I O N',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        letterSpacing: 5.0,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Explosive Radial Flash Bloom
          if (flashIntensity > 0)
            Positioned.fill(
              child: Opacity(
                opacity: flashIntensity * 0.92,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Colors.white.withValues(alpha: 0.98),
                        const Color(0xFFFFEAA7).withValues(alpha: 0.75),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Discreet Top-Right Skip Button
  Widget _buildSkipButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _finishAndNavigate,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SKIP',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.fast_forward_rounded, size: 14, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dynamic Floating Dust Particles Painter (Golden embers)
class ParticleDustPainter extends CustomPainter {
  final double time;
  final Color particleColor;
  final int count;

  ParticleDustPainter({
    required this.time,
    required this.particleColor,
    this.count = 30,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final seedX = (math.sin(i * 99.7) * 0.5 + 0.5);
      final seedY = (math.cos(i * 33.1) * 0.5 + 0.5);
      final speed = 0.3 + (i % 5) * 0.15;
      final radius = 1.0 + (i % 4) * 0.9;

      final currentY = (seedY * size.height - (time * 25.0 * speed)) % size.height;
      final currentX = (seedX * size.width + math.sin(time + i) * 16.0) % size.width;

      final alpha = (0.2 + 0.6 * math.sin(time * 2.0 + i)).clamp(0.1, 0.85);
      paint.color = particleColor.withValues(alpha: alpha);

      canvas.drawCircle(Offset(currentX, currentY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticleDustPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

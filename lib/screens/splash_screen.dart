import 'package:flutter/material.dart';
import 'package:shakelha_mp/screens/home_shell.dart';
import 'package:shakelha_mp/widgets/gameBG.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 0.85, end: 1)
        .animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));

    _fadeController.forward();
    _scaleController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(HomeShell.routeName);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GameUi(),
          SafeArea(
            child: AnimatedBuilder(
              animation: Listenable.merge([_fade, _scale]),
              builder: (context, child) {
                return Opacity(
                  opacity: _fade.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                'شكّلها',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      shadows: const [
                                        Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black26),
                                      ],
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Shakelha',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white70,
                                      letterSpacing: 2,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          height: 180,
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.08),
                            border: Border.all(color: Colors.white30, width: 2),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _MascotIcon(icon: '📜', label: 'حرف'),
                                _MascotIcon(icon: '☕', label: 'قهوة'),
                                _MascotIcon(icon: '🌴', label: 'نخلة'),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotIcon extends StatelessWidget {
  final String icon;
  final String label;
  const _MascotIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFFFD54F), width: 2),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        )
      ],
    );
  }
}

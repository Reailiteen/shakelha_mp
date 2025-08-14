import 'package:flutter/material.dart';
import 'package:mp_tictactoe/responsive/responsive.dart';
import 'package:mp_tictactoe/screens/create_room_screen.dart';
import 'package:mp_tictactoe/screens/join_room_screen.dart';
import 'package:mp_tictactoe/screens/pass_play_screen.dart';
import 'package:mp_tictactoe/widgets/custom_button.dart';

class MainMenuScreen extends StatelessWidget {
  static String routeName = '/main-menu';
  const MainMenuScreen({Key? key}) : super(key: key);

  void createRoom(BuildContext context) {
    Navigator.pushNamed(context, CreateRoomScreen.routeName);
  }

  void joinRoom(BuildContext context) {
    Navigator.pushNamed(context, JoinRoomScreen.routeName);
  }

  void passPlay(BuildContext context) {
    Navigator.pushNamed(context, PassPlayScreen.routeName);
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'قريباً',
          textAlign: TextAlign.center,
        ),
        content: Text(
          'ميزة "$feature" ستكون متاحة قريباً!'
              ,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF122033),
              Color(0xFF1E3A5F),
              Color(0xFF2B4E6E),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Responsive(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Top bar: mock currencies and season progress (UI only)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _chip(context, Icons.monetization_on, '2500', const Color(0xFFFFD54F)),
                      _chip(context, Icons.trending_up, '65%', const Color(0xFF26A69A)),
                      _chip(context, Icons.diamond, '150', Colors.purpleAccent),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Center(
                    child: Text(
                      'شكّلها',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Create / Join primary actions
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        onTap: () => createRoom(context),
                        text: 'إنشاء غرفة',
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        onTap: () => joinRoom(context),
                        text: 'انضمام إلى غرفة',
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        onTap: () => passPlay(context),
                        text: 'تمرير واللعب (محلي)',
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bottom actions
                  Row(
                    children: [
                      Expanded(
                        child: _bottomButton(
                          context,
                          title: 'مساعدة',
                          icon: Icons.help_outline,
                          onTap: () => _showComingSoonDialog(context, 'مساعدة'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _bottomButton(
                          context,
                          title: 'الإعدادات',
                          icon: Icons.settings,
                          onTap: () => _showComingSoonDialog(context, 'الإعدادات'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButton(BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF6D4C41).withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF6D4C41),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

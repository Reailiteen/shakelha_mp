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
        backgroundColor: const Color(0xFF2B4E6E),
        title: Text(
          'قريباً',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'ميزة "$feature" ستكون متاحة قريباً!'
              ,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Responsive(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            // Top bar: mock currencies and season progress (UI only)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _chip(context, Icons.monetization_on, '2500', const Color(0xFFFFD54F)),
                _chip(context, Icons.trending_up, '65%', const Color(0xFF26A69A)),
                _chip(context, Icons.diamond, '150', Colors.purpleAccent),
              ],
            ),

            const SizedBox(height: 18),

            // Title
            Center(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'شكّلها',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Create / Join primary actions
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  onTap: () => createRoom(context),
                  text: 'إنشاء غرفة',
                  glowColor: const Color(0xFF26A69A),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  onTap: () => joinRoom(context),
                  text: 'انضمام إلى غرفة',
                  glowColor: const Color(0xFF19B6A6),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  onTap: () => passPlay(context),
                  text: 'تمرير واللعب (محلي)',
                  glowColor: const Color(0xFFFFD54F),
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

            const SizedBox(height: 8),
          ],
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
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
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
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6D4C41).withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
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

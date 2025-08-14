import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mp_tictactoe/provider/game_provider.dart';

/// A decorative abilities bar inspired by the provided UI.
/// Non-invasive: only wires existing safe actions when possible.
class AbilitiesBar extends StatelessWidget {
  const AbilitiesBar({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    Widget abilityButton({
      required IconData icon,
      required Color color,
      required String tooltip,
      required VoidCallback? onTap,
      int usesLeft = 0,
    }) {
      final usable = onTap != null;
      return Opacity(
        opacity: usable ? 1 : 0.5,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 2),
              boxShadow: usable
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Center(child: Icon(icon, color: color, size: 24)),
                if (usesLeft > 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$usesLeft',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1DB7A6),
            Color(0xFF16A09A),
          ],
        ),
        border: Border.all(color: const Color(0xFFFFD54F).withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Swap letters -> maps to exchange flow if available
          abilityButton(
            icon: Icons.swap_horiz,
            color: const Color(0xFF1976D2),
            tooltip: 'تبديل الأحرف',
            onTap: game.canExchangeTiles() ? () => _showExchangeDialog(context, game) : null,
          ),
          // Reveal words -> decorative only for now
          abilityButton(
            icon: Icons.lightbulb,
            color: const Color(0xFFFFD54F),
            tooltip: 'رؤية المساعد',
            onTap: () => _showComingSoon(context, 'رؤية المساعد'),
          ),
          // Block square -> decorative only for now
          abilityButton(
            icon: Icons.block,
            color: const Color(0xFF8D6E63),
            tooltip: 'حظر مربع',
            onTap: () => _showComingSoon(context, 'حظر مربع'),
          ),
        ],
      ),
    );
  }

  void _showExchangeDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تبديل الأحرف'),
        content: const Text('اختر حرفاً من رفك ثم اضغط تبديل.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              game.exchangeSelectedTiles();
              Navigator.pop(context);
            },
            child: const Text('تبديل'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قريباً'),
        content: Text('ميزة "$feature" ستكون متاحة قريباً!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

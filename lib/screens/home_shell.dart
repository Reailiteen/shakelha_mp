import 'package:flutter/material.dart';
import 'package:shakelha_mp/screens/main_menu_screen.dart';
import 'package:shakelha_mp/screens/shop_screen.dart';
import 'package:shakelha_mp/widgets/game_page.dart';

/// HomeShell provides the main RTL navigation between Shop (left)
/// and Game menu (right, default).
class HomeShell extends StatefulWidget {
  static const routeName = '/home';
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final PageController _controller;
  int _current = 1; // 0 = Shop, 1 = Game (default)

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int index) {
    setState(() => _current = index);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGame = _current == 1;
    return GamePageShell(
      title: isGame ? 'اللعبة' : 'المتجر',
      child: Column(
        children: [
          // Top segmented control
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SegmentButton(
                      selected: !isGame,
                      label: 'المتجر',
                      onTap: () => _go(0),
                    ),
                  ),
                  Expanded(
                    child: _SegmentButton(
                      selected: isGame,
                      label: 'اللعبة',
                      onTap: () => _go(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Pages: 0 Shop, 1 Game Menu
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _current = i),
              children: const [
                ShopScreen(),
                MainMenuScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;
  const _SegmentButton({required this.selected, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}

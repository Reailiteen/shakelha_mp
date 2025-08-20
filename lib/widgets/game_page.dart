import 'package:flutter/material.dart';
import 'package:shakelha_mp/widgets/gameBG.dart';
import 'package:shakelha_mp/widgets/topbar.dart';

/// A reusable shell that applies the wooden game background, a top bar,
/// and a padded content area. Use this for all app screens to unify UI.
class GamePageShell extends StatelessWidget {
  const GamePageShell({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background - fills entire screen
          const Positioned.fill(
            child: GameUi(),
          ),
          // Content with SafeArea
          SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.085,
                    child: Topbar(currentText: title),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



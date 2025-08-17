import 'package:flutter/material.dart';

/// Game background + frame. Displays a full-screen background image,
/// an outer green outline, and an inner brown container that can host a Stack.
class GameUi extends StatelessWidget {
  const GameUi({super.key, this.child, this.backgroundAssetPath = 'lib/data/ui/game_bg_wooden.png'});

  /// Optional content layered inside the brown container as a Stack child.
  final Widget? child;

  /// Path to background asset (ensure it is declared in pubspec.yaml).
  final String backgroundAssetPath;

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundAssetPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Subtle dark overlay to improve foreground contrast (non-interactive)
        IgnorePointer(
          ignoring: true,
          child: Positioned.fill(
            child: Container(color: const Color.fromARGB(255, 162, 35, 35).withOpacity(0.16)),
          ),
        ),
        // Green outline frame
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF512103).withOpacity(0.55),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder layer; consumer screens can pass a child if needed
                  if (child != null) child!,
                ],
              ),
            ),
          ),
        ),
      
        // Outer green outline above background but does not block input
        IgnorePointer(
          ignoring: true,
          child: Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2D462D), width: 5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        // Inner brown container hosting a Stack for optional content
        ],
    );
  }
}
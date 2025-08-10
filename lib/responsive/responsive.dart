import 'package:flutter/material.dart';

/// A simple responsive container that centers content and constrains width
/// using common breakpoints. It also applies horizontal padding on small
/// screens for comfortable reading.
class Responsive extends StatelessWidget {
  final Widget child;
  const Responsive({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Breakpoints
        // < 700: mobile
        // 700 - 1100: tablet / small desktop
        // > 1100: desktop / wide
        double maxWidth;
        EdgeInsets padding;

        if (width < 700) {
          maxWidth = 560; // comfortable mobile content width
          padding = const EdgeInsets.symmetric(horizontal: 16);
        } else if (width < 1100) {
          maxWidth = 900; // tablet / small laptop
          padding = const EdgeInsets.symmetric(horizontal: 24);
        } else {
          maxWidth = 1200; // desktop
          padding = const EdgeInsets.symmetric(horizontal: 32);
        }

        return Center(
          child: Padding(
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

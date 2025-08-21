import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shakelha_mp/provider/responsive_provider.dart';
import 'package:shakelha_mp/theme.dart';

/// Fixed-Both container for different aspect-ratio groups
/// Centers the main content and fills extra space with background
class ResponsiveWidget extends StatelessWidget {
  final Widget child;
  const ResponsiveWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Update responsive provider with current constraints
        context.read<ResponsiveProvider>().updateConstraints(constraints);
        
        return Consumer<ResponsiveProvider>(
          builder: (context, responsive, _) {
            return Container(
              color: AppColors.backgroundExtra, // Light background for extra space
              padding: EdgeInsets.symmetric(
                horizontal: responsive.horizontalPadding,
                vertical: responsive.verticalPadding,
              ),
              child: Center(
                child: SizedBox(
                  width: responsive.contentWidth,
                  height: responsive.contentHeight,
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Helper widget to access responsive values easily
class ResponsiveWidgetWrapper extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveProvider responsive) builder;
  
  const ResponsiveWidgetWrapper({Key? key, required this.builder}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ResponsiveProvider>(
      builder: (context, responsive, _) => builder(context, responsive),
    );
  }
}

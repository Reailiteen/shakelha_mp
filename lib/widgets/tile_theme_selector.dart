import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shakelha_mp/provider/tile_theme_provider.dart';
import 'package:shakelha_mp/widgets/tileUI.dart';

/// Widget that allows users to select different tile themes
/// Demonstrates the usage of TileThemeProvider
class TileThemeSelector extends StatelessWidget {
  const TileThemeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TileThemeProvider>(
      builder: (context, tileTheme, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current theme display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Current Theme: ${tileTheme.getThemeName(tileTheme.currentTheme)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tileTheme.getThemeDescription(tileTheme.currentTheme),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Theme preview with sample tile
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  const Text(
                    'Preview:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Sample tile using current theme
                  TileUI(
                    width: 60,
                    height: 60,
                    letter: 'A',
                    points: 1,
                    left: 0,
                    top: 0,
                    // No tileColors specified - will use provider's current theme
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Theme selection buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tileTheme.availableThemes.map((theme) {
                final isSelected = theme == tileTheme.currentTheme;
                return ElevatedButton(
                  onPressed: () {
                    tileTheme.currentTheme = theme;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                    foregroundColor: isSelected ? Colors.white : Colors.black87,
                  ),
                  child: Text(tileTheme.getThemeName(theme)),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

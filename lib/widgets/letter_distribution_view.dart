import 'package:flutter/material.dart';
import 'package:shakelha_mp/models/letterDistribution.dart';
import 'package:shakelha_mp/widgets/tileUI.dart';

/// A reusable widget that displays the letter distribution for the game
/// Shows all letters with their counts and point values in an organized grid
class LetterDistributionView extends StatelessWidget {
  final LetterDistribution? letterDistribution;
  final bool showRemainingCounts;
  
  const LetterDistributionView({
    Key? key,
    this.letterDistribution,
    this.showRemainingCounts = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use Arabic distribution as default if none provided
    final distribution = letterDistribution ?? LetterDistribution.arabic();
    
    return Scaffold(
      backgroundColor: const Color(0xFF101828),
      appBar: AppBar(
        title: const Text(
          'توزيع الحروف',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16304A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(2.0), // Reduced from 16.0 to 12.0
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header information - made more compact
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6), // Reduced from 16 to 12
                decoration: BoxDecoration(
                  color: const Color(0xFF16304A),
                  borderRadius: BorderRadius.circular(8), // Reduced from 12 to 8
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    Text(
                      'إجمالي البلاطات: ${distribution.allTiles.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16, // Reduced from 18 to 16
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4), // Reduced from 8 to 4
                    if (showRemainingCounts)
                      Text(
                        'المتبقي في الكيس: ${distribution.tilesRemaining}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14, // Reduced from 16 to 14
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 6), // Reduced from 20 to 12
              
              // Letter distribution grid
              Expanded(
                child: _buildLetterGrid(distribution),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLetterGrid(LetterDistribution distribution) {
    // Group tiles by letter and count them
    final Map<String, int> letterCounts = {};
    final Map<String, int> letterValues = {};
    
    for (final tile in distribution.allTiles) {
      letterCounts[tile.letter] = (letterCounts[tile.letter] ?? 0) + 1;
      letterValues[tile.letter] = tile.value;
    }
    
    // Sort letters by count (descending) then by value (descending)
    final sortedLetters = letterCounts.keys.toList()
      ..sort((a, b) {
        final countComparison = letterCounts[b]!.compareTo(letterCounts[a]!);
        if (countComparison != 0) return countComparison;
        return letterValues[b]!.compareTo(letterValues[a]!);
      });

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8, // Increased from 4 to 5 for more compact layout
        childAspectRatio: 0.8, // Reduced from 1.2 to 0.8 for more vertical space
        crossAxisSpacing: 4, // Reduced from 12 to 8
        mainAxisSpacing: 4, // Reduced from 12 to 8
      ),
      itemCount: sortedLetters.length,
      itemBuilder: (context, index) {
        final letter = sortedLetters[index];
        final count = letterCounts[letter]!;
        final value = letterValues[letter]!;
        
        return _buildLetterCard(letter, count, value);
      },
    );
  }

  Widget _buildLetterCard(String letter, int count, int value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16304A),
        borderRadius: BorderRadius.circular(8), // Reduced from 12 to 8
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Letter tile preview - made smaller
          SizedBox(
            width: 30, // Reduced from 40 to 28
            height: 30, // Reduced from 40 to 28
            child: TileUI(
              width: 30, // Reduced from 40 to 28
              height: 30, // Reduced from 40 to 28
              letter: letter,
              points: value,
              left: 0,
              top: 0,
            ),
          ),
          
          // Count
          Text(
            '×$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14, // Reduced from 16 to 14
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Value
          Text(
            '$value نقطة',
            style: TextStyle(
              color: Colors.green[300],
              fontSize: 10, // Reduced from 12 to 10
            ),
          ),
        ],
      ),
    );
  }
}

/// A modal bottom sheet version of the letter distribution view
/// Useful for quick access without full screen navigation
class LetterDistributionBottomSheet extends StatelessWidget {
  final LetterDistribution? letterDistribution;
  
  const LetterDistributionBottomSheet({
    Key? key,
    this.letterDistribution,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4, // Reduced from 0.8 to 0.7
      decoration: const BoxDecoration(
        color: Color(0xFF101828),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8), // Reduced from 12 to 8
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title - made more compact
          Padding(
            padding: const EdgeInsets.all(12), // Reduced from 16 to 12
            child: Text(
              'توزيع الحروف',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18, // Reduced from 20 to 18
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Letter distribution content
          Expanded(
            child: LetterDistributionView(
              letterDistribution: letterDistribution,
              showRemainingCounts: true,
            ),
          ),
        ],
      ),
    );
  }
}

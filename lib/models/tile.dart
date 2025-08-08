import 'package:meta/meta.dart';

/// Represents a single tile/letter in the game.
/// Can be on the board, in a player's rack, or in the letter bag.
class Tile {
  /// The letter displayed on the tile
  final String letter;
  
  /// The point value of the tile
  final int value;
  
  /// Whether the tile is currently placed on the board
  final bool isOnBoard;
  
  /// Whether the tile was just placed in the current turn
  final bool isNewlyPlaced;
  
  /// The player ID who owns/placed this tile (null if in bag)
  final String? ownerId;

  const Tile({
    required this.letter,
    this.value = 1,
    this.isOnBoard = false,
    this.isNewlyPlaced = false,
    this.ownerId,
  });

  /// Creates a Tile from a JSON map
  factory Tile.fromJson(Map<String, dynamic> json) {
    return Tile(
      letter: json['letter'],
      value: json['value'] ?? 1,
      isOnBoard: json['isOnBoard'] ?? false,
      isNewlyPlaced: json['isNewlyPlaced'] ?? false,
      ownerId: json['ownerId'],
    );
  }

  /// Converts the tile to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'letter': letter,
      'value': value,
      'isOnBoard': isOnBoard,
      'isNewlyPlaced': isNewlyPlaced,
      'ownerId': ownerId,
    };
  }

  /// Creates a copy of this tile with updated fields
  Tile copyWith({
    String? letter,
    int? value,
    bool? isOnBoard,
    bool? isNewlyPlaced,
    String? ownerId,
  }) {
    return Tile(
      letter: letter ?? this.letter,
      value: value ?? this.value,
      isOnBoard: isOnBoard ?? this.isOnBoard,
      isNewlyPlaced: isNewlyPlaced ?? this.isNewlyPlaced,
      ownerId: ownerId ?? this.ownerId,
    );
  }
  
  @override
  String toString() => 'Tile($letter, value: $value)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tile &&
          runtimeType == other.runtimeType &&
          letter == other.letter &&
          value == other.value &&
          isOnBoard == other.isOnBoard &&
          isNewlyPlaced == other.isNewlyPlaced &&
          ownerId == other.ownerId;
          
  @override
  int get hashCode => Object.hash(letter, value, isOnBoard, isNewlyPlaced, ownerId);
}
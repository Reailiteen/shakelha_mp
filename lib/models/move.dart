import 'tile.dart';
import 'position.dart';

/// Represents a placed tile on the board
class PlacedTile {
  /// The tile that was placed
  final Tile tile;
  
  /// The position where the tile was placed
  final Position position;
  
  /// Whether this placement formed a new word
  final bool isNewWord;
  
  const PlacedTile({
    required this.tile,
    required this.position,
    this.isNewWord = false,
  });
  
  /// Creates a PlacedTile from a JSON map
  factory PlacedTile.fromJson(Map<String, dynamic> json) {
    return PlacedTile(
      tile: Tile.fromJson(json['tile']),
      position: Position.fromJson(json['position']),
      isNewWord: json['isNewWord'] ?? false,
    );
  }
  
  /// Converts the placed tile to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'tile': tile.toJson(),
      'position': position.toJson(),
      'isNewWord': isNewWord,
    };
  }
}

/// Represents a move made by a player in the game
class Move {
  /// The unique ID of the move
  final String id;
  
  /// The ID of the player who made the move
  final String playerId;
  
  /// The type of move (place, exchange, pass)
  final MoveType type;
  
  /// The tiles placed during this move (if any)
  final List<PlacedTile> placedTiles;
  
  /// The words formed by this move
  final List<String> wordsFormed;
  
  /// The points scored in this move
  final int points;
  
  /// When the move was made
  final DateTime timestamp;
  
  /// Any bonus points applied to this move
  final int bonusPoints;
  
  /// Whether the move was a bingo (using all 7 tiles)
  final bool isBingo;
  
  Move({
    required this.id,
    required this.playerId,
    required this.type,
    this.placedTiles = const [],
    this.wordsFormed = const [],
    this.points = 0,
    DateTime? timestamp,
    this.bonusPoints = 0,
    this.isBingo = false,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// Creates a Move from a JSON map
  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      id: json['id'],
      playerId: json['playerId'],
      type: MoveType.values.firstWhere(
        (e) => e.toString() == 'MoveType.${json['type']}',
        orElse: () => MoveType.place,
      ),
      placedTiles: (json['placedTiles'] as List?)
              ?.map((e) => PlacedTile.fromJson(e))
              .toList() ??
          [],
      wordsFormed: (json['wordsFormed'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      points: json['points'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
      bonusPoints: json['bonusPoints'] ?? 0,
      isBingo: json['isBingo'] ?? false,
    );
  }
  
  /// Converts the move to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerId': playerId,
      'type': type.toString().split('.').last,
      'placedTiles': placedTiles.map((e) => e.toJson()).toList(),
      'wordsFormed': wordsFormed,
      'points': points,
      'timestamp': timestamp.toIso8601String(),
      'bonusPoints': bonusPoints,
      'isBingo': isBingo,
    };
  }
  
  /// Creates a copy of this move with updated fields
  Move copyWith({
    String? id,
    String? playerId,
    MoveType? type,
    List<PlacedTile>? placedTiles,
    List<String>? wordsFormed,
    int? points,
    DateTime? timestamp,
    int? bonusPoints,
    bool? isBingo,
  }) {
    return Move(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      type: type ?? this.type,
      placedTiles: placedTiles ?? List.from(this.placedTiles),
      wordsFormed: wordsFormed ?? List.from(this.wordsFormed),
      points: points ?? this.points,
      timestamp: timestamp ?? this.timestamp,
      bonusPoints: bonusPoints ?? this.bonusPoints,
      isBingo: isBingo ?? this.isBingo,
    );
  }
  
  /// Returns the total points for this move (base + bonus)
  int get totalPoints => points + bonusPoints;
  
  /// Returns whether this move placed any tiles
  bool get isPlaceMove => type == MoveType.place && placedTiles.isNotEmpty;
  
  /// Returns whether this move was a pass
  bool get isPassMove => type == MoveType.pass;
  
  /// Returns whether this move was an exchange
  bool get isExchangeMove => type == MoveType.exchange;
  
  @override
  String toString() => 'Move(${type.toString().split('.').last} by $playerId: $points points)';
}

/// The type of move a player can make
enum MoveType {
  /// Place tiles on the board
  place,
  
  /// Exchange tiles with the bag
  exchange,
  
  /// Pass the turn
  pass,
}

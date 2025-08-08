import 'package:meta/meta.dart';
import 'tile.dart';
import 'move.dart';
import 'user.dart';

/// Represents a player in the game, either human or AI.
class Player {
  /// The user account associated with this player (null for AI players)
  final User? user;
  
  /// Unique identifier for the player
  final String id;
  
  /// The player's display name
  final String nickname;
  
  /// The socket ID for real-time communication
  final String socketId;
  
  /// The player's current score
  final int score;
  
  /// Whether this is a human or AI player
  final PlayerType type;
  
  /// The tiles currently in the player's rack
  final List<Tile> rack;
  
  /// The moves made by this player in the current game
  final List<Move> moves;
  
  /// Whether it's currently this player's turn
  final bool isCurrentTurn;
  
  /// Whether the player has passed their turn
  final bool hasPassed;
  
  /// Whether the player has exchanged tiles this turn
  final bool hasExchanged;

  const Player({
    this.user,
    required this.id,
    required this.nickname,
    required this.socketId,
    this.score = 0,
    this.type = PlayerType.human,
    List<Tile>? rack,
    List<Move>? moves,
    this.isCurrentTurn = false,
    this.hasPassed = false,
    this.hasExchanged = false,
  })  : rack = rack ?? const [],
        moves = moves ?? const [];

  /// Creates a Player from a JSON map
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      id: json['id'],
      nickname: json['nickname'],
      socketId: json['socketId'],
      score: json['score'] ?? 0,
      type: PlayerType.values.firstWhere(
        (e) => e.toString() == 'PlayerType.${json['type']}',
        orElse: () => PlayerType.human,
      ),
      rack: (json['rack'] as List?)
              ?.map((e) => Tile.fromJson(e))
              .toList() ??
          [],
      moves: (json['moves'] as List?)
              ?.map((e) => Move.fromJson(e))
              .toList() ??
          [],
      isCurrentTurn: json['isCurrentTurn'] ?? false,
      hasPassed: json['hasPassed'] ?? false,
      hasExchanged: json['hasExchanged'] ?? false,
    );
  }

  /// Converts the player to a JSON map
  Map<String, dynamic> toJson() {
    return {
      if (user != null) 'user': user!.toJson(),
      'id': id,
      'nickname': nickname,
      'socketId': socketId,
      'score': score,
      'type': type.toString().split('.').last,
      'rack': rack.map((e) => e.toJson()).toList(),
      'moves': moves.map((e) => e.toJson()).toList(),
      'isCurrentTurn': isCurrentTurn,
      'hasPassed': hasPassed,
      'hasExchanged': hasExchanged,
    };
  }

  /// Creates a copy of this player with updated fields
  Player copyWith({
    User? user,
    String? id,
    String? nickname,
    String? socketId,
    int? score,
    PlayerType? type,
    List<Tile>? rack,
    List<Move>? moves,
    bool? isCurrentTurn,
    bool? hasPassed,
    bool? hasExchanged,
  }) {
    return Player(
      user: user ?? this.user,
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      socketId: socketId ?? this.socketId,
      score: score ?? this.score,
      type: type ?? this.type,
      rack: rack ?? List.from(this.rack),
      moves: moves ?? List.from(this.moves),
      isCurrentTurn: isCurrentTurn ?? this.isCurrentTurn,
      hasPassed: hasPassed ?? this.hasPassed,
      hasExchanged: hasExchanged ?? this.hasExchanged,
    );
  }
  
  /// Adds a move to the player's move history
  Player addMove(Move move) {
    return copyWith(
      moves: [...moves, move],
      score: score + (move.points ?? 0),
    );
  }
  
  /// Updates the player's rack with new tiles
  Player updateRack(List<Tile> newRack) {
    return copyWith(rack: newRack);
  }
  
  /// Returns whether the player has any tiles left
  bool get hasNoTilesLeft => rack.isEmpty;
  
  @override
  String toString() => 'Player($nickname, score: $score)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          socketId == other.socketId;
          
  @override
  int get hashCode => Object.hash(id, socketId);
}

/// The type of player (human or AI)
enum PlayerType {
  human,
  ai,
}


import 'dart:math';
import 'package:uuid/uuid.dart';

import 'board.dart';
import 'letterDistribution.dart';
import 'player.dart';
import 'move.dart';

/// Represents a game room where players can join and play
class Room {
  /// Unique identifier for the room
  final String id;
  
  /// The name of the room
  final String name;
  
  /// The maximum number of players allowed in the room
  final int maxPlayers;
  
  /// The list of players in the room
  final List<Player> players;
  
  /// The current game board
  final Board board;
  
  /// The letter distribution for this game
  final LetterDistribution letterDistribution;
  
  /// The ID of the current player
  final String? currentPlayerId;
  
  /// The index of the current player in the players list
  final int currentPlayerIndex;
  
  /// Whether this is the first move of the game
  final bool isFirstMove;
  
  /// The list of moves made in the current game
  final List<Move> moveHistory;
  
  /// Whether the game has started
  final bool hasGameStarted;
  
  /// Whether the game has ended
  final bool hasGameEnded;
  
  /// The timestamp when the room was created
  final DateTime createdAt;
  
  /// The timestamp when the last activity occurred
  final DateTime updatedAt;
  
  /// The settings for this room
  final RoomSettings settings;
  
  /// The ID of the player who created the room
  final String createdBy;

  /// Gets the current player
  Player? get currentPlayer => 
      currentPlayerId == null ? null : getPlayer(currentPlayerId!);
  
  /// Gets a player by ID
  Player? getPlayer(String playerId) {
    return players.firstWhereOrNull((p) => p.id == playerId);
  }
  
  /// Gets the opponent of a player
  Player? getOpponent(String playerId) {
    if (players.length < 2) return null;
    return players.firstWhere((p) => p.id != playerId);
  }
  
  /// Creates a new room with the given parameters
  Room({
    String? id,
    required this.name,
    this.maxPlayers = 2,
    required this.players,
    required this.board,
    required this.letterDistribution,
    this.currentPlayerId,
    this.currentPlayerIndex = 0,
    this.isFirstMove = true,
    this.moveHistory = const [],
    this.hasGameStarted = false,
    this.hasGameEnded = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    RoomSettings? settings,
    required this.createdBy,
  })  : id = id ?? const Uuid().v4(),
        settings = settings ?? const RoomSettings(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Private constructor for copyWith
  Room._({
    required this.id,
    required this.name,
    required this.maxPlayers,
    required this.players,
    required this.board,
    required this.letterDistribution,
    this.currentPlayerId,
    required this.currentPlayerIndex,
    required this.isFirstMove,
    required this.moveHistory,
    required this.hasGameStarted,
    required this.hasGameEnded,
    required this.createdAt,
    required this.updatedAt,
    required this.settings,
    required this.createdBy,
  });
  /// Creates a new room with the given name and creator
  factory Room.create({
    required String name,
    required Player creator,
    int maxPlayers = 2,
    RoomSettings? settings,
  }) {
    final now = DateTime.now();
    final board = Board.empty();
    final letterDistribution = LetterDistribution.english();
    
    return Room(
      id: const Uuid().v4(),
      name: name,
      maxPlayers: maxPlayers,
      players: [creator],
      board: board,
      letterDistribution: letterDistribution,
      settings: settings ?? const RoomSettings(),
      createdBy: creator.id,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a Room from a JSON map
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      maxPlayers: json['maxPlayers'] ?? 2,
      players: (json['players'] as List)
          .map((e) => Player.fromJson(e))
          .toList(),
      board: Board.fromJson(json['board']),
      letterDistribution: LetterDistribution.fromJson(json['letterDistribution']),
      currentPlayerIndex: json['currentPlayerIndex'] ?? 0,
      moveHistory: (json['moveHistory'] as List?)
              ?.map((e) => Move.fromJson(e))
              .toList() ??
          [],
      hasGameStarted: json['hasGameStarted'] ?? false,
      hasGameEnded: json['hasGameEnded'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      settings: json['settings'] != null
          ? RoomSettings.fromJson(json['settings'])
          : const RoomSettings(),
      createdBy: json['createdBy'],
    );
  }

  /// Converts the room to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'maxPlayers': maxPlayers,
      'players': players.map((e) => e.toJson()).toList(),
      'board': board.toJson(),
      'letterDistribution': letterDistribution.toJson(),
      'currentPlayerIndex': currentPlayerIndex,
      'moveHistory': moveHistory.map((e) => e.toJson()).toList(),
      'hasGameStarted': hasGameStarted,
      'hasGameEnded': hasGameEnded,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'settings': settings.toJson(),
      'createdBy': createdBy,
    };
  }
  
  /// Returns a new Room with the specified player added
  Room withPlayerAdded(Player player) {
    if (isFull) {
      throw StateError('Room is full');
    }
    
    if (players.any((p) => p.id == player.id)) {
      throw StateError('Player already in room');
    }
    
    return copyWith(
      players: [...players, player],
      updatedAt: DateTime.now(),
    );
  }
  
  /// Returns a new Room with the specified player removed
  Room withPlayerRemoved(String playerId) {
    final newPlayers = players.where((p) => p.id != playerId).toList();
    
    // If creator leaves, assign new creator
    String newCreatedBy = createdBy;
    if (createdBy == playerId && newPlayers.isNotEmpty) {
      newCreatedBy = newPlayers.first.id;
    }
    
    // Adjust current player index if needed
    int newCurrentPlayerIndex = currentPlayerIndex;
    if (newPlayers.length <= currentPlayerIndex) {
      newCurrentPlayerIndex = max(0, newPlayers.length - 1);
    }
    
    return copyWith(
      players: newPlayers,
      currentPlayerIndex: newCurrentPlayerIndex,
      createdBy: newCreatedBy,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Returns a new Room with the game started
  Room withGameStarted() {
    if (hasGameStarted) {
      throw StateError('Game has already started');
    }
    
    if (players.length < 2) {
      throw StateError('Not enough players to start');
    }
    
    // Deal initial tiles to players
    final newLetterDistribution = letterDistribution;
    final newPlayers = players.map((player) {
      final tiles = newLetterDistribution.drawTiles(7, ownerId: player.id);
      return player.updateRack(tiles);
    }).toList();
    
    return copyWith(
      players: newPlayers,
      letterDistribution: newLetterDistribution,
      hasGameStarted: true,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Gets the number of players in the room
  int get playerCount => players.length;
  
  /// Checks if the room is full
  bool get isFull => playerCount >= maxPlayers;
  
  /// Checks if the room is empty
  bool get isEmpty => players.isEmpty;
  
  /// Gets the creator of the room
  Player? get creator => players.firstWhereOrNull((p) => p.id == createdBy);
  
  /// Adds a player to the room
  /// Returns a new Room with the player added
  @Deprecated('Use withPlayerAdded instead')
  Room addPlayer(Player player) => withPlayerAdded(player);
  
  /// Removes a player from the room
  /// Returns a new Room with the player removed
  @Deprecated('Use withPlayerRemoved instead')
  Room removePlayer(String playerId) => withPlayerRemoved(playerId);
  
  /// Starts the game if conditions are met
  /// Returns a new Room with the game started
  @Deprecated('Use withGameStarted instead')
  Room startGame() => withGameStarted();
  
  /// Makes a move in the game
  /// Returns a new Room with the move applied
  Room makeMove(Move move) {
    if (!hasGameStarted || hasGameEnded) {
      throw StateError('Game is not in progress');
    }
    
    if (move.playerId != currentPlayer?.id) {
      throw StateError('Not your turn');
    }
    
    // Apply the move to the board
    Board newBoard = board;
    for (final placedTile in move.placedTiles) {
      newBoard = newBoard.placeTile(placedTile.tile, placedTile.position);
    }
    
    // Update player's score and rack
    final playerIndex = players.indexWhere((p) => p.id == move.playerId);
    final player = players[playerIndex];
    final newPlayer = player
        .addMove(move)
        .updateRack(player.rack.where((t) => !move.placedTiles.any((pt) => pt.tile == t)).toList());
    
    // Draw new tiles if needed
    final tilesToDraw = min(move.placedTiles.length, letterDistribution.tilesRemaining);
    final newTiles = letterDistribution.drawTiles(tilesToDraw, ownerId: player.id);
    final finalPlayer = newPlayer.updateRack([...newPlayer.rack, ...newTiles]);
    
    // Update players list
    final newPlayers = List<Player>.from(players);
    newPlayers[playerIndex] = finalPlayer;
    
    // Check for game end
    final isGameOver = _checkGameEndCondition(newBoard, newPlayers);
    
    // Move to next player
    final nextPlayerIndex = (currentPlayerIndex + 1) % players.length;
    
    return copyWith(
      board: newBoard,
      players: newPlayers,
      currentPlayerIndex: isGameOver ? currentPlayerIndex : nextPlayerIndex,
      moveHistory: [...moveHistory, move],
      hasGameEnded: isGameOver,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Checks if the game should end
  bool _checkGameEndCondition(Board board, List<Player> players) {
    // Game ends if a player has no tiles left and the bag is empty
    final anyPlayerOutOfTiles = players.any((p) => p.rack.isEmpty);
    final isBagEmpty = letterDistribution.tilesRemaining == 0;
    
    if (anyPlayerOutOfTiles && isBagEmpty) {
      return true;
    }
    
    // Game could also end if no more valid moves are possible
    // This would require additional logic to check
    
    return false;
  }
  
  /// Creates a copy of this room with updated fields
  Room copyWith({
    String? id,
    String? name,
    int? maxPlayers,
    List<Player>? players,
    Board? board,
    LetterDistribution? letterDistribution,
    int? currentPlayerIndex,
    List<Move>? moveHistory,
    bool? hasGameStarted,
    bool? hasGameEnded,
    DateTime? createdAt,
    DateTime? updatedAt,
    RoomSettings? settings,
    String? createdBy,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      players: players ?? List.from(this.players),
      board: board ?? this.board,
      letterDistribution: letterDistribution ?? this.letterDistribution,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      moveHistory: moveHistory ?? List.from(this.moveHistory),
      hasGameStarted: hasGameStarted ?? this.hasGameStarted,
      hasGameEnded: hasGameEnded ?? this.hasGameEnded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      createdBy: createdBy ?? this.createdBy,
    );
  }
  
  @override
  String toString() => 'Room($name, $playerCount/$maxPlayers players)';
}

/// Settings that can be customized for a room
class RoomSettings {
  /// Time limit per turn in seconds (null for no limit)
  final int? timeLimitPerTurn;
  
  /// Whether to allow spectators
  final bool allowSpectators;
  
  /// Whether to enable chat
  final bool enableChat;
  
  /// Dictionary to use (e.g., 'en_US', 'en_UK')
  final String dictionary;
  
  /// Minimum word length to be valid
  final int minWordLength;
  
  const RoomSettings({
    this.timeLimitPerTurn,
    this.allowSpectators = true,
    this.enableChat = true,
    this.dictionary = 'en_US',
    this.minWordLength = 2,
  });
  
  /// Creates RoomSettings from a JSON map
  factory RoomSettings.fromJson(Map<String, dynamic> json) {
    return RoomSettings(
      timeLimitPerTurn: json['timeLimitPerTurn'],
      allowSpectators: json['allowSpectators'] ?? true,
      enableChat: json['enableChat'] ?? true,
      dictionary: json['dictionary'] ?? 'en_US',
      minWordLength: json['minWordLength'] ?? 2,
    );
  }
  
  /// Converts the settings to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'timeLimitPerTurn': timeLimitPerTurn,
      'allowSpectators': allowSpectators,
      'enableChat': enableChat,
      'dictionary': dictionary,
      'minWordLength': minWordLength,
    };
  }
  
  /// Creates a copy of these settings with updated fields
  RoomSettings copyWith({
    int? timeLimitPerTurn,
    bool? allowSpectators,
    bool? enableChat,
    String? dictionary,
    int? minWordLength,
  }) {
    return RoomSettings(
      timeLimitPerTurn: timeLimitPerTurn ?? this.timeLimitPerTurn,
      allowSpectators: allowSpectators ?? this.allowSpectators,
      enableChat: enableChat ?? this.enableChat,
      dictionary: dictionary ?? this.dictionary,
      minWordLength: minWordLength ?? this.minWordLength,
    );
  }
}

// Extension to add firstWhereOrNull to Iterable
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

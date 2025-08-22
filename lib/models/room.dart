import 'dart:math';
import 'package:uuid/uuid.dart';

import 'board.dart';
import 'letterDistribution.dart';
import 'player.dart';
import 'move.dart';
import 'tile.dart';
import 'position.dart';
import 'package:shakelha_mp/resources/scrabble_game_logic.dart';

enum Status {
  open,
  playing,
  full,
  ended,
}
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

  /// Count of consecutive pass moves across players
  final int consecutivePassCount;
  
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

  /// Whether the room is listed publicly in the lobby
  final bool isPublic;

  /// Status of the room lifecycle: open, playing, full, ended
  final Status status;

  /// Socket ID of the host/creator (authorizes room settings)
  final String? hostSocketId;

  /// Generates a valid room ID that matches server regex: /^[a-zA-Z0-9]{6}$/
  static String generateValidRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

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
    this.consecutivePassCount = 0,
    this.moveHistory = const [],
    this.hasGameStarted = false,
    this.hasGameEnded = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    RoomSettings? settings,
    required this.createdBy,
    this.isPublic = false,
    this.status =   Status.open,
    this.hostSocketId,
  })  : id = id ?? generateValidRoomId(),
        settings = settings ?? const RoomSettings(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Private constructor for copyWith
  // Private redirect constructor was unused; removed to satisfy lints
  /// Creates a new room with the given name and creator
  factory Room.create({
    required String name,
    required Player creator,
    int maxPlayers = 2,
    RoomSettings? settings,
  }) {
    final now = DateTime.now();
    return Room(
      name: name,
      maxPlayers: maxPlayers,
      players: [creator],
      board: Board.empty(size: ScrabbleGameLogic.boardSize),
      letterDistribution: LetterDistribution.arabic(),
      createdBy: creator.id,
      createdAt: now,
      updatedAt: now,
      settings: settings,
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
      currentPlayerId: json['currentPlayerId'],
      currentPlayerIndex: json['currentPlayerIndex'] ?? 0,
      isFirstMove: json['isFirstMove'] ?? true,
      consecutivePassCount: json['consecutivePassCount'] ?? 0,
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
      isPublic: json['isPublic'] ?? false,
      status: json['status'] == null
          ? Status.open
          : (json['status'] is String
              ? Status.values.firstWhere(
                  (s) => s.toString().split('.').last == json['status'],
                  orElse: () => Status.open,
                )
              : Status.open),
      hostSocketId: json['hostSocketId'],
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
      'currentPlayerId': currentPlayerId,
      'currentPlayerIndex': currentPlayerIndex,
      'isFirstMove': isFirstMove,
      'consecutivePassCount': consecutivePassCount,
      'moveHistory': moveHistory.map((e) => e.toJson()).toList(),
      'hasGameStarted': hasGameStarted,
      'hasGameEnded': hasGameEnded,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'settings': settings.toJson(),
      'createdBy': createdBy,
      'isPublic': isPublic,
      'status': status.toString().split('.').last,
      'hostSocketId': hostSocketId,
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
      final tiles = newLetterDistribution.drawTiles(7)
          .map((t) => t.copyWith(ownerId: player.id))
          .toList();
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
      newBoard.placeTile(placedTile.tile, placedTile.position);
    }
    
    // Update player's score and rack
    final playerIndex = players.indexWhere((p) => p.id == move.playerId);
    final player = players[playerIndex];
    final newPlayer = player
        .addMove(move)
        .updateRack(player.rack.where((t) => !move.placedTiles.any((pt) => pt.tile == t)).toList());
    
    // Draw new tiles if needed
    final tilesToDraw = min(move.placedTiles.length, letterDistribution.tilesRemaining);
    final newTiles = letterDistribution.drawTiles(tilesToDraw)
        .map((t) => t.copyWith(ownerId: player.id))
        .toList();
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
    String? currentPlayerId,
    int? currentPlayerIndex,
    bool? isFirstMove,
    int? consecutivePassCount,
    List<Move>? moveHistory,
    bool? hasGameStarted,
    bool? hasGameEnded,
    DateTime? createdAt,
    DateTime? updatedAt,
    RoomSettings? settings,
    String? createdBy,
    bool? isPublic,
    String? status,
    String? hostSocketId,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      players: players ?? List.from(this.players),
      board: board ?? this.board,
      letterDistribution: letterDistribution ?? this.letterDistribution,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      isFirstMove: isFirstMove ?? this.isFirstMove,
      consecutivePassCount: consecutivePassCount ?? this.consecutivePassCount,
      moveHistory: moveHistory ?? List.from(this.moveHistory),
      hasGameStarted: hasGameStarted ?? this.hasGameStarted,
      hasGameEnded: hasGameEnded ?? this.hasGameEnded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      createdBy: createdBy ?? this.createdBy,
      isPublic: isPublic ?? this.isPublic,
      hostSocketId: hostSocketId ?? this.hostSocketId,
    );
  }
  
  @override
  String toString() => 'Room($name, $playerCount/$maxPlayers players)';

  // --- Game helpers to avoid duplicating logic in providers ---

  /// Returns map of playerId -> score
  Map<String, int> scores() {
    final out = <String, int>{};
    for (final p in players) {
      out[p.id] = p.score;
    }
    return out;
  }

  /// Advances to next player and sets `currentPlayerId`
  Room switchToNextPlayer() {
    final nextIndex = (currentPlayerIndex + 1) % players.length;
    final updatedPlayers = players
        .map((p) => p.copyWith(isCurrentTurn: p.id == players[nextIndex].id))
        .toList();
    return copyWith(
      currentPlayerIndex: nextIndex,
      currentPlayerId: players[nextIndex].id,
      players: updatedPlayers,
      updatedAt: DateTime.now(),
    );
  }

  /// Validates and applies a placement move. On success, updates board, rack, score, history, refills rack,
  /// resets first move flag, clears pass streak, and advances turn.
  /// Returns (updatedRoom, validationResult, committedMove).
  (Room, MoveValidationResult, Move) trySubmitMove(String playerId, List<PlacedTile> placedTiles) {
    final validation = ScrabbleGameLogic.validateMove(
      room: this,
      playerId: playerId,
      placedTiles: placedTiles,
    );
    if (!validation.isValid) {
      return (this, validation, Move(id: '', playerId: playerId, type: MoveType.place));
    }

    // Update board and player rack
    var updatedBoard = board;
    final playerIndex = players.indexWhere((p) => p.id == playerId);
    final player = players[playerIndex];
    final newRack = List<Tile>.from(player.rack);
    for (final pt in placedTiles) {
      updatedBoard.placeTile(pt.tile.copyWith(isOnBoard: true, isNewlyPlaced: false, ownerId: playerId, position: pt.position), pt.position);
      final i = newRack.indexWhere((t) => identical(t, pt.tile) || (t.letter == pt.tile.letter && !t.isOnBoard));
      if (i != -1) newRack.removeAt(i);
    }

    // Create move and update player score
    final move = Move(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playerId: playerId,
      type: MoveType.place,
      placedTiles: List<PlacedTile>.from(placedTiles),
      wordsFormed: List<String>.from(validation.wordsFormed),
      points: validation.points,
    );

    // Draw up to rack size
    final toDraw = (7 - newRack.length).clamp(0, 7);
    final added = toDraw > 0 ? letterDistribution.drawTiles(toDraw, ownerId: playerId) : const <Tile>[];
    newRack.addAll(added);

    // Apply updates
    final updatedPlayer = player.copyWith(score: player.score + validation.points, rack: newRack);
    final newPlayers = List<Player>.from(players);
    newPlayers[playerIndex] = updatedPlayer;

    final nextRoom = copyWith(
      board: updatedBoard,
      players: newPlayers,
      moveHistory: [...moveHistory, move],
      isFirstMove: false,
      consecutivePassCount: 0,
      updatedAt: DateTime.now(),
    ).switchToNextPlayer();

    return (nextRoom, validation, move);
  }

  /// Records a pass for the given player and advances turn, increasing the consecutive pass streak.
  Room passTurnBy(String playerId, {int? passThreshold}) {
    final move = Move(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playerId: playerId,
      type: MoveType.pass,
      placedTiles: const [],
      wordsFormed: const [],
      points: 0,
    );
    final threshold = passThreshold ?? (players.length * 2);
    final newCount = consecutivePassCount + 1;
    var r = copyWith(
      moveHistory: [...moveHistory, move],
      consecutivePassCount: newCount,
      updatedAt: DateTime.now(),
    );
    if (newCount >= threshold) {
      r = r.copyWith(hasGameEnded: true);
      return r;
    }
    return r.switchToNextPlayer();
  }

  /// Swaps tiles back to bag and draws replacements for player.
  Room swapTilesFor(String playerId, List<Tile> tilesToSwap) {
    if (tilesToSwap.isEmpty) return this;
    final idx = players.indexWhere((p) => p.id == playerId);
    if (idx == -1) return this;
    final p = players[idx];
    final newRack = List<Tile>.from(p.rack);
    for (final t in tilesToSwap) {
      final i = newRack.indexWhere((rt) => identical(rt, t) || (rt.letter == t.letter && !rt.isOnBoard));
      if (i != -1) newRack.removeAt(i);
    }
    letterDistribution.returnTiles(tilesToSwap);
    final replacements = letterDistribution.drawTiles(tilesToSwap.length, ownerId: playerId);
    newRack.addAll(replacements);
    final updatedPlayers = List<Player>.from(players);
    updatedPlayers[idx] = updatedPlayers[idx].copyWith(rack: newRack, hasExchanged: true);
    final move = Move(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playerId: playerId,
      type: MoveType.exchange,
      placedTiles: const [],
      wordsFormed: const [],
      points: 0,
    );
    final r = copyWith(
      players: updatedPlayers,
      moveHistory: [...moveHistory, move],
      consecutivePassCount: 0,
      updatedAt: DateTime.now(),
    );
    return r.switchToNextPlayer();
  }

  /// Refill a player's rack to 7 tiles
  Room refillRackFor(String playerId) {
    final idx = players.indexWhere((p) => p.id == playerId);
    if (idx == -1) return this;
    final p = players[idx];
    final toDraw = (7 - p.rack.length).clamp(0, 7);
    if (toDraw <= 0) return this;
    final drawn = letterDistribution.drawTiles(toDraw, ownerId: playerId);
    final newRack = [...p.rack, ...drawn];
    final updatedPlayers = List<Player>.from(players);
    updatedPlayers[idx] = updatedPlayers[idx].copyWith(rack: newRack);
    return copyWith(players: updatedPlayers, updatedAt: DateTime.now());
  }

  /// Move a pending placement (represented in UI state) logically on the board preview
  /// Note: final commit still goes through trySubmitMove; this function does not mutate board.
  /// Kept here for future centralization if we later move pending state into the model.
  Room previewMovePending(Position from, Position to) {
    // No-op placeholder to keep API symmetric; UI holds pending state.
    return this;
  }
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

import 'package:flutter/material.dart';
import 'package:mp_tictactoe/models/room.dart';
import 'package:mp_tictactoe/models/player.dart';
import 'package:mp_tictactoe/models/board.dart';
import 'package:mp_tictactoe/models/letterDistribution.dart';

import 'package:mp_tictactoe/models/tile.dart';
import 'package:mp_tictactoe/models/position.dart';
import 'package:mp_tictactoe/models/move.dart';
import 'package:mp_tictactoe/resources/scrabble_game_logic.dart';
import 'package:mp_tictactoe/data/arabic_dictionary_loader.dart';

/// Provider for local pass-and-play game state management
class PassPlayProvider extends ChangeNotifier {
  Room? _room;
  String? _currentPlayerId;
  // Local placement state (mirrors GameProvider for UI parity)
  final List<Tile> _selectedTiles = [];
  final List<PlacedTile> _pendingPlacements = [];
  bool _isPlacingTiles = false;
  String? _errorMessage;
  String? _successMessage;
  List<String> _lastSubmittedWords = const [];
  
  Room? get room => _room;
  String? get currentPlayerId => _currentPlayerId;
  List<Tile> get selectedTiles => _selectedTiles;
  List<PlacedTile> get pendingPlacements => _pendingPlacements;
  bool get isPlacingTiles => _isPlacingTiles;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<String> get lastSubmittedWords => _lastSubmittedWords;
  int get consecutivePassCount => _room?.consecutivePassCount ?? 0;
  
  Player? get currentPlayer {
    if (_room == null || _currentPlayerId == null) return null;
    try {
      return _room!.players.firstWhere((p) => p.id == _currentPlayerId);
    } catch (e) {
      return null;
    }
  }
  
  bool get isMyTurn {
    if (_room == null || _currentPlayerId == null) return false;
    final currentIdx = _room!.currentPlayerIndex;
    if (currentIdx >= _room!.players.length) return false;
    return _room!.players[currentIdx].id == _currentPlayerId;
  }

  void _setErrorMessage(String msg) {
    print('[PassPlayProvider] Setting error message: "$msg"');
    print('[PassPlayProvider] Stack trace: ${StackTrace.current}');
    _errorMessage = msg;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccessMessage(String msg) {
    _successMessage = msg;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  /// Initialize a new local game with two players (convenience)
  void initializeGame(String player1Name, String player2Name) {
    startGame(2, [player1Name, player2Name]);
  }

  /// Start a new pass-and-play game with N players
  void startGame(int playerCount, List<String> playerNames) {
    final letterDist = LetterDistribution.arabic();
    final names = List<String>.from(playerNames);
    while (names.length < playerCount) {
      names.add('Player ${names.length + 1}');
    }

    final players = <Player>[];
    for (int i = 0; i < playerCount; i++) {
      final id = 'player${i + 1}';
      final rack = letterDist.drawTiles(7, ownerId: id);
      players.add(Player(
        id: id,
        nickname: names[i],
        socketId: id,
        score: 0,
        type: PlayerType.human,
        rack: rack,
        moves: const [],
        isCurrentTurn: i == 0,
        hasPassed: false,
        hasExchanged: false,
      ));
    }
    
    _room = Room(
      id: 'local-game',
      name: 'Pass & Play',
      maxPlayers: playerCount,
      players: players,
      board: Board.empty(),
      letterDistribution: letterDist,
      currentPlayerId: players.first.id,
      currentPlayerIndex: 0,
      moveHistory: const [],
      hasGameStarted: true,
      hasGameEnded: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: players.first.id,
      isPublic: false,
      status: Status.playing,
      hostSocketId: players.first.id,
    );
    
    _currentPlayerId = players.first.id;
    _selectedTiles.clear();
    _pendingPlacements.clear();
    _isPlacingTiles = false;
    _clearMessages();
    ArabicDictionary.instance.preload();
    notifyListeners();
  }
  
  /// Starts placing tiles mode
  void startPlacingTiles() {
    if (!isMyTurn) {
      _setErrorMessage('ليس دورك');
      return;
    }
    _isPlacingTiles = true;
    _selectedTiles.clear();
    _clearMessages();
    notifyListeners();
  }
  
  /// Cancels placing tiles mode
  void cancelPlacingTiles() {
    _isPlacingTiles = false;
    _pendingPlacements.clear();
    _selectedTiles.clear();
    _clearMessages();
    notifyListeners();
  }

  /// Selects a tile from the player's rack
  void selectTile(Tile tile) {
    if (!_isPlacingTiles) return;
    if (_selectedTiles.contains(tile)) {
      _selectedTiles.remove(tile);
    } else {
      _selectedTiles.add(tile);
    }
    notifyListeners();
  }

  /// Convenience: place an explicit tile at a position
  bool placeTile(Position position, Tile tile) {
    if (!isMyTurn) {
      _setErrorMessage('ليس دورك');
      return false;
    }
    if (_room?.board.getTileAt(position) != null) {
      _setErrorMessage('المربع مشغول');
      return false;
    }
    if (_pendingPlacements.any((p) => p.position == position)) {
      _setErrorMessage('هناك حرف بانتظار التأكيد');
      return false;
    }
    // Remove from rack immediately
    _removeFromCurrentPlayerRack(tile);
    _pendingPlacements.add(PlacedTile(
      tile: tile.copyWith(isNewlyPlaced: true, isOnBoard: true, ownerId: _currentPlayerId, position: position),
      position: position,
    ));
    _clearMessages();
    notifyListeners();
    return true;
  }

  /// Places a selected tile on the board (using current selection)
  void placeTileOnBoard(Position position) {
    if (!_isPlacingTiles || _selectedTiles.isEmpty) return;
    if (_room?.board.getTileAt(position) != null) {
      _setErrorMessage('المربع مشغول');
      return;
    }
    if (_pendingPlacements.any((p) => p.position == position)) {
      _setErrorMessage('هناك حرف بانتظار التأكيد');
      return;
    }
    final selectedTile = _selectedTiles.first;
    _selectedTiles.remove(selectedTile);
    // Remove from rack immediately
    _removeFromCurrentPlayerRack(selectedTile);
    _pendingPlacements.add(PlacedTile(
      tile: selectedTile.copyWith(isNewlyPlaced: true, isOnBoard: true, ownerId: _currentPlayerId, position: position),
      position: position,
    ));
    _clearMessages();
    notifyListeners();
  }

  /// Removes a pending placement or (no-op) for committed tiles
  void removeTile(Position position) {
    removePendingPlacement(position);
  }

  /// Removes a pending placement
  void removePendingPlacement(Position position) {
    print('[PassPlayProvider] Removing pending placement at position: $position');
    final index = _pendingPlacements.indexWhere((p) => p.position == position);
    if (index != -1) {
      final pt = _pendingPlacements.removeAt(index);
      print('[PassPlayProvider] Removed tile: "${pt.tile.letter}" from position: $position');
      // Return tile to rack
      _returnToCurrentPlayerRack(pt.tile);
      notifyListeners();
    } else {
      print('[PassPlayProvider] No pending placement found at position: $position');
    }
  }

  /// Places a dragged tile onto the board (drag-and-drop support)
  void placeDraggedTile(Tile tile, Position position, {bool removeFromRack = true}) {
    if (!isMyTurn) {
      _setErrorMessage('ليس دورك');
      return;
    }
    if (_room?.board.getTileAt(position) != null) {
      _setErrorMessage('المربع مشغول');
      return;
    }
    if (_pendingPlacements.any((p) => p.position == position)) {
      _setErrorMessage('هناك حرف بانتظار التأكيد');
      return;
    }
    if (removeFromRack) {
      _removeFromCurrentPlayerRack(tile);
    }
    _pendingPlacements.add(PlacedTile(
      tile: tile.copyWith(isNewlyPlaced: true, isOnBoard: true, ownerId: _currentPlayerId, position: position),
      position: position,
    ));
    _clearMessages();
    notifyListeners();
  }

  /// Exchanges selected tiles back to the bag and draws new ones
  bool swapTiles(List<Tile> tilesToSwap) {
    if (!isMyTurn || _room == null || _currentPlayerId == null) return false;
    if (tilesToSwap.isEmpty) return false;

    final idx = _room!.players.indexWhere((p) => p.id == _currentPlayerId);
    if (idx == -1) return false;
    final player = _room!.players[idx];

    // Remove from rack (by identity)
    final newRack = List<Tile>.from(player.rack);
    for (final t in tilesToSwap) {
      final i = newRack.indexWhere((rt) => identical(rt, t) || (rt.letter == t.letter && !rt.isOnBoard));
      if (i != -1) newRack.removeAt(i);
    }

    // Return to bag and draw replacements up to 7 tiles
    _room!.letterDistribution.returnTiles(tilesToSwap);
    final toDraw = 7; // always restock to full rack after swapping all
    final replacements = _room!.letterDistribution.drawTiles(toDraw, ownerId: player.id);
    newRack.addAll(replacements);

    // Update player and history
    var players = List<Player>.from(_room!.players);
    players[idx] = players[idx].copyWith(rack: newRack, hasExchanged: true);
    final move = Move(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playerId: player.id,
      type: MoveType.exchange,
      placedTiles: const [],
      wordsFormed: const [],
      points: 0,
    );

    _room = _room!.copyWith(
      players: players,
      moveHistory: [..._room!.moveHistory, move],
      updatedAt: DateTime.now(),
    );

    _isPlacingTiles = false;
    _pendingPlacements.clear();
    _selectedTiles.clear();
    _setSuccessMessage('تم تبديل ${tilesToSwap.length} بلاطات');
    switchPlayer();
    return true;
  }

  /// Refill current player's rack to 7
  void refillTiles() {
    if (_room == null || _currentPlayerId == null) return;
    final idx = _room!.players.indexWhere((p) => p.id == _currentPlayerId);
    if (idx == -1) return;
    final player = _room!.players[idx];
    final toDraw = (7 - player.rack.length).clamp(0, 7);
    if (toDraw <= 0) return;
    final drawn = _room!.letterDistribution.drawTiles(toDraw, ownerId: player.id);
    final rack = [...player.rack, ...drawn];
    final players = List<Player>.from(_room!.players);
    players[idx] = players[idx].copyWith(rack: rack);
    _room = _room!.copyWith(players: players, updatedAt: DateTime.now());
    notifyListeners();
  }

  /// Validate a word using the dictionary (direction not needed for lookup)
  bool validateWord(String word, Position position, String direction) {
    return ArabicDictionary.instance.containsWord(word);
  }

  /// Approximate word score (sum of letter values; multipliers ignored here)
  int calculateWordScore(String word, Position position, String direction) {
    if (_room == null) return 0;
    int sum = 0;
    for (final rune in word.runes) {
      final ch = String.fromCharCode(rune);
      sum += _room!.letterDistribution.getLetterValue(ch);
    }
    return sum;
  }

  /// Returns the main + cross words for the current pending placements
  List<String> getAllWordsFormed() {
    if (_room == null || _currentPlayerId == null || _pendingPlacements.isEmpty) return const [];
    final res = ScrabbleGameLogic.validateMove(
      room: _room!,
      playerId: _currentPlayerId!,
      placedTiles: List<PlacedTile>.from(_pendingPlacements),
    );
    return res.wordsFormed;
  }

  /// Update a player's score by delta
  void updatePlayerScore(String playerId, int delta) {
    if (_room == null) return;
    final idx = _room!.players.indexWhere((p) => p.id == playerId);
    if (idx == -1) return;
    final players = List<Player>.from(_room!.players);
    players[idx] = players[idx].copyWith(score: players[idx].score + delta);
    _room = _room!.copyWith(players: players, updatedAt: DateTime.now());
    notifyListeners();
  }

  Map<String, int> getScores() {
    if (_room == null) return {};
    final out = <String, int>{};
    for (final p in _room!.players) {
      out[p.id] = p.score;
    }
    return out;
  }

  // --- private helpers to keep rack consistent during DnD ---
  void _removeFromCurrentPlayerRack(Tile tile) {
    if (_room == null || _currentPlayerId == null) return;
    final idx = _room!.players.indexWhere((p) => p.id == _currentPlayerId);
    if (idx == -1) return;
    final rack = List<Tile>.from(_room!.players[idx].rack);
    final i = rack.indexWhere((t) => identical(t, tile) || (t.letter == tile.letter && !t.isOnBoard));
    if (i != -1) {
      rack.removeAt(i);
      final players = List<Player>.from(_room!.players);
      players[idx] = players[idx].copyWith(rack: rack);
      _room = _room!.copyWith(players: players, updatedAt: DateTime.now());
    }
  }

  void _returnToCurrentPlayerRack(Tile tile) {
    if (_room == null || _currentPlayerId == null) return;
    final idx = _room!.players.indexWhere((p) => p.id == _currentPlayerId);
    if (idx == -1) return;
    final rack = List<Tile>.from(_room!.players[idx].rack);
    rack.add(tile.copyWith(isOnBoard: false, isNewlyPlaced: false, ownerId: _currentPlayerId, position: null));
    final players = List<Player>.from(_room!.players);
    players[idx] = players[idx].copyWith(rack: rack);
    _room = _room!.copyWith(players: players, updatedAt: DateTime.now());
  }

  /// Move a pending placement from one board position to another empty cell.
  void movePendingTile(Position from, Position to) {
    if (_room == null) return;
    if (!isMyTurn) return;
    if (_room!.board.getTileAt(to) != null) return;
    if (_pendingPlacements.any((p) => p.position == to)) return;
    final index = _pendingPlacements.indexWhere((p) => p.position == from);
    if (index == -1) return;
    final pt = _pendingPlacements[index];
    _pendingPlacements[index] = PlacedTile(
      tile: pt.tile.copyWith(position: to),
      position: to,
      isNewWord: pt.isNewWord,
    );
    notifyListeners();
  }

  /// Validate and submit the current move locally (no sockets)
  bool submitMove() {
    if (_room == null || _currentPlayerId == null) {
      _setErrorMessage('اللعبة غير جاهزة');
      return false;
    }
    if (!isMyTurn) {
      _setErrorMessage('ليس دورك');
      return false;
    }
    if (!ArabicDictionary.instance.isReady) {
      _setErrorMessage('جاري تحميل القاموس...');
      ArabicDictionary.instance.preload();
      return false;
    }
    if (_pendingPlacements.isEmpty) {
      _setErrorMessage('لم تضع أي أحرف');
      return false;
    }

    // Centralized validation via Board
    final originalBoard = _room!.board;
    final tempBoard = Board.fromJson(originalBoard.toJson());
    tempBoard.isFirstTurn = originalBoard.isFirstTurn;
    final newlyPlaced = _pendingPlacements.map((pt) => pt.tile.copyWith(position: pt.position)).toList();
    final (ok, msg, points, words) = tempBoard.validateAndScoreMove(newlyPlaced);
    if (!ok) {
      _setErrorMessage(msg);
      return false;
    }

    // Commit tiles to the real board
    var committedBoard = _room!.board;
    for (final pt in _pendingPlacements) {
      final committedTile = pt.tile.copyWith(isOnBoard: true, isNewlyPlaced: false, ownerId: _currentPlayerId, position: pt.position);
      committedBoard.placeTile(committedTile, pt.position);
    }
    committedBoard.isFirstTurn = false;

    // Update score and refill up to 7 tiles
    final playerIdx = _room!.players.indexWhere((p) => p.id == _currentPlayerId);
    var players = List<Player>.from(_room!.players);
    final afterScore = players[playerIdx].copyWith(score: players[playerIdx].score + points);
    players[playerIdx] = afterScore;

    // Refill to 7 tiles
    final need = (7 - afterScore.rack.length).clamp(0, 7);
    if (need > 0) {
      final drawn = _room!.letterDistribution.drawTiles(need, ownerId: _currentPlayerId);
      players[playerIdx] = players[playerIdx].copyWith(rack: [...afterScore.rack, ...drawn]);
    }

    final move = Move(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playerId: _currentPlayerId!,
      type: MoveType.place,
      placedTiles: List<PlacedTile>.from(_pendingPlacements),
      wordsFormed: words,
      points: points,
    );

    _room = _room!.copyWith(
      board: committedBoard,
      players: players,
      moveHistory: [..._room!.moveHistory, move],
      isFirstMove: false,
      updatedAt: DateTime.now(),
    ).switchToNextPlayer();

    // UI state
    _lastSubmittedWords = move.wordsFormed;
    _isPlacingTiles = false;
    _pendingPlacements.clear();
    _selectedTiles.clear();
    _setSuccessMessage('تم تسجيل الحركة: +$points');
    _currentPlayerId = _room!.currentPlayerId ?? _room!.players[_room!.currentPlayerIndex].id;
    return true;
  }
  
  /// End turn: submit if there is a move, otherwise pass
  bool endTurn() {
    if (_pendingPlacements.isNotEmpty) {
      return submitMove();
    } else {
      passTurn();
      return true;
    }
  }

  /// Switch to the next player's turn
  void switchPlayer() {
    if (_room == null) return;
    _room = _room!.switchToNextPlayer();
    _currentPlayerId = _room!.currentPlayerId ?? _room!.players[_room!.currentPlayerIndex].id;
    notifyListeners();
  }

  /// Pass the current turn and record history
  void passTurn() {
    if (_room == null || _currentPlayerId == null) return;
    if (_pendingPlacements.isNotEmpty) {
      final ok = submitMove();
      if (!ok) return;
      notifyListeners();
      return;
    }
    _room = _room!.passTurnBy(_currentPlayerId!);
    _isPlacingTiles = false;
    _pendingPlacements.clear();
    _selectedTiles.clear();
    // If game didn't end, sync currentPlayerId for UI
    if (!_room!.hasGameEnded) {
      _currentPlayerId = _room!.currentPlayerId ?? _room!.players[_room!.currentPlayerIndex].id;
    }
    notifyListeners();
  }
  
  /// Undo current pending placements (does not undo committed moves)
  void undoMove() {
    // Return any pending tiles back to rack
    for (final pt in _pendingPlacements) {
      _returnToCurrentPlayerRack(pt.tile);
    }
    _pendingPlacements.clear();
    _selectedTiles.clear();
    _isPlacingTiles = false;
    notifyListeners();
  }

  /// Check for end-of-game conditions
  bool isGameOver() {
    if (_room == null) return false;
    return ScrabbleGameLogic.isGameOver(_room!);
  }
  
  /// Reset the game
  void resetGame() {
    _room = null;
    _currentPlayerId = null;
    _selectedTiles.clear();
    _pendingPlacements.clear();
    _isPlacingTiles = false;
    _clearMessages();
    notifyListeners();
  }
  
  /// Update room state (for compatibility with GameProvider interface)
  void updateRoom(Room room) {
    _room = room;
    notifyListeners();
  }
  
  /// Set current player ID (for compatibility with GameProvider interface)
  void setCurrentPlayerId(String playerId) {
    _currentPlayerId = playerId;
    notifyListeners();
  }

  /// Export a serializable game snapshot (caller can persist)
  Map<String, dynamic> saveGameState() {
    return {
      'room': _room?.toJson(),
      'currentPlayerId': _currentPlayerId,
    };
  }

  /// Restore a saved snapshot
  void loadGameState(Map<String, dynamic> data) {
    try {
      final r = data['room'] as Map<String, dynamic>?;
      if (r == null) return;
      _room = Room.fromJson(r);
      _currentPlayerId = data['currentPlayerId'] ?? _room!.currentPlayerId ?? _room!.players[_room!.currentPlayerIndex].id;
      notifyListeners();
    } catch (_) {
      _setErrorMessage('تعذر استعادة حالة اللعبة');
    }
  }
}
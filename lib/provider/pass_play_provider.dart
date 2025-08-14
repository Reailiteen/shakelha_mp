import 'package:flutter/material.dart';
import 'package:mp_tictactoe/models/room.dart';
import 'package:mp_tictactoe/models/player.dart';
import 'package:mp_tictactoe/models/board.dart';
import 'package:mp_tictactoe/models/letter_distribution.dart';

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

  /// Initialize a new local game with two players
  void initializeGame(String player1Name, String player2Name) {
    final letterDist = LetterDistribution();
    
    // Create players with initial racks
    final player1 = Player(
      id: 'player1',
      nickname: player1Name,
      socketId: 'player1',
      score: 0,
      type: PlayerType.human,
      rack: _drawTiles(letterDist, 7),
      moves: [],
      isCurrentTurn: true,
      hasPassed: false,
      hasExchanged: false,
    );
    
    final player2 = Player(
      id: 'player2',
      nickname: player2Name,
      socketId: 'player2',
      score: 0,
      type: PlayerType.human,
      rack: _drawTiles(letterDist, 7),
      moves: [],
      isCurrentTurn: false,
      hasPassed: false,
      hasExchanged: false,
    );
    
    _room = Room(
      id: 'local-game',
      name: 'Pass & Play',
      maxPlayers: 2,
      players: [player1, player2],
      board: Board.empty(),
      letterDistribution: letterDist,
      currentPlayerIndex: 0,
      moveHistory: [],
      hasGameStarted: true,
      hasGameEnded: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      settings: null,  // No settings needed for local game
      createdBy: 'player1',
      isPublic: false,
      status: 'playing',
      hostSocketId: 'player1',
    );
    
    _currentPlayerId = 'player1';
    _selectedTiles.clear();
    _pendingPlacements.clear();
    _isPlacingTiles = false;
    _clearMessages();
    // Preload dictionary for faster first validation
    ArabicDictionary.instance.preload();
    notifyListeners();
  }
  
  /// Draw tiles from letter distribution
  List<Tile> _drawTiles(LetterDistribution letterDist, int count) {
    return letterDist.drawTiles(count);
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

  /// Places a selected tile on the board
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
    _pendingPlacements.add(PlacedTile(
      tile: selectedTile.copyWith(isNewlyPlaced: true, isOnBoard: true, ownerId: _currentPlayerId),
      position: position,
    ));
    _clearMessages();
    notifyListeners();
  }

  /// Removes a pending placement
  void removePendingPlacement(Position position) {
    final index = _pendingPlacements.indexWhere((p) => p.position == position);
    if (index != -1) {
      _pendingPlacements.removeAt(index);
      notifyListeners();
    }
  }

  /// Places a dragged tile onto the board (drag-and-drop support)
  void placeDraggedTile(Tile tile, Position position) {
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
    _pendingPlacements.add(PlacedTile(
      tile: tile.copyWith(isNewlyPlaced: true, isOnBoard: true, ownerId: _currentPlayerId),
      position: position,
    ));
    _clearMessages();
    notifyListeners();
  }

  /// Switch to the other player's turn
  void passTurn() {
    if (_room == null) return;
    
    final newIndex = (_room!.currentPlayerIndex + 1) % _room!.players.length;
    final updatedPlayers = _room!.players.map((p) {
      return p.copyWith(isCurrentTurn: p.id == _room!.players[newIndex].id);
    }).toList();
    
    _room = _room!.copyWith(
      currentPlayerIndex: newIndex,
      players: updatedPlayers,
      updatedAt: DateTime.now(),
    );
    
    // Switch current player view to the new turn player
    _currentPlayerId = _room!.players[newIndex].id;
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

    // Run rules validation
    final validation = ScrabbleGameLogic.validateMove(
      room: _room!,
      playerId: _currentPlayerId!,
      placedTiles: List<PlacedTile>.from(_pendingPlacements),
    );
    if (!validation.isValid) {
      _setErrorMessage(validation.message);
      return false;
    }

    // Commit tiles to board and update rack and score
    final currentPlayerIdx = _room!.players.indexWhere((p) => p.id == _currentPlayerId);
    if (currentPlayerIdx == -1) return false;
    var newBoard = _room!.board;
    var rack = List<Tile>.from(_room!.players[currentPlayerIdx].rack);

    for (final pt in _pendingPlacements) {
      // Place on board
      final committedTile = pt.tile.copyWith(isOnBoard: true, isNewlyPlaced: false, ownerId: _currentPlayerId);
      newBoard = newBoard.placeTile(committedTile, pt.position);
      // Remove from rack: match by letter and not on board
      final i = rack.indexWhere((t) => t.letter == pt.tile.letter && !t.isOnBoard);
      if (i != -1) rack.removeAt(i);
    }

    // Score update
    final gained = validation.points;
    var players = List<Player>.from(_room!.players);
    final updatedPlayer = players[currentPlayerIdx].copyWith(
      score: players[currentPlayerIdx].score + gained,
    );
    players[currentPlayerIdx] = updatedPlayer;

    // Refill rack up to 7
    final toDraw = (7 - rack.length).clamp(0, 7);
    if (toDraw > 0) {
      rack.addAll(_drawTiles(_room!.letterDistribution, toDraw));
    }
    players[currentPlayerIdx] = players[currentPlayerIdx].copyWith(rack: rack);

    // Record move
    final move = Move(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playerId: _currentPlayerId!,
      type: MoveType.place,
      placedTiles: List<PlacedTile>.from(_pendingPlacements),
      wordsFormed: List<String>.from(validation.wordsFormed),
      points: gained,
    );

    _room = _room!.copyWith(
      board: newBoard,
      players: players,
      moveHistory: [..._room!.moveHistory, move],
      updatedAt: DateTime.now(),
    );

    // Update UI state
    _lastSubmittedWords = List<String>.from(validation.wordsFormed);
    _isPlacingTiles = false;
    _pendingPlacements.clear();
    _selectedTiles.clear();
    _setSuccessMessage('تم تسجيل الحركة: +$gained');

    // Switch turns
    passTurn();
    return true;
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
}

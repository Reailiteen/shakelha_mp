import 'package:flutter/material.dart';

import 'package:shakelha_mp/models/move.dart';
import 'package:shakelha_mp/models/player.dart';
import 'package:shakelha_mp/models/position.dart';
import 'package:shakelha_mp/models/room.dart';
import 'package:shakelha_mp/models/tile.dart';
import 'package:shakelha_mp/resources/scrabble_game_logic.dart';
import 'package:shakelha_mp/resources/socket_methods.dart';
import 'package:shakelha_mp/data/arabic_dictionary_loader.dart';
import 'package:shakelha_mp/models/board.dart';

class GameProvider extends ChangeNotifier {
  Room? _room;
  String? _currentPlayerId;
  List<Tile> _selectedTiles = [];
  List<PlacedTile> _pendingPlacements = [];
  bool _isPlacingTiles = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isMyTurn = false;
  final SocketMethods _sockets = SocketMethods();
  List<String> _lastSubmittedWords = const [];

  // Word validation state (multiplayer)
  List<ValidatedWord> _validatedWords = [];
  bool _wordValidationEnabled = true;
  bool _hasValidationProblems = false;

  // Getters
  Room? get room => _room;
  String? get currentPlayerId => _currentPlayerId;
  List<Tile> get selectedTiles => _selectedTiles;
  List<PlacedTile> get pendingPlacements => _pendingPlacements;
  bool get isPlacingTiles => _isPlacingTiles;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isMyTurn => _isMyTurn;
  List<String> get lastSubmittedWords => _lastSubmittedWords;
  List<ValidatedWord> get validatedWords => _validatedWords;
  bool get wordValidationEnabled => _wordValidationEnabled;
  bool get hasValidationProblems => _hasValidationProblems;

  Player? get currentPlayer {
    if (_room == null || _currentPlayerId == null) return null;
    return _room!.players.firstWhere(
      (p) => p.id == _currentPlayerId,
      orElse: () => _room!.players.first,
    );
  }

  Player? get myPlayer {
    if (_room == null || _currentPlayerId == null) return null;
    return _room!.players.firstWhere(
      (p) => p.id == _currentPlayerId,
      orElse: () => _room!.players.first,
    );
  }

  List<Tile> get myRack {
    final player = myPlayer;
    return player?.rack ?? [];
  }

  /// Updates the room state
  void updateRoom(Room room) {
    _room = room;
    _updateTurnStatus();
    notifyListeners();
  }

  /// Sets the current player ID
  void setCurrentPlayerId(String playerId) {
    _currentPlayerId = playerId;
    _updateTurnStatus();
    notifyListeners();
  }

  /// Updates turn status based on current player
  void _updateTurnStatus() {
    if (_room != null && _currentPlayerId != null) {
      final idx = _room!.currentPlayerIndex;
      String? currentTurnPlayerId;
      if (idx >= 0 && idx < _room!.players.length) {
        currentTurnPlayerId = _room!.players[idx].id;
      }

      _isMyTurn = currentTurnPlayerId == _currentPlayerId;

      // Automatically start placing tiles when it's our turn
      if (_isMyTurn && !_isPlacingTiles) {
        _isPlacingTiles = true;
      }
    }
  }

  /// Starts placing tiles mode
  void startPlacingTiles() {
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
    // Clear hover on cancel
    if (_room != null) {
      _sockets.clearHover(_room!.id);
    }
    _updateWordValidation();
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

    // Check if position is already occupied
    if (_room?.board.getTileAt(position) != null) {
      _setErrorMessage('Position already occupied!');
      return;
    }

    // Check if position is already in pending placements
    if (_pendingPlacements.any((p) => p.position == position)) {
      _setErrorMessage('Position already has a pending tile!');
      return;
    }

    final selectedTile = _selectedTiles.first;
    _selectedTiles.remove(selectedTile);

    _pendingPlacements.add(PlacedTile(
      tile: selectedTile.copyWith(isNewlyPlaced: true),
      position: position,
    ));

    _clearMessages();
    _updateWordValidation();
    notifyListeners();
  }

  /// Removes a pending placement
  void removePendingPlacement(Position position) {
    final index = _pendingPlacements.indexWhere((p) => p.position == position);
    if (index != -1) {
      _pendingPlacements.removeAt(index);
      _updateWordValidation();
      notifyListeners();
    }
  }

  /// Moves a pending tile from one position to another
  void movePendingTile(Position fromPosition, Position toPosition) {
    final index = _pendingPlacements.indexWhere((p) => p.position == fromPosition);
    if (index != -1) {
      final tile = _pendingPlacements[index];
      _pendingPlacements.removeAt(index);
      _pendingPlacements.add(PlacedTile(
        tile: tile.tile,
        position: toPosition,
      ));
      _updateWordValidation();
      notifyListeners();
    }
  }

  /// Places a dragged tile onto the board (drag-and-drop support)
  void placeDraggedTile(Tile tile, Position position) {
    if (!isMyTurn) {
      _setErrorMessage('Not your turn');
      return;
    }
    if (_room?.board.getTileAt(position) != null) {
      _setErrorMessage('Position already occupied!');
      return;
    }
    if (_pendingPlacements.any((p) => p.position == position)) {
      _setErrorMessage('Position already has a pending tile!');
      return;
    }

    _pendingPlacements.add(PlacedTile(
      tile: tile.copyWith(isNewlyPlaced: true),
      position: position,
    ));
    _clearMessages();
    // Keep placements local; batch will be sent on submitMove
    _updateWordValidation();
    notifyListeners();
  }

  /// Send a realtime hover preview for the current selected tile
  void sendHover(Position position) {
    if (_room == null || !_isPlacingTiles || _selectedTiles.isEmpty) return;
    final letter = _selectedTiles.first.letter;
    _sockets.hoverTile(_room!.id, letter: letter, row: position.row, col: position.col);
  }

  /// Clear the realtime hover preview
  void clearHover() {
    if (_room == null) return;
    _sockets.clearHover(_room!.id);
  }

  /// Send hover using explicit letter (e.g., during a drag where data is available)
  void sendHoverWithLetter(String letter, Position position) {
    if (_room == null) return;
    _sockets.hoverTile(_room!.id, letter: letter, row: position.row, col: position.col);
  }

  /// Validates and submits the current move
  bool submitMove() {
    // Ensure dictionary loaded
    if (!ArabicDictionary.instance.isReady) {
      _setErrorMessage('يرجى الانتظار ريثما يتم تحميل القاموس...');
      ArabicDictionary.instance.preload();
      return false;
    }
    if (_pendingPlacements.isEmpty) {
      _setErrorMessage('لم تضع أي حروف!');
      return false;
    }
    if (_room == null || _currentPlayerId == null) {
      _setErrorMessage('الغرفة غير جاهزة');
      return false;
    }
    if (!_isMyTurn) {
      _setErrorMessage('ليس دورك');
      return false;
    }
    
    // Check tile continuity first (must be in line)
    final pendingTiles = _pendingPlacements.map((p) => p.tile.copyWith(position: p.position)).toList();
    if (_room?.board.areTilesContinuous(pendingTiles) != true) {
      _setErrorMessage('يجب أن تكون الحروف متصلة وفي خط مستقيم');
      return false;
    }

    // Do live word validation first
    _updateWordValidation();
    if (_hasValidationProblems) {
      final invalidWords = _validatedWords
          .where((w) => w.status == WordValidationStatus.invalid)
          .map((w) => w.text)
          .join('، ');
      _setErrorMessage('كلمات غير صحيحة: $invalidWords');
      return false;
    }

    // Then validate the full move
    final validation = validatePendingMove();
    if (!validation.isValid) {
      _setErrorMessage(validation.message);
      return false;
    }

    // Show preview of score and words before submitting
    final previewMessage = 'النقاط: ${validation.points}\n'
        'الكلمات: ${validation.wordsFormed.join('، ')}';
    _setSuccessMessage(previewMessage);

    // Emit placements to server as a batch then submit the move
    try {
      final roomId = _room!.id;

      debugPrint('[submitMove] Submitting move with ${_pendingPlacements.length} tiles');
      debugPrint('[submitMove] Placed tiles: ${_pendingPlacements.map((pt) => '${pt.tile.letter}@(${pt.position.row},${pt.position.col})').join(', ')}');

      final placedPayload = _pendingPlacements
          .map((pt) => pt.toJson())
          .toList();

      _sockets.submitMove(roomId, placedTiles: placedPayload);

      // Log words formed for debugging/analytics
      _lastSubmittedWords = List<String>.from(validation.wordsFormed);
      debugPrint('[submitMove] Words formed: ${_lastSubmittedWords.join(' | ')}');

      // Set a timer to check if board was updated, if not request a refresh
      Future.delayed(const Duration(seconds: 2), () {
        if (_room != null && _room!.board.getAllTiles().isEmpty) {
          _sockets.socketClient.emit('getRoomUpdate', {'roomId': roomId});
        }
      });

      // Don't commit tiles locally - wait for server confirmation
      // This ensures all players see the same board state

      // Update turn status but don't modify the board yet
      _updateTurnStatus();

      // Locally finalize UI state; server will sync room via listeners
      _isPlacingTiles = false;
      selectedRackIndex = null;

      // Clear pending placements AFTER sending to server
      _pendingPlacements.clear();
      // Clear hover/preview after submit
      if (_room != null) {
        _sockets.clearHover(_room!.id);
      }
      final wordsText = _lastSubmittedWords.isNotEmpty ? '\nالكلمات: ' + _lastSubmittedWords.join('، ') : '';
      _setSuccessMessage('تم وضع الحروف: +${validation.points} نقطة$wordsText');
      notifyListeners();
      return true;
    } catch (e) {
      _setErrorMessage('Failed to submit move');
      return false;
    }
  }

  /// Gets the current player
  Player? getCurrentPlayer() {
    if (_room == null) return null;
    final players = _room!.players;
    final idx = players.indexWhere((p) => p.id == _currentPlayerId);
    if (idx != -1) return players[idx];
    if (players.isNotEmpty) return players.first;
    return null;
  }

  /// Currently selected rack tile index
  int? selectedRackIndex;

  /// Selects a tile from the rack
  void selectRackTile(int index) {
    if (!_isPlacingTiles) return;
    if (selectedRackIndex == index) {
      selectedRackIndex = null;
      _selectedTiles.clear();
    } else {
      selectedRackIndex = index;
      final rack = myRack;
      if (index >= 0 && index < rack.length) {
        _selectedTiles
          ..clear()
          ..add(rack[index]);
      }
    }
    notifyListeners();
  }

  /// Checks if a move can be submitted
  bool canSubmitMove() {
    return _pendingPlacements.isNotEmpty;
  }

  /// Checks if there are pending placements
  bool hasPendingPlacements() {
    return _pendingPlacements.isNotEmpty;
  }

  /// Cancels the current move
  void cancelMove() {
    _pendingPlacements.clear();
    notifyListeners();
  }

  /// Checks if tiles can be exchanged
  bool canExchangeTiles() {
    return isMyTurn && selectedRackIndex != null;
  }

  /// Exchanges selected tiles
  void exchangeSelectedTiles() {
    if (selectedRackIndex == null) return;
    // TODO: Implement tile exchange logic
    selectedRackIndex = null;
    notifyListeners();
  }

  /// Passes the current turn
  void passTurn() {
    if (_room == null) {
      _setErrorMessage('Room not ready');
      return;
    }

    if (!_isMyTurn) {
      _setErrorMessage('ليس دورك');
      return;
    }

    // Return any pending placed tiles back to the current player's rack
    final idx = _room!.players.indexWhere((p) => p.id == _currentPlayerId);
    if (idx != -1 && _pendingPlacements.isNotEmpty) {
      final players = List<Player>.from(_room!.players);
      final player = players[idx];
      final returnedTiles = _pendingPlacements.map((p) => p.tile.copyWith(isNewlyPlaced: false)).toList();
      final newRack = [...player.rack, ...returnedTiles];
      players[idx] = player.copyWith(rack: newRack);
      _room = _room!.copyWith(players: players, updatedAt: DateTime.now());
    }

    _isPlacingTiles = false;
    _pendingPlacements.clear();
    _selectedTiles.clear();

    // Notify server and other players
    _sockets.passTurn(_room!.id);
    _setSuccessMessage('Turn passed');
    notifyListeners();
  }

  /// Exchanges selected tiles
  void exchangeTiles() {
    if (!_isMyTurn) {
      _setErrorMessage('ليس دورك');
      return;
    }
    if (_selectedTiles.isEmpty) {
      _setErrorMessage('لم تحدد أي حروف للتبديل!');
      return;
    }

    // Emit exchange request to server
    if (_room != null) {
      try {
        final tilesToExchange = _selectedTiles
            .map((t) => '${t.letter}_${t.value}')
            .toList();

        _sockets.exchangeTiles(_room!.id, tilesToExchange);
        _setSuccessMessage('تم تبديل ${_selectedTiles.length} حروف');
        _selectedTiles.clear();
        _isPlacingTiles = false;
        notifyListeners();
      } catch (e) {
        _setErrorMessage('فشل تبديل الحروف');
      }
    }
  }

  /// Sets an error message
  void _setErrorMessage(String message) {
    _errorMessage = message;
    _successMessage = null;

    // Clear error message after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (_errorMessage == message) {
        _errorMessage = null;
        notifyListeners();
      }
    });
  }

  /// Sets a success message
  void _setSuccessMessage(String message) {
    _successMessage = message;
    _errorMessage = null;

    // Clear success message after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (_successMessage == message) {
        _successMessage = null;
        notifyListeners();
      }
    });
  }

  /// Clears all messages
  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  /// Gets the tile at a specific position (including pending placements)
  Tile? getTileAt(Position position) {
    // Check pending placements first
    final pendingTile = _pendingPlacements
        .firstWhere((p) => p.position == position, orElse: () => PlacedTile(tile: Tile(letter: ''), position: position))
        .tile;

    if (pendingTile.letter.isNotEmpty) return pendingTile;

    // Check board
    return _room?.board.getTileAt(position);
  }

  /// Checks if a position has a pending placement
  bool hasPendingPlacement(Position position) {
    return _pendingPlacements.any((p) => p.position == position);
  }

  /// Gets the current game score for all players
  Map<String, int> getScores() {
    if (_room == null) return {};

    final scores = <String, int>{};
    for (final player in _room!.players) {
      scores[player.id] = player.score;
    }
    return scores;
  }

  /// Resets the game state
  void reset() {
    _room = null;
    _currentPlayerId = null;
    _selectedTiles.clear();
    _pendingPlacements.clear();
    _isPlacingTiles = false;
    _errorMessage = null;
    _successMessage = null;
    _isMyTurn = false;
    notifyListeners();
  }

  /// Validate the pending placements locally using Scrabble rules (returns validation result)
  MoveValidationResult validatePendingMove() {
    if (_room == null || _currentPlayerId == null) {
      return const MoveValidationResult(isValid: false, message: 'Room not ready');
    }
    if (_pendingPlacements.isEmpty) {
      return const MoveValidationResult(isValid: false, message: 'No tiles placed');
    }

    // Convert pending placements to tiles with positions for board checks
    final pendingTiles = _pendingPlacements.map((p) => p.tile.copyWith(position: p.position)).toList();

    // Continuity check (prevents L-shaped placements)
    if (_room?.board.areTilesContinuous(pendingTiles) != true) {
      return const MoveValidationResult(isValid: false, message: 'Invalid placement: tiles must be continuous and in one line');
    }

    // Delegate to ScrabbleGameLogic for full validation (dictionary + scoring)
    try {
      final validation = ScrabbleGameLogic.validateMove(
        room: _room!,
        playerId: _currentPlayerId!,
        placedTiles: List<PlacedTile>.from(_pendingPlacements),
      );
      return validation;
    } catch (e) {
      return MoveValidationResult(isValid: false, message: 'Validation failed: $e');
    }
  }

  /// Update real-time word validation using the board validator
  void _updateWordValidation() {
    if (!_wordValidationEnabled || _room == null) {
      _validatedWords = [];
      _hasValidationProblems = false;
      notifyListeners();
      return;
    }
    
    // Always clear previous validation state
    _validatedWords = [];
    _hasValidationProblems = false;

    final board = _room!.board;

    // Build a getTileAt function that includes pending placements
    String? getTileAt(Position pos) {
      final pending = _pendingPlacements.firstWhere(
        (p) => p.position == pos,
        orElse: () => PlacedTile(tile: Tile(letter: ''), position: pos),
      ).tile;
      if (pending.letter.isNotEmpty) return pending.letter;
      final existing = board.getTileAt(pos);
      return existing?.letter;
    }

    final pendingTiles = _pendingPlacements.map((p) => p.tile.copyWith(position: p.position)).toList();

    try {
      final allWords = board.validateAllWords(getTileAt: getTileAt, pendingTiles: pendingTiles);
      // Keep only words that involve newly placed tiles when there are pending placements
      if (_pendingPlacements.isNotEmpty) {
        _validatedWords = allWords.where((w) => w.positions.any((pos) => _pendingPlacements.any((p) => p.position == pos))).toList();
      } else {
        _validatedWords = allWords;
      }

      _hasValidationProblems = _validatedWords.any((w) => w.status == WordValidationStatus.invalid);
    } catch (e) {
      _validatedWords = [];
      _hasValidationProblems = false;
    }

    notifyListeners();
  }

  /// Convenience boolean to check if current pending placements are valid
  bool areCurrentWordsValid() {
    final validation = validatePendingMove();
    if (!validation.isValid) {
      _setErrorMessage(validation.message);
      return false;
    }
    return true;
  }
}

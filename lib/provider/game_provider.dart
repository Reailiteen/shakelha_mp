import 'package:flutter/material.dart';

import 'package:mp_tictactoe/models/move.dart';
import 'package:mp_tictactoe/models/player.dart';
import 'package:mp_tictactoe/models/position.dart';
import 'package:mp_tictactoe/models/room.dart';
import 'package:mp_tictactoe/models/tile.dart';
import 'package:mp_tictactoe/resources/scrabble_game_logic.dart';
import 'package:mp_tictactoe/resources/socket_methods.dart';
import 'package:mp_tictactoe/data/arabic_dictionary_loader.dart';

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
      final mySocketId = _sockets.socketClient.id;
      final idx = _room!.currentPlayerIndex;
      bool turnByIndex = false;
      if (idx >= 0 && idx < _room!.players.length) {
        final currentP = _room!.players[idx];
        turnByIndex = (currentP.id == _currentPlayerId) ||
            (mySocketId != null && currentP.socketId == mySocketId);
      }
      final turnById = _room!.currentPlayerId != null
          ? (_room!.currentPlayerId == _currentPlayerId)
          : false;
      _isMyTurn = turnByIndex || turnById;
      // Debug
      // ignore: avoid_print
      debugPrint('[turn] myId='+(_currentPlayerId??'?')+', mySocket='+ (mySocketId??'?') +
          ', currentIdx='+idx.toString()+', idxId='+ (idx>=0&&idx<_room!.players.length? _room!.players[idx].id : '?') +
          ', idxSocket='+ (idx>=0&&idx<_room!.players.length? _room!.players[idx].socketId : '?') +
          ', room.currentPlayerId='+ (_room!.currentPlayerId?.toString()??'null') +
          ', isMyTurn='+ _isMyTurn.toString());
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
    // Keep placements local; batch will be sent on submitMove
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
      _setErrorMessage('Loading dictionary, please wait...');
      ArabicDictionary.instance.preload();
      return false;
    }
    if (_pendingPlacements.isEmpty) {
      _setErrorMessage('No tiles placed!');
      return false;
    }
    if (_room == null || _currentPlayerId == null) {
      _setErrorMessage('Room not ready');
      return false;
    }
    if (!_isMyTurn) {
      _setErrorMessage('Not your turn');
      return false;
    }

    // Validate using Scrabble rules
    final validation = ScrabbleGameLogic.validateMove(
      room: _room!,
      playerId: _currentPlayerId!,
      placedTiles: List<PlacedTile>.from(_pendingPlacements),
    );
    if (!validation.isValid) {
      _setErrorMessage(validation.message);
      return false;
    }

    // Emit placements to server as a batch then submit the move
    try {
      final roomId = _room!.id;
      final placedPayload = _pendingPlacements
          .map((pt) => pt.toJson())
          .toList();
      _sockets.submitMove(roomId, placedTiles: placedPayload);

      // Log words formed for debugging/analytics
      _lastSubmittedWords = List<String>.from(validation.wordsFormed);
      debugPrint('[submitMove] words=' + _lastSubmittedWords.join(' | '));

      // Optimistically remove used tiles from my rack locally, then refill from local bag
      final me = myPlayer;
      if (me != null) {
        final newRack = List<Tile>.from(me.rack);
        for (final pt in _pendingPlacements) {
          final idx = newRack.indexWhere((t) =>
              t.ownerId == me.id &&
              t.letter == pt.tile.letter &&
              t.isOnBoard == false);
          if (idx != -1) {
            newRack.removeAt(idx);
          }
        }
        // Draw to 7 from the bag
        if (_room != null) {
          final ld = _room!.letterDistribution;
          final need = 7 - newRack.length;
          if (need > 0) {
            final drawn = ld.drawTiles(need);
            final owned = drawn.map((t) => t.copyWith(ownerId: me.id)).toList();
            newRack.addAll(owned);
          }
          // Persist updated rack and bag into room
          final pIdx = _room!.players.indexWhere((p) => p.id == me.id);
          if (pIdx != -1) {
            final updatedMe = me.copyWith(rack: newRack);
            final updatedPlayers = List<Player>.from(_room!.players);
            updatedPlayers[pIdx] = updatedMe;
            _room = _room!.copyWith(players: updatedPlayers, letterDistribution: ld);
          }
        }
      }

      // Locally finalize UI state; server will sync room via listeners
      _isPlacingTiles = false;
      _pendingPlacements.clear();
      selectedRackIndex = null;
      final wordsText = _lastSubmittedWords.isNotEmpty ? ' [' + _lastSubmittedWords.join(', ') + ']' : '';
      _setSuccessMessage('Move submitted: +${validation.points}$wordsText');
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
    if (_room == null) return;
    _isPlacingTiles = false;
    _pendingPlacements.clear();
    _selectedTiles.clear();
    _sockets.passTurn(_room!.id);
    _setSuccessMessage('Turn passed');
    notifyListeners();
  }
  
  /// Exchanges selected tiles
  void exchangeTiles() {
    if (_selectedTiles.isEmpty) {
      _setErrorMessage('No tiles selected for exchange!');
      return;
    }
    
    _setSuccessMessage('${_selectedTiles.length} tiles exchanged');
    _selectedTiles.clear();
    _isPlacingTiles = false;
    notifyListeners();
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
}

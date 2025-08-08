import 'package:flutter/material.dart';

import 'package:mp_tictactoe/models/move.dart';
import 'package:mp_tictactoe/models/player.dart';
import 'package:mp_tictactoe/models/position.dart';
import 'package:mp_tictactoe/models/room.dart';
import 'package:mp_tictactoe/models/tile.dart';

class GameProvider extends ChangeNotifier {
  Room? _room;
  String? _currentPlayerId;
  List<Tile> _selectedTiles = [];
  List<PlacedTile> _pendingPlacements = [];
  bool _isPlacingTiles = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isMyTurn = false;
  
  // Getters
  Room? get room => _room;
  String? get currentPlayerId => _currentPlayerId;
  List<Tile> get selectedTiles => _selectedTiles;
  List<PlacedTile> get pendingPlacements => _pendingPlacements;
  bool get isPlacingTiles => _isPlacingTiles;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isMyTurn => _isMyTurn;
  
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
      _isMyTurn = _room!.currentPlayerId == _currentPlayerId;
    }
  }
  
  /// Starts placing tiles mode
  void startPlacingTiles() {
    _isPlacingTiles = true;
    _pendingPlacements.clear();
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
  
  /// Validates and submits the current move
  bool submitMove() {
    if (_pendingPlacements.isEmpty) return false;
    
    // Clear pending placements and notify
    _pendingPlacements.clear();
    notifyListeners();
    return true;
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
    selectedRackIndex = selectedRackIndex == index ? null : index;
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
    _isPlacingTiles = false;
    _pendingPlacements.clear();
    _selectedTiles.clear();
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

import 'package:flutter/material.dart';
import 'package:mp_tictactoe/models/move.dart';  // This imports PlacedTile
import 'package:mp_tictactoe/models/room.dart';
import 'package:mp_tictactoe/models/tile.dart';
import 'package:mp_tictactoe/models/position.dart';

class RoomDataProvider extends ChangeNotifier {
  Room? _room;
  String? _currentPlayerId;
  bool _isGameOver = false;
  String? _winnerId;
  Map<String, int> _scores = {};
  List<PlacedTile> _placedTiles = [];
  
  // Getters
  Room? get room => _room;
  String? get currentPlayerId => _currentPlayerId;
  bool get isGameOver => _isGameOver;
  String? get winnerId => _winnerId;
  Map<String, int> get scores => _scores;
  List<PlacedTile> get placedTiles => _placedTiles;
  
  /// Updates the entire room state
  void updateRoom(Room room) {
    _room = room;
    notifyListeners();
  }
  
  /// Updates the current player
  void setCurrentPlayer(String playerId) {
    _currentPlayerId = playerId;
    notifyListeners();
  }
  
  /// Adds a placed tile to the board
  void addPlacedTile(PlacedTile placedTile) {
    _placedTiles.add(placedTile);
    notifyListeners();
  }
  
  /// Moves a tile from one position to another
  void moveTile(Position fromPos, Position toPos) {
    final index = _placedTiles.indexWhere(
      (tile) => tile.position == fromPos,
    );
    
    if (index != -1) {
      final tile = _placedTiles.removeAt(index);
      _placedTiles.add(PlacedTile(
        tile: tile.tile,
        position: toPos,
        isNewWord: tile.isNewWord,
      ));
      
      notifyListeners();
    }
  }
  
  /// Removes a tile from the board
  void removeTile(Position position) {
    _placedTiles.removeWhere((tile) => tile.position == position);
    notifyListeners();
  }
  
  /// Clears all placed tiles (used when canceling a move)
  void clearPlacedTiles() {
    _placedTiles.clear();
    notifyListeners();
  }
  
  /// Sets the game over state
  void setGameOver(String? winnerId, Map<String, int> scores) {
    _isGameOver = true;
    _winnerId = winnerId;
    _scores = scores;
    notifyListeners();
  }
  
  /// Resets the game state
  void reset() {
    _room = null;
    _currentPlayerId = null;
    _isGameOver = false;
    _winnerId = null;
    _scores = {};
    _placedTiles = [];
    notifyListeners();
  }
  
  // Helper methods for the game UI
  bool isTileAtPosition(Position position) {
    return _placedTiles.any((tile) => tile.position == position);
  }
  
  Tile? getTileAtPosition(Position position) {
    try {
      return _placedTiles.firstWhere((tile) => tile.position == position).tile;
    } catch (e) {
      return null;
    }
  }
}

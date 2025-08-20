import 'dart:math' as math;
import 'package:shakelha_mp/models/board.dart';
import 'package:shakelha_mp/models/letterDistribution.dart';
import 'package:shakelha_mp/models/move.dart';
import 'package:shakelha_mp/models/player.dart';
import 'package:shakelha_mp/models/position.dart';
import 'package:shakelha_mp/models/room.dart';
import 'package:shakelha_mp/models/tile.dart';
// Dictionary handled by Board validator

class ScrabbleGameLogic {
  static const int boardSize = 15;
  static const int maxRackSize = 7;
  
  /// Validates if the current move is valid according to Scrabble rules
  static MoveValidationResult validateMove({
    required Room room,
    required String playerId,
    required List<PlacedTile> placedTiles,
  }) {
    final board = room.board;
  
    // 1. Check if it's the player's turn (support index-based turns too)
    bool isPlayersTurn = false;
    if (room.currentPlayerId != null) {
      isPlayersTurn = (room.currentPlayerId == playerId);
    } else {
      final idx = room.currentPlayerIndex;
      if (idx >= 0 && idx < room.players.length) {
        isPlayersTurn = room.players[idx].id == playerId;
      }
    }
    if (!isPlayersTurn) {
      return MoveValidationResult(
        isValid: false,
        message: 'It\'s not your turn!',
      );
    }
    
    // 2. Check if any tiles were placed
    if (placedTiles.isEmpty) {
      return MoveValidationResult(
        isValid: false,
        message: 'No tiles placed!',
      );
    }
    
    // 3. Check if all placed tiles belong to the player
    for (final placedTile in placedTiles) {
      if (placedTile.tile.ownerId != playerId) {
        return MoveValidationResult(
          isValid: false,
          message: 'You can only place your own tiles!',
        );
      }
    }
    
    // 4. Check if tiles are in a straight line (same row or column)
    if (!_areTilesInStraightLine(placedTiles)) {
      return const MoveValidationResult(
        isValid: false,
        message: 'Tiles must be placed in a straight line!',
      );
    }

    // 4b. Enforce contiguity across the span (no gaps between min..max when considering existing board tiles)
    if (!_isContiguousWithBoard(board, placedTiles)) {
      return const MoveValidationResult(
        isValid: false,
        message: 'Tiles must be contiguous without gaps!',
      );
    }
    
    // 5. Check if the move connects with existing tiles (except first move)
    if (!room.isFirstMove && !_isMoveConnectedToExistingTiles(board, placedTiles)) {
      return const MoveValidationResult(
        isValid: false,
        message: 'Your move must connect with existing tiles!',
      );
    }
    
    // 6. Check if first move is on the center square
    if (room.isFirstMove) {
      final center = Position(row: boardSize ~/ 2, col: boardSize ~/ 2);
      if (!placedTiles.any((pt) => pt.position == center)) {
        return MoveValidationResult(
          isValid: false,
          message: 'First move must be on the center square!',
        );
      }
    }
    
    // 7/8. Defer to board centralized validator for words and points
    final overlayTiles = placedTiles.map((pt) => pt.tile.copyWith(position: pt.position)).toList();
    final (ok, msg, points, words) = board.validateAndScoreMove(overlayTiles);
    if (!ok) {
      return MoveValidationResult(isValid: false, message: msg);
    }
    
    return MoveValidationResult(
      isValid: true,
      message: 'Valid move!',
      points: points,
      wordsFormed: words,
    );
  }
  
  /// Executes a move if it's valid
  static Room executeMove({
    required Room room,
    required String playerId,
    required List<PlacedTile> placedTiles,
  }) {
    final validation = validateMove(room: room, playerId: playerId, placedTiles: placedTiles);
    
    if (!validation.isValid) {
      throw Exception('Invalid move: ${validation.message}');
    }
    
    // Create the move
    final move = Move(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playerId: playerId,
      type: MoveType.place,
      placedTiles: placedTiles,
      wordsFormed: validation.wordsFormed,
      points: validation.points,
      isBingo: placedTiles.length == maxRackSize, // Bingo bonus for using all tiles
    );
    
    // Update the board with placed tiles
    var updatedBoard = room.board;
    for (final placedTile in placedTiles) {
      updatedBoard.placeTile(placedTile.tile, placedTile.position);
    }
    
    // Update player's rack
    final playerIndex = room.players.indexWhere((p) => p.id == playerId);
    final player = room.players[playerIndex];
    
    // Remove used tiles from player's rack
    final newRack = List<Tile>.from(player.rack);
    for (final placedTile in placedTiles) {
      newRack.removeWhere((t) => t == placedTile.tile);
    }
    
    // Add points to player's score
    final updatedPlayer = player.copyWith(
      score: player.score + validation.points,
      rack: newRack,
    );
    
    // Update room state
    final updatedPlayers = List<Player>.from(room.players);
    updatedPlayers[playerIndex] = updatedPlayer;
    
    // Get next player's turn
    final nextPlayerIndex = (playerIndex + 1) % room.players.length;
    
    return room.copyWith(
      board: updatedBoard,
      players: updatedPlayers,
      currentPlayerIndex: nextPlayerIndex,
      moveHistory: [...room.moveHistory, move],
    );
  }
  
  /// Draws tiles from the bag to fill the player's rack
  static List<Tile> drawTilesForPlayer({
    required LetterDistribution letterDistribution,
    required Player player,
    required int count,
  }) {
    final canTake = maxRackSize - player.rack.length;
    if (canTake <= 0) return [];
    final toDraw = math.min(count, canTake);
    return letterDistribution.drawTiles(toDraw);
  }
  
  /// Checks if the game is over
  static bool isGameOver(Room room) {
    // Game ends when:
    // 1. A player has no tiles left and the bag is empty
    // 2. All players have passed twice in a row
    
    // Check if any player has no tiles left
    final playerWithNoTiles = room.players.firstWhere(
      (p) => p.rack.isEmpty,
      orElse: () => room.players.first,
    );
    
    if (playerWithNoTiles.rack.isEmpty && room.letterDistribution.tilesRemaining == 0) {
      return true;
    }
    
    // Check for consecutive passes
    if (room.moveHistory.length >= 4) {
      final lastMoves = room.moveHistory.sublist(room.moveHistory.length - 4);
      return lastMoves.every((move) => move.type == MoveType.pass);
    }
    
    return false;
  }
  
  /// Calculates the final scores when the game ends
  static Map<String, int> calculateFinalScores(Room room) {
    final scores = <String, int>{};
    
    for (final player in room.players) {
      // Add up all points from moves
      int totalScore = player.score;
      
      // Subtract remaining tile values
      final remainingTileValue = player.rack.fold<int>(
        0, 
        (sum, tile) => sum + tile.value
      );
      
      // If a player uses all their tiles, add other players' remaining tile values
      if (player.rack.isEmpty) {
        for (final otherPlayer in room.players) {
          if (otherPlayer.id != player.id) {
            final otherRemainingValue = otherPlayer.rack.fold<int>(
              0, 
              (sum, tile) => sum + tile.value
            );
            totalScore += otherRemainingValue;
          }
        }
      } else {
        totalScore -= remainingTileValue;
      }
      
      scores[player.id] = totalScore;
    }
    
    return scores;
  }
  
  // Helper methods
  static bool _areTilesInStraightLine(List<PlacedTile> placedTiles) {
    if (placedTiles.length == 1) return true;
    
    // Check if all in same row
    final sameRow = placedTiles.every(
      (t) => t.position.row == placedTiles.first.position.row
    );
    
    // Check if all in same column
    final sameCol = placedTiles.every(
      (t) => t.position.col == placedTiles.first.position.col
    );
    
    return sameRow || sameCol;
  }
  
  static bool _isMoveConnectedToExistingTiles(Board board, List<PlacedTile> placedTiles) {
    for (final placedTile in placedTiles) {
      final pos = placedTile.position;
      
      // Check adjacent positions
      final adjacentPositions = [
        Position(row: pos.row - 1, col: pos.col), // top
        Position(row: pos.row + 1, col: pos.col), // bottom
        Position(row: pos.row, col: pos.col - 1), // left
        Position(row: pos.row, col: pos.col + 1), // right
      ];
      
      for (final adjPos in adjacentPositions) {
        if (adjPos.row >= 0 && 
            adjPos.row < boardSize && 
            adjPos.col >= 0 && 
            adjPos.col < boardSize &&
            board.getTileAt(adjPos) != null) {
          return true;
        }
      }
    }
    
    return false;
  }
  

  static bool _isContiguousWithBoard(Board board, List<PlacedTile> placedTiles) {
    if (placedTiles.isEmpty) return false;
    if (placedTiles.length == 1) return true; // single tile is trivially contiguous
    final sameRow = placedTiles.every((t) => t.position.row == placedTiles.first.position.row);
    final sameCol = placedTiles.every((t) => t.position.col == placedTiles.first.position.col);
    final positions = placedTiles.map((pt) => pt.position).toList();
    if (sameRow) {
      final r = positions.first.row;
      final cols = positions.map((p) => p.col).toList()..sort();
      for (int col = cols.first; col <= cols.last; col++) {
        final pos = Position(row: r, col: col);
        final hasPlaced = positions.any((p) => p == pos);
        final hasBoard = board.getTileAt(pos) != null;
        if (!hasPlaced && !hasBoard) return false; // gap
      }
      return true;
    }
    if (sameCol) {
      final c = positions.first.col;
      final rows = positions.map((p) => p.row).toList()..sort();
      for (int row = rows.first; row <= rows.last; row++) {
        final pos = Position(row: row, col: c);
        final hasPlaced = positions.any((p) => p == pos);
        final hasBoard = board.getTileAt(pos) != null;
        if (!hasPlaced && !hasBoard) return false;
      }
      return true;
    }
    return false;
  }
}

class MoveValidationResult {
  final bool isValid;
  final String message;
  final int points;
  final List<String> wordsFormed;
  
  const MoveValidationResult({
    required this.isValid,
    required this.message,
    this.points = 0,
    this.wordsFormed = const [],
  });
}

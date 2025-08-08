import 'dart:math' as math;
import 'package:mp_tictactoe/models/board.dart';
import 'package:mp_tictactoe/models/letter_distribution.dart';
import 'package:mp_tictactoe/models/move.dart';
import 'package:mp_tictactoe/models/player.dart';
import 'package:mp_tictactoe/models/position.dart';
import 'package:mp_tictactoe/models/room.dart';
import 'package:mp_tictactoe/models/tile.dart';
import 'package:mp_tictactoe/provider/dictionary_provider.dart';

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
  
    // 1. Check if it's the player's turn
    if (room.currentPlayerId != playerId) {
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
      return MoveValidationResult(
        isValid: false,
        message: 'Tiles must be placed in a straight line!',
      );
    }
    
    // 5. Check if the move connects with existing tiles (except first move)
    if (!room.isFirstMove && !_isMoveConnectedToExistingTiles(board, placedTiles)) {
      return MoveValidationResult(
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
    
    // 7. Check if all words formed are valid
    final words = _findWordsFormed(board, placedTiles);
    final invalidWords = _getInvalidWords(words);
    
    if (invalidWords.isNotEmpty) {
      return MoveValidationResult(
        isValid: false,
        message: 'Invalid words: ${invalidWords.join(', ')}',
      );
    }
    
    // 8. Calculate points
    final points = _calculatePoints(board, placedTiles, words);
    
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
      updatedBoard = updatedBoard.placeTile(placedTile.tile, placedTile.position);
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
  
  static List<String> _getInvalidWords(List<String> words) {
    // Validate words using the Arabic dictionary
    final dict = DictionaryProvider();
    return dict.getInvalidWords(words);
  }
  
  static int _calculatePoints(Board board, List<PlacedTile> placedTiles, List<String> words) {
    // TODO: Implement point calculation with bonuses
    // For now, just sum the values of placed tiles
    return placedTiles.fold(0, (sum, tile) => sum + tile.tile.value);
  }
  
  static List<String> _findWordsFormed(Board board, List<PlacedTile> placedTiles) {
    // TODO: Implement word finding logic
    // For now, return a single word formed by placed tiles
    final word = String.fromCharCodes(
      placedTiles.map((pt) => pt.tile.letter.codeUnitAt(0))
    );
    return [word];
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

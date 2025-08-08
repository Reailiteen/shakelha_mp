import 'package:flutter/material.dart';
import 'package:mp_tictactoe/models/letter.dart';

class GameMethods {
  bool validateWordPlacement({
    required List<List<Letter?>> board,
    required Set<String> validWords,
    required bool isFirstMove,
  }) {
    const int boardSize = 15;
    const center = 7;

    List<Offset> placedOffsets = [];

    // 1. Collect newly placed tile positions
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (board[row][col]?.isNew == true) {
          placedOffsets.add(Offset(row.toDouble(), col.toDouble()));
        }
      }
    }

    if (placedOffsets.isEmpty) return false;

    // 2. Check all placed tiles are in one row or one column
    bool sameRow = placedOffsets.every((p) => p.dx == placedOffsets.first.dx);
    bool sameCol = placedOffsets.every((p) => p.dy == placedOffsets.first.dy);

    if (!sameRow && !sameCol) return false;

    // 3. Check first move is connected to center
    if (isFirstMove) {
      bool centerUsed = placedOffsets.any((p) => p.dx == center && p.dy == center);
      if (!centerUsed) return false;
    } else {
      // 4. Check connectivity to existing tiles
      bool isConnected = placedOffsets.any((p) {
        int x = p.dx.toInt();
        int y = p.dy.toInt();
        return [
          if (x > 0) board[x - 1][y],
          if (x < boardSize - 1) board[x + 1][y],
          if (y > 0) board[x][y - 1],
          if (y < boardSize - 1) board[x][y + 1],
        ].any((t) => t != null && !t.isNew);
      });

      if (!isConnected) return false;
    }

    // 5. Get primary word
    List<Letter> primaryWordTiles = [];
    Offset start = placedOffsets.first;
    int startX = start.dx.toInt();
    int startY = start.dy.toInt();

    if (sameRow) {
      // RTL: go right first (since Arabic goes right to left)
      int y = startY;
      while (y < boardSize && board[startX][y] != null) y++;
      int endY = y - 1;
      y = startY;
      while (y >= 0 && board[startX][y] != null) y--;
      int beginY = y + 1;

      for (int i = endY; i >= beginY; i--) {
        primaryWordTiles.add(board[startX][i]!);
      }
    } else {
      // Column-wise
      int x = startX;
      while (x < boardSize && board[x][startY] != null) x++;
      int endX = x - 1;
      x = startX;
      while (x >= 0 && board[x][startY] != null) x--;
      int beginX = x + 1;

      for (int i = beginX; i <= endX; i++) {
        primaryWordTiles.add(board[i][startY]!);
      }
    }

    // 6. Validate main word
    String mainWord = primaryWordTiles.map((e) => e.letter).join();
    if (!validWords.contains(mainWord)) return false;

    // 7. Validate secondary words formed by new tiles
    for (final pos in placedOffsets) {
      int x = pos.dx.toInt();
      int y = pos.dy.toInt();

      List<Letter> word = [];

      if (sameRow) {
        // check vertical word
        int i = x;
        while (i >= 0 && board[i][y] != null) i--;
        int beginX = i + 1;
        i = x;
        while (i < boardSize && board[i][y] != null) i++;
        int endX = i - 1;

        if (endX > beginX) {
          for (int j = beginX; j <= endX; j++) {
            word.add(board[j][y]!);
          }
        }
      } else {
        // check horizontal word
        int i = y;
        while (i >= 0 && board[x][i] != null) i--;
        int beginY = i + 1;
        i = y;
        while (i < boardSize && board[x][i] != null) i++;
        int endY = i - 1;

        if (endY > beginY) {
          for (int j = endY; j >= beginY; j--) {
            word.add(board[x][j]!); // RTL
          }
        }
      }

      if (word.isNotEmpty) {
        String sideWord = word.map((e) => e.letter).join();
        if (!validWords.contains(sideWord)) return false;
      }
    }

    return true;
  }

}

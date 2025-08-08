import 'package:flutter_test/flutter_test.dart';
import 'package:mp_tictactoe/models/board.dart';
import 'package:mp_tictactoe/models/letterDistribution.dart';
import 'package:mp_tictactoe/models/move.dart';
import 'package:mp_tictactoe/models/player.dart';
import 'package:mp_tictactoe/models/position.dart';
import 'package:mp_tictactoe/models/room.dart';
import 'package:mp_tictactoe/models/tile.dart';
import 'package:mp_tictactoe/models/user.dart';

void main() {
  group('Model Serialization Tests', () {
    test('Tile serialization', () {
      final tile = Tile(
        letter: 'A',
        value: 1,
        isOnBoard: true,
        isNewlyPlaced: true,
        ownerId: 'player1',
      );
      
      final json = tile.toJson();
      final deserialized = Tile.fromJson(json);
      
      expect(deserialized.letter, equals(tile.letter));
      expect(deserialized.value, equals(tile.value));
      expect(deserialized.isOnBoard, equals(tile.isOnBoard));
      expect(deserialized.isNewlyPlaced, equals(tile.isNewlyPlaced));
      expect(deserialized.ownerId, equals(tile.ownerId));
    });

    test('Player serialization', () {
      final user = User(
        id: 'user1',
        username: 'testuser',
        email: 'test@example.com',
      );
      
      final player = Player(
        user: user,
        id: 'player1',
        nickname: 'Test Player',
        socketId: 'socket123',
        score: 100,
        isCurrentTurn: true,
      );
      
      final json = player.toJson();
      final deserialized = Player.fromJson(json);
      
      expect(deserialized.id, equals(player.id));
      expect(deserialized.nickname, equals(player.nickname));
      expect(deserialized.score, equals(player.score));
      expect(deserialized.isCurrentTurn, equals(player.isCurrentTurn));
      expect(deserialized.user?.id, equals(user.id));
    });

    test('Move serialization', () {
      final move = Move(
        id: 'move1',
        playerId: 'player1',
        type: MoveType.place,
        placedTiles: [
          PlacedTile(
            tile: Tile(letter: 'T', value: 1),
            position: Position(row: 7, col: 7),
            isNewWord: true,
          ),
        ],
        wordsFormed: ['TEST'],
        points: 10,
        isBingo: false,
      );
      
      final json = move.toJson();
      final deserialized = Move.fromJson(json);
      
      expect(deserialized.id, equals(move.id));
      expect(deserialized.playerId, equals(move.playerId));
      expect(deserialized.type, equals(move.type));
      expect(deserialized.placedTiles.length, equals(move.placedTiles.length));
      expect(deserialized.wordsFormed, equals(move.wordsFormed));
      expect(deserialized.points, equals(move.points));
      expect(deserialized.isBingo, equals(move.isBingo));
    });

    test('Room serialization', () {
      final user = User(
        id: 'user1',
        username: 'testuser',
        email: 'test@example.com',
      );
      
      final player = Player(
        user: user,
        id: 'player1',
        nickname: 'Test Player',
        socketId: 'socket123',
      );
      
      final room = Room.create(
        name: 'Test Room',
        creator: player,
        maxPlayers: 2,
      );
      
      final json = room.toJson();
      final deserialized = Room.fromJson(json);
      
      expect(deserialized.id, isNotEmpty);
      expect(deserialized.name, equals(room.name));
      expect(deserialized.players.length, equals(1));
      expect(deserialized.players.first.id, equals(player.id));
      expect(deserialized.maxPlayers, equals(2));
    });

    test('LetterDistribution serialization', () {
      final distribution = LetterDistribution.english();
      final json = distribution.toJson();
      final deserialized = LetterDistribution.fromJson(json);
      
      // Can't directly compare the objects, so we'll check some properties
      expect(deserialized.tilesRemaining, greaterThan(0));
      
      // Test letter values
      expect(deserialized.getLetterValue('A'), equals(1));
      expect(deserialized.getLetterValue('Q'), equals(10));
      expect(deserialized.getLetterValue('Z'), equals(10));
    });
  });
}

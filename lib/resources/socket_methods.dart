
import 'package:flutter/material.dart';
import 'package:mp_tictactoe/models/room.dart';
import 'package:mp_tictactoe/models/tile.dart';
import 'package:mp_tictactoe/models/board.dart';
import 'package:mp_tictactoe/models/letter_distribution.dart';
import 'package:mp_tictactoe/models/player.dart';
import 'package:mp_tictactoe/provider/room_data_provider.dart';
import 'package:mp_tictactoe/resources/socket_client.dart';
import 'package:mp_tictactoe/screens/game_screen.dart';
import 'package:mp_tictactoe/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  // EMITS
  /// Creates a new game room
  void createRoom(String nickname) {
    if (nickname.isNotEmpty) {
      _socketClient.emit('createRoom', {
        'nickname': nickname,
      });
    }
  }

  /// Joins an existing game room
  void joinRoom(String nickname, String roomId) {
    if (nickname.isNotEmpty && roomId.isNotEmpty) {
      _socketClient.emit('joinRoom', {
        'nickname': nickname,
        'roomId': roomId,
      });
    }
  }

  /// Places tiles on the board
  void placeTiles(String roomId, List<Map<String, dynamic>> placedTiles) {
    _socketClient.emit('placeTiles', {
      'roomId': roomId,
      'placedTiles': placedTiles,
    });
  }
  
  /// Exchanges tiles from the player's rack
  void exchangeTiles(String roomId, List<String> tileIds) {
    _socketClient.emit('exchangeTiles', {
      'roomId': roomId,
      'tileIds': tileIds,
    });
  }
  
  /// Passes the current turn
  void passTurn(String roomId) {
    debugPrint('[emit passTurn] roomId=' + roomId);
    _socketClient.emit('passTurn', {
      'roomId': roomId,
    });
  }
  
  /// Submits the current move
  void submitMove(String roomId) {
    _socketClient.emit('submitMove', {
      'roomId': roomId,
    });
  }
  
  /// Cancels the current move and returns tiles to the rack
  void cancelMove(String roomId) {
    _socketClient.emit('cancelMove', {
      'roomId': roomId,
    });
  }

  // LISTENERS
  // Normalizes server (Mongo) room payload into our Room model JSON
  Map<String, dynamic> _normalizeRoom(dynamic roomData) {
    if (roomData is! Map) return {};
    final map = Map<String, dynamic>.from(roomData);
    // If already in our shape, return as-is
    if (map.containsKey('id') && map.containsKey('board')) return map;

    // Server shape -> client shape
    final players = ((map['players'] as List?) ?? const []).map((p) {
      final pm = Map<String, dynamic>.from(p as Map);
      final socketID = pm['socketID'] as String? ?? '';
      final nickname = pm['nickname'] as String? ?? 'Player';
      final isCurrent = (map['turn'] is Map) && (map['turn']['socketID'] == socketID);
      return {
        'id': socketID,
        'nickname': nickname,
        'socketId': socketID,
        'score': pm['points'] ?? 0,
        'type': 'human',
        'rack': <dynamic>[],
        'moves': <dynamic>[],
        'isCurrentTurn': isCurrent,
        'hasPassed': false,
        'hasExchanged': false,
      };
    }).toList();

    final currentIdx = map['turnIndex'] is int ? map['turnIndex'] as int : 0;
    final createdBy = players.isNotEmpty ? players.first['id'] as String : '';

    return {
      'id': (map['_id'] ?? map['id'] ?? '').toString(),
      'name': (map['name'] ?? 'Room').toString(),
      'maxPlayers': map['maxRounds'] is int ? 2 : (map['maxPlayers'] ?? 2),
      'players': players,
      'board': Board.empty().toJson(),
      'letterDistribution': LetterDistribution().toJson(),
      'currentPlayerIndex': currentIdx,
      'moveHistory': <dynamic>[],
      'hasGameStarted': players.length > 1,
      'hasGameEnded': false,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'settings': const RoomSettings().toJson(),
      'createdBy': createdBy,
    };
  }
  void createRoomSuccessListener(BuildContext context) {
    _socketClient.on('createRoomSuccess', (roomData) {
      debugPrint('[createRoomSuccess] raw payload: ' + roomData.toString());
      var room = Room.fromJson(_normalizeRoom(roomData));
      debugPrint('[createRoomSuccess] normalized: id=' + room.id +
          ', players=' + room.players.length.toString() +
          ', started=' + room.hasGameStarted.toString());
      // Deal initial racks if empty
      if (room.players.every((p) => p.rack.isEmpty)) {
        final ld = room.letterDistribution; // mutable bag
        final List<Player> players = room.players;
        final newPlayers = players.map((p) {
          final need = 7 - p.rack.length;
          final List<Tile> drawn = need > 0 ? ld.drawTiles(need) : <Tile>[];
          final owned = drawn.map((t) => t.copyWith(ownerId: p.id)).toList();
          return p.updateRack([...p.rack, ...owned]);
        }).toList();
        room = room.copyWith(players: newPlayers, letterDistribution: ld);
      }
      for (final p in room.players) {
        debugPrint('[createRoomSuccess] rack ${p.nickname} size=' + p.rack.length.toString());
      }
      Provider.of<RoomDataProvider>(context, listen: false).updateRoom(room);
      Navigator.pushNamed(context, GameScreen.routeName);
    });
  }

  void joinRoomSuccessListener(BuildContext context) {
    _socketClient.on('joinRoomSuccess', (roomData) {
      debugPrint('[joinRoomSuccess] raw payload: ' + roomData.toString());
      var room = Room.fromJson(_normalizeRoom(roomData));
      debugPrint('[joinRoomSuccess] normalized: id=' + room.id +
          ', players=' + room.players.length.toString() +
          ', started=' + room.hasGameStarted.toString());
      // Ensure racks are dealt at join time if missing
      if (room.players.any((p) => p.rack.isEmpty)) {
        final ld = room.letterDistribution;
        final List<Player> players = room.players;
        final newPlayers = players.map((p) {
          final need = 7 - p.rack.length;
          final List<Tile> drawn = need > 0 ? ld.drawTiles(need) : <Tile>[];
          final owned = drawn.map((t) => t.copyWith(ownerId: p.id)).toList();
          return p.updateRack([...p.rack, ...owned]);
        }).toList();
        room = room.copyWith(players: newPlayers, letterDistribution: ld);
      }
      for (final p in room.players) {
        debugPrint('[joinRoomSuccess] rack ${p.nickname} size=' + p.rack.length.toString());
      }
      Provider.of<RoomDataProvider>(context, listen: false).updateRoom(room);
      Navigator.pushNamed(context, GameScreen.routeName);
    });
  }

  /// Optional: listens for player list updates
  /// Server also emits 'updateRoom' with full room after this, so this is informational
  void updatePlayersStateListener(BuildContext context) {
    _socketClient.on('updatePlayers', (playersData) {
      // Inform the user someone joined/left; 'updateRoom' will sync state shortly
      try {
        final count = (playersData as List).length;
        showSnackBar(context, 'Players in room: $count');
      } catch (_) {}
    });
  }

  void errorOccuredListener(BuildContext context) {
    _socketClient.on('errorOccurred', (data) {
      debugPrint('[socket errorOccurred] payload: ' + data.toString());
      showSnackBar(context, data);
    });
  }

  /// Listens for updates to the game room
  void updateRoomListener(BuildContext context) {
    _socketClient.on('updateRoom', (roomData) {
      var incoming = Room.fromJson(_normalizeRoom(roomData));
      final provider = Provider.of<RoomDataProvider>(context, listen: false);
      final current = provider.room;
      if (current != null) {
        // Merge: keep local board, bag, and racks; update metadata from server
        final mergedPlayers = incoming.players.map((pIn) {
          final existing = current.players.firstWhere(
            (p) => p.id == pIn.id,
            orElse: () => pIn,
          );
          final rack = existing.rack.isNotEmpty ? existing.rack : pIn.rack;
          return pIn.copyWith(rack: rack);
        }).toList();
        incoming = incoming.copyWith(
          board: current.board,
          letterDistribution: current.letterDistribution,
          players: mergedPlayers,
        );
        // If any rack still empty, deal from local bag
        if (incoming.players.any((p) => p.rack.isEmpty)) {
          final ld = incoming.letterDistribution;
          final dealt = incoming.players.map((p) {
            if (p.rack.isEmpty) {
              final need = 7;
              final drawn = ld.drawTiles(need);
              final owned = drawn.map((t) => t.copyWith(ownerId: p.id)).toList();
              return p.updateRack(owned);
            }
            return p;
          }).toList();
          incoming = incoming.copyWith(players: dealt, letterDistribution: ld);
        }
        for (final p in incoming.players) {
          debugPrint('[updateRoom merge] rack ${p.nickname} size=' + p.rack.length.toString());
        }
      }
      provider.updateRoom(incoming);
    });
  }

  /// Listens for tiles placed on the server and updates the full room state
  void tilesPlacedListener(BuildContext context) {
    _socketClient.on('tilesPlaced', (data) {
      final room = Room.fromJson(_normalizeRoom(data['room']));
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoom(room);
    });
  }
  
  /// Listens for move submission and updates room/turn
  void moveSubmittedListener(BuildContext context) {
    _socketClient.on('moveSubmitted', (data) {
      final room = Room.fromJson(_normalizeRoom(data['room']));
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoom(room);
    });
  }
  
  /// Listens for turn pass and updates room/turn
  void turnPassedListener(BuildContext context) {
    _socketClient.on('turnPassed', (data) {
      final room = Room.fromJson(_normalizeRoom(data['room']));
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoom(room);
    });
  }
  
  /// Listens for tile exchanges and updates room state
  void tilesExchangedListener(BuildContext context) {
    _socketClient.on('tilesExchanged', (data) {
      final room = Room.fromJson(_normalizeRoom(data['room']));
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoom(room);
    });
  }
  
  /// Listens for game over events
  void gameOverListener(BuildContext context) {
    _socketClient.on('gameOver', (data) {
      final roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
      final winnerId = data['winnerId'] as String?;
      final scores = Map<String, int>.from(data['scores']);
      roomDataProvider.setGameOver(winnerId, scores);
    });
  }
  
  /// Listens for error messages
  void errorOccurredListener(BuildContext context) {
    _socketClient.on('errorOccurred', (data) {
      debugPrint('[socket errorOccurred] payload: ' + data.toString());
      try {
        if (data is String) {
          showSnackBar(context, data);
        } else if (data is Map && data['message'] is String) {
          showSnackBar(context, data['message']);
        } else {
          showSnackBar(context, 'An error occurred');
        }
      } catch (_) {
        showSnackBar(context, 'An error occurred');
      }
    });
  }
  
  /// Listens for player turn changes
  void turnChangedListener(BuildContext context) {
    _socketClient.on('turnChanged', (data) {
      final roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
      final currentPlayerId = data['currentPlayerId'] as String;
      roomDataProvider.setCurrentPlayer(currentPlayerId);
    });
  }
}

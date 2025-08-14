
import 'package:flutter/material.dart';
import 'dart:math' as math;
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
  /// Optional params: isPublic, name, occupancy
  void createRoom(String nickname, {bool isPublic = false, String name = 'Room', int occupancy = 2}) {
    if (nickname.isNotEmpty) {
      _socketClient.emit('createRoom', {
        'nickname': nickname,
        'isPublic': isPublic,
        'name': name,
        'occupancy': occupancy,
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
  
  /// Submits the current move (optionally with placedTiles payload)
  void submitMove(String roomId, {List<Map<String, dynamic>>? placedTiles}) {
    final payload = <String, dynamic>{'roomId': roomId};
    if (placedTiles != null) payload['placedTiles'] = placedTiles;
    debugPrint('[emit submitMove] roomId=' + roomId + (placedTiles == null ? '' : ', placedTiles=' + placedTiles.length.toString()));
    _socketClient.emit('submitMove', payload);
  }
  
  /// Cancels the current move and returns tiles to the rack
  void cancelMove(String roomId) {
    _socketClient.emit('cancelMove', {
      'roomId': roomId,
    });
  }

  /// Broadcasts a live hover/preview of a tile over a board position
  /// Payload example: { roomId, hover: { letter, row, col } }
  void hoverTile(String roomId, {required String letter, required int row, required int col}) {
    _socketClient.emit('hoverTile', {
      'roomId': roomId,
      'hover': {
        'letter': letter,
        'row': row,
        'col': col,
      }
    });
  }

  /// Clears the current hover/preview for this client
  void clearHover(String roomId) {
    _socketClient.emit('clearHover', {
      'roomId': roomId,
    });
  }

  /// Request list of public rooms (lobby)
  void listRooms({String status = 'open', int page = 1, int pageSize = 20}) {
    _socketClient.emit('listRooms', {
      'status': status,
      'page': page,
      'pageSize': pageSize,
    });
  }

  /// Marks the current player as ready/unready in the lobby.
  /// Server should:
  /// - track ready state per player
  /// - when all players are ready, transition room status to 'playing'
  /// - broadcast 'updateRoom' with the updated room
  void readyUp({required String roomId, bool ready = true}) {
    _socketClient.emit('readyUp', {
      'roomId': roomId,
      'ready': ready,
    });
  }

  /// Host-only: toggle room visibility in lobby list
  void setRoomVisibility({required String roomId, required bool isPublic}) {
    _socketClient.emit('setRoomVisibility', {
      'roomId': roomId,
      'isPublic': isPublic,
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

    // Map server board (2D array) -> client Board
    Board normalizedBoard;
    final size = (map['size'] is int) ? map['size'] as int : 15;
    if (map['board'] is List) {
      final srvBoard = map['board'] as List;
      final grid = List.generate(size, (_) => List<Tile?>.filled(size, null));
      for (int r = 0; r < srvBoard.length && r < size; r++) {
        final row = srvBoard[r];
        if (row is! List) continue;
        for (int c = 0; c < row.length && c < size; c++) {
          final cell = row[c];
          if (cell == null) continue;
          if (cell is Map) {
            final letter = (cell['letter'] ?? '') as String;
            if (letter.isEmpty) continue;
            final points = (cell['points'] ?? cell['value'] ?? 1) as int;
            final isNew = (cell['isNewlyPlaced'] ?? cell['isNew'] ?? false) as bool;
            grid[r][c] = Tile(
              letter: letter,
              value: points,
              isOnBoard: true,
              isNewlyPlaced: isNew,
            );
          } else if (cell is String && cell.isNotEmpty) {
            grid[r][c] = Tile(letter: cell, value: 1, isOnBoard: true);
          }
        }
      }
      normalizedBoard = Board(size: size, grid: grid, cellMultipliers: Board.empty(size: size).cellMultipliers);
    } else {
      normalizedBoard = Board.empty(size: size);
    }

    return {
      'id': (map['_id'] ?? map['id'] ?? '').toString(),
      'name': (map['name'] ?? 'Room').toString(),
      'maxPlayers': map['occupancy'] is int ? map['occupancy'] as int : (map['maxPlayers'] ?? 2),
      'players': players,
      'board': normalizedBoard.toJson(),
      'letterDistribution': LetterDistribution().toJson(),
      'currentPlayerIndex': currentIdx,
      'moveHistory': <dynamic>[],
      'hasGameStarted': players.length > 1 || (map['status'] == 'playing') || normalizedBoard.getOccupiedPositions().isNotEmpty,
      'hasGameEnded': false,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'settings': const RoomSettings().toJson(),
      'createdBy': createdBy,
      'isPublic': (map['isPublic'] ?? false) as bool,
      'status': (map['status'] ?? 'open').toString(),
      'hostSocketId': (map['hostSocketId'] ?? '') as String,
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

  /// Listen for lobby room list response
  void roomsListListener(BuildContext context, void Function(List<Map<String, dynamic>> rooms) onRooms) {
    _socketClient.on('roomsList', (data) {
      try {
        final list = (data as List).cast<dynamic>();
        final rooms = list.map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return {
            'id': (m['id'] ?? m['_id']).toString(),
            'name': (m['name'] ?? 'Room').toString(),
            'seats': (m['seats'] ?? '${(m['players'] as List? ?? const []).length}/${m['occupancy'] ?? 2}').toString(),
            'status': (m['status'] ?? 'open').toString(),
            'updatedAt': m['updatedAt'],
          };
        }).toList();
        onRooms(rooms);
      } catch (_) {
        showSnackBar(context, 'Failed to parse rooms');
      }
    });
  }

  /// Listen for lobby updates; clients should call listRooms on this signal
  void roomsUpdatedListener(void Function() onUpdated) {
    _socketClient.on('roomsUpdated', (_) => onUpdated());
  }

  /// Optional: listen for lobby ready updates (backend should emit 'lobbyReadyUpdate')
  /// Payload example: { roomId, players: [{id, nickname, ready}], allReady: bool }
  void lobbyReadyUpdateListener(BuildContext context) {
    _socketClient.on('lobbyReadyUpdate', (data) {
      // We rely on updateRoom to reflect authoritative state.
      // This is an optional UX hint; for now we no-op.
    });
  }

  /// Listens for updates to the game room
  void updateRoomListener(BuildContext context) {
    _socketClient.on('updateRoom', (roomData) {
      var incoming = Room.fromJson(_normalizeRoom(roomData));
      final provider = Provider.of<RoomDataProvider>(context, listen: false);
      final current = provider.room;
      if (current != null) {
        // Merge: prefer incoming board and racks; keep local bag; fallback to existing rack only if incoming has none
        final mergedPlayers = incoming.players.map((pIn) {
          final existing = current.players.firstWhere(
            (p) => p.id == pIn.id,
            orElse: () => pIn,
          );
          final useIncomingRack = pIn.rack.isNotEmpty;
          final rack = useIncomingRack ? pIn.rack : existing.rack;
          return pIn.copyWith(
            rack: rack,
            score: math.max(pIn.score, existing.score),
          );
        }).toList();
        final incomingHasTiles = incoming.board.getOccupiedPositions().isNotEmpty;
        final boardToUse = incomingHasTiles ? incoming.board : current.board;
        incoming = incoming.copyWith(
          board: boardToUse, // don't wipe board if server sent empty grid
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

  /// Mirrors opponent hover previews in the local UI
  void hoverUpdateListener(BuildContext context) {
    _socketClient.on('hoverUpdate', (data) {
      try {
        final socketId = data['socketId'] as String?;
        final hover = data['hover'] as Map?;
        if (socketId != null && hover != null) {
          final letter = (hover['letter'] ?? '') as String;
          final row = (hover['row'] ?? -1) as int;
          final col = (hover['col'] ?? -1) as int;
          Provider.of<RoomDataProvider>(context, listen: false)
              .updateRemoteHover(socketId: socketId, letter: letter, row: row, col: col);
        }
      } catch (_) {}
    });

    _socketClient.on('hoverCleared', (data) {
      try {
        final socketId = (data is Map) ? data['socketId'] as String? : data as String?;
        if (socketId != null) {
          Provider.of<RoomDataProvider>(context, listen: false)
              .clearRemoteHover(socketId);
        }
      } catch (_) {}
    });
  }

  /// Listens for tiles placed on the server and updates the full room state
  void tilesPlacedListener(BuildContext context) {
    _socketClient.on('tilesPlaced', (data) {
      var incoming = Room.fromJson(_normalizeRoom(data['room']));
      final provider = Provider.of<RoomDataProvider>(context, listen: false);
      final current = provider.room;
      if (current != null) {
        final mergedPlayers = incoming.players.map((pIn) {
          final existing = current.players.firstWhere(
            (p) => p.id == pIn.id,
            orElse: () => pIn,
          );
          final useIncomingRack = pIn.rack.isNotEmpty;
          final rack = useIncomingRack ? pIn.rack : existing.rack;
          return pIn.copyWith(rack: rack);
        }).toList();
        final incomingHasTiles = incoming.board.getOccupiedPositions().isNotEmpty;
        final boardToUse = incomingHasTiles ? incoming.board : current.board;
        incoming = incoming.copyWith(
          board: boardToUse,
          letterDistribution: current.letterDistribution,
          players: mergedPlayers,
        );
      }
      provider.updateRoom(incoming);
    });
  }
  
  /// Listens for move submission and updates room/turn
  void moveSubmittedListener(BuildContext context) {
    _socketClient.on('moveSubmitted', (data) {
      var incoming = Room.fromJson(_normalizeRoom(data['room']));
      final provider = Provider.of<RoomDataProvider>(context, listen: false);
      final current = provider.room;
      if (current != null) {
        final mergedPlayers = incoming.players.map((pIn) {
          final existing = current.players.firstWhere(
            (p) => p.id == pIn.id,
            orElse: () => pIn,
          );
          final useIncomingRack = pIn.rack.isNotEmpty;
          final rack = useIncomingRack ? pIn.rack : existing.rack;
          return pIn.copyWith(
            rack: rack,
            score: math.max(pIn.score, existing.score),
          );
        }).toList();
        final incomingHasTiles = incoming.board.getOccupiedPositions().isNotEmpty;
        final boardToUse = incomingHasTiles ? incoming.board : current.board;
        incoming = incoming.copyWith(
          board: boardToUse,
          letterDistribution: current.letterDistribution,
          players: mergedPlayers,
        );
      }
      provider.updateRoom(incoming);
    });
  }
  
  /// Listens for turn pass and updates room/turn
  void turnPassedListener(BuildContext context) {
    _socketClient.on('turnPassed', (data) {
      var incoming = Room.fromJson(_normalizeRoom(data['room']));
      final provider = Provider.of<RoomDataProvider>(context, listen: false);
      final current = provider.room;
      if (current != null) {
        final mergedPlayers = incoming.players.map((pIn) {
          final existing = current.players.firstWhere(
            (p) => p.id == pIn.id,
            orElse: () => pIn,
          );
          final useIncomingRack = pIn.rack.isNotEmpty;
          final rack = useIncomingRack ? pIn.rack : existing.rack;
          return pIn.copyWith(rack: rack);
        }).toList();
        final incomingHasTiles = incoming.board.getOccupiedPositions().isNotEmpty;
        final boardToUse = incomingHasTiles ? incoming.board : current.board;
        incoming = incoming.copyWith(
          board: boardToUse,
          letterDistribution: current.letterDistribution,
          players: mergedPlayers,
        );
      }
      provider.updateRoom(incoming);
    });
  }
  
  /// Listens for tile exchanges and updates room state
  void tilesExchangedListener(BuildContext context) {
    _socketClient.on('tilesExchanged', (data) {
      var incoming = Room.fromJson(_normalizeRoom(data['room']));
      final provider = Provider.of<RoomDataProvider>(context, listen: false);
      final current = provider.room;
      if (current != null) {
        final mergedPlayers = incoming.players.map((pIn) {
          final existing = current.players.firstWhere(
            (p) => p.id == pIn.id,
            orElse: () => pIn,
          );
          // For exchanges, incoming should have racks; fallback if missing
          final rack = pIn.rack.isNotEmpty ? pIn.rack : existing.rack;
          return pIn.copyWith(
            rack: rack,
            score: math.max(pIn.score, existing.score),
          );
        }).toList();
        incoming = incoming.copyWith(
          board: incoming.board,
          letterDistribution: current.letterDistribution,
          players: mergedPlayers,
        );
      }
      provider.updateRoom(incoming);
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

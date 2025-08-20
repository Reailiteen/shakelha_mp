
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shakelha_mp/models/room.dart';
import 'package:shakelha_mp/models/tile.dart';
import 'package:shakelha_mp/models/board.dart';
import 'package:shakelha_mp/models/letterDistribution.dart';
import 'package:shakelha_mp/models/player.dart';
import 'package:shakelha_mp/models/move.dart';
import 'package:shakelha_mp/provider/room_data_provider.dart';
import 'package:shakelha_mp/resources/socket_client.dart';
import 'package:shakelha_mp/screens/game_screen.dart';
import 'package:shakelha_mp/utils/utils.dart';
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
      final payload = {
        'nickname': nickname,
        'isPublic': isPublic,
        'name': name,
        'occupancy': occupancy,
      };
      debugPrint('[SocketMethods] Emitting createRoom: $payload');
      _socketClient.emit('createRoom', payload);
    } else {
      debugPrint('[SocketMethods] Cannot create room: nickname is empty');
    }
  }

  /// Joins an existing game room
  void joinRoom(String nickname, String roomId) async {
    if (nickname.isEmpty || roomId.isEmpty) {
      debugPrint('[SocketMethods] Cannot join room: nickname or roomId is empty');
      return;
    }
    
    // Wait a bit for socket to be ready if not connected
    if (!_socketClient.connected) {
      debugPrint('[SocketMethods] Socket not connected, waiting for connection...');
      int attempts = 0;
      while (!_socketClient.connected && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
        debugPrint('[SocketMethods] Connection attempt $attempts, connected: ${_socketClient.connected}');
      }
      
      if (!_socketClient.connected) {
        debugPrint('[SocketMethods] Failed to connect after $attempts attempts');
        return;
      }
    }
    
    debugPrint('[SocketMethods] Joining room: nickname=$nickname, roomId=$roomId');
    debugPrint('[SocketMethods] Socket connected: ${_socketClient.connected}, Socket ID: ${_socketClient.id}');
    
    _socketClient.emit('joinRoom', {
      'nickname': nickname,
      'roomId': roomId,
    });
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

  /// Reset the board state for a new game
  void resetBoard(String roomId) {
    debugPrint('[SocketMethods] Resetting board for room: $roomId');
    _socketClient.emit('resetBoard', {
      'roomId': roomId,
    });
  }

  // LISTENERS
  // Normalizes server (Mongo) room payload into our Room model JSON
  Map<String, dynamic> _normalizeRoom(Map<String, dynamic> map) {
    try {
      // Normalize players from server format
      final playersData = map['players'] as List? ?? [];
      final validPlayersData = playersData.where((p) {
        final playerMap = Map<String, dynamic>.from(p as Map);
        final playerId = (playerMap['_id'] ?? playerMap['id'] ?? playerMap['socketID'] ?? '').toString();
        return playerId.isNotEmpty;
      }).toList();
      
      final players = validPlayersData.map<Map<String, dynamic>>((p) {
        final playerMap = Map<String, dynamic>.from(p as Map);
        
        // Ensure required fields are never null or empty
        final playerId = (playerMap['_id'] ?? playerMap['id'] ?? playerMap['socketID'] ?? '').toString();
        final socketId = (playerMap['socketID'] ?? playerMap['socketId'] ?? playerId).toString();
        final nickname = (playerMap['nickname'] ?? 'Player').toString();
        
        debugPrint('[normalizeRoom] Creating player data: id=$playerId, nickname=$nickname, socketId=$socketId');
        
        return {
          'id': playerId,
          'nickname': nickname,
          'socketId': socketId,
          'score': playerMap['points'] ?? 0,
          'type': 'human',
          'rack': playerMap['currentLetters'] ?? playerMap['rack'] ?? <dynamic>[],
          'moves': playerMap['moves'] ?? <dynamic>[],
          'isCurrentTurn': false,
          'hasPassed': false,
          'hasExchanged': false,
        };
      }).toList();
      
      // Handle different turn field formats
      int currentIdx = 0;
      String createdBy = '';
      
      if (map.containsKey('turnIndex')) {
        currentIdx = map['turnIndex'] as int? ?? 0;
      } else if (map.containsKey('turn')) {
        final turnData = map['turn'] as Map?;
        if (turnData != null) {
          final turnPlayerId = turnData['_id'] ?? turnData['id'] ?? turnData['socketID'] ?? '';
          currentIdx = players.indexWhere((p) => p['id'] == turnPlayerId);
          if (currentIdx == -1) currentIdx = 0;
        }
      }
      
      // Get creator from players or host
      if (players.isNotEmpty) {
        createdBy = players.first['id'] as String;
      } else if (map.containsKey('hostSocketId')) {
        createdBy = map['hostSocketId'] as String? ?? '';
      }
      
      // Always start with a fresh board for new games
      // Only preserve board if the game is actively in progress
      Board normalizedBoard;
      final status = map['status'] as String? ?? 'open';
      final hasGameStarted = map['hasGameStarted'] as bool? ?? false;
      
      if (status == 'playing' && hasGameStarted && map['board'] != null) {
        // Game is in progress, preserve the board
        final boardData = map['board'] as Map<String, dynamic>;
        final size = boardData['size'] as int? ?? 15;
        final gridData = boardData['grid'] as List? ?? [];
        
        final grid = List.generate(size, (r) {
          if (r >= gridData.length) return List.filled(size, null);
          final rowData = gridData[r] as List? ?? [];
          return List.generate(size, (c) {
            if (c >= rowData.length) return null;
            final cell = rowData[c];
            if (cell == null) return null;
            if (cell is Map) {
              final letter = (cell['letter'] ?? '') as String;
              if (letter.isEmpty) return null;
              final points = (cell['points'] ?? cell['value'] ?? 1) as int;
              final isNew = (cell['isNewlyPlaced'] ?? cell['isNew'] ?? false) as bool;
              return Tile(
                letter: letter,
                value: points,
                isOnBoard: true,
                isNewlyPlaced: isNew,
              );
            } else if (cell is String && cell.isNotEmpty) {
              return Tile(letter: cell, value: 1, isOnBoard: true);
            }
            return null;
          });
        });
        normalizedBoard = Board(size: size, grid: grid, cellMultipliers: Board.empty(size: size).cellMultipliers);
        debugPrint('[normalizeRoom] Preserving existing board with ${normalizedBoard.getAllTiles().length} tiles');
      } else {
        // New game or room not started, use empty board
        normalizedBoard = Board.empty(size: 15);
        debugPrint('[normalizeRoom] Starting with fresh empty board');
      }

      final normalized = {
        'id': (map['_id'] ?? map['id'] ?? '').toString(),
        'name': (map['name'] ?? 'Room').toString(),
        'maxPlayers': map['occupancy'] is int ? map['occupancy'] as int : (map['maxPlayers'] ?? 2),
        'players': players,
        'board': normalizedBoard.toJson(),
        'letterDistribution': LetterDistribution.arabic().toJson(),
        'currentPlayerIndex': currentIdx,
        'moveHistory': <dynamic>[],
        'hasGameStarted': players.length > 1 || (status == 'playing') || normalizedBoard.getAllTiles().isNotEmpty,
        'hasGameEnded': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'settings': const RoomSettings().toJson(),
        'createdBy': createdBy,
        'isPublic': (map['isPublic'] ?? false) as bool,
        'status': status,
        'hostSocketId': (map['hostSocketId'] ?? '') as String,
      };
      
      debugPrint('[normalizeRoom] Successfully normalized room data');
      debugPrint('[normalizeRoom] Room ID: ${normalized['id']}');
      debugPrint('[normalizeRoom] Players count: ${normalized['players'].length}');
      debugPrint('[normalizeRoom] Max players: ${normalized['maxPlayers']}');
      debugPrint('[normalizeRoom] Status: ${normalized['status']}');
      return normalized;
    } catch (e) {
      debugPrint('[normalizeRoom] Error normalizing room data: $e');
      // Return a minimal valid room structure as fallback
      return {
        'id': (map['_id'] ?? map['id'] ?? 'fallback').toString(),
        'name': (map['name'] ?? 'Room').toString(),
        'maxPlayers': 2,
        'players': <Map<String, dynamic>>[],
        'board': Board.empty(size: 15).toJson(),
        'letterDistribution': LetterDistribution.arabic().toJson(),
        'currentPlayerIndex': 0,
        'moveHistory': <dynamic>[],
        'hasGameStarted': false,
        'hasGameEnded': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'settings': const RoomSettings().toJson(),
        'createdBy': '',
        'isPublic': false,
        'status': 'open',
        'hostSocketId': '',
      };
    }
  }
  void createRoomSuccessListener(BuildContext context) {
    _socketClient.on('createRoomSuccess', (roomData) {
      try {
        // Check if context is still mounted before proceeding
        if (!context.mounted) {
          debugPrint('[createRoomSuccess] Context no longer mounted, skipping room creation');
          return;
        }
        
        debugPrint('[createRoomSuccess] raw payload: $roomData');
        
        // Normalize the room data
        Map<String, dynamic> normalizedData;
        try {
          normalizedData = _normalizeRoom(roomData);
          debugPrint('[createRoomSuccess] Normalized data: ${normalizedData.keys}');
        } catch (normalizeError) {
          debugPrint('[createRoomSuccess] Error normalizing room data: $normalizeError');
          // Try to create a minimal room structure
          normalizedData = {
            'id': (roomData['_id'] ?? roomData['id'] ?? 'fallback').toString(),
            'name': (roomData['name'] ?? 'Room').toString(),
            'maxPlayers': 2,
            'players': <Map<String, dynamic>>[],
            'board': Board.empty(size: 15).toJson(),
            'letterDistribution': LetterDistribution.arabic().toJson(),
            'currentPlayerIndex': 0,
            'moveHistory': <dynamic>[],
            'hasGameStarted': false,
            'hasGameEnded': false,
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'settings': const RoomSettings().toJson(),
            'createdBy': '',
            'isPublic': false,
            'status': 'open',
            'hostSocketId': '',
          };
        }
        
        // Create Room object from normalized data
        Room room;
        try {
          debugPrint('[createRoomSuccess] About to create Room from normalized data');
          debugPrint('[createRoomSuccess] Players data type: ${normalizedData['players'].runtimeType}');
          debugPrint('[createRoomSuccess] First player data: ${normalizedData['players'].isNotEmpty ? normalizedData['players'].first : 'No players'}');
          
          room = Room.fromJson(normalizedData);
          debugPrint('[createRoomSuccess] Room created: id=${room.id}, players=${room.players.length}, started=${room.hasGameStarted}');
        } catch (roomError) {
          debugPrint('[createRoomSuccess] Error creating Room object: $roomError');
          debugPrint('[createRoomSuccess] Normalized data that failed: $normalizedData');
          return;
        }
        
        // Deal initial racks if empty
        if (room.players.every((p) => p.rack.isEmpty)) {
          // Ensure letter distribution has tiles
          var ld = room.letterDistribution;
          debugPrint('[createRoomSuccess] Letter distribution tiles remaining: ${ld.tilesRemaining}');
          
          if (ld.tilesRemaining == 0) {
            debugPrint('[createRoomSuccess] Letter distribution is empty, initializing with Arabic tiles');
            ld = LetterDistribution.arabic();
            debugPrint('[createRoomSuccess] After initialization, tiles remaining: ${ld.tilesRemaining}');
          }
          
          final List<Player> players = room.players;
          final newPlayers = players.map((p) {
            final need = 7 - p.rack.length;
            debugPrint('[createRoomSuccess] Player ${p.nickname} needs $need tiles');
            final List<Tile> drawn = need > 0 ? ld.drawTiles(need) : <Tile>[];
            final owned = drawn.map((t) => t.copyWith(ownerId: p.id)).toList();
            debugPrint('[createRoomSuccess] Player ${p.nickname} received tiles: ${owned.map((t) => t.letter).join(', ')}');
            return p.updateRack([...p.rack, ...owned]);
          }).toList();
          room = room.copyWith(players: newPlayers, letterDistribution: ld);
          debugPrint('[createRoomSuccess] After dealing, letter distribution has ${ld.tilesRemaining} tiles remaining');
        }
        
        for (final p in room.players) {
          debugPrint('[createRoomSuccess] rack ${p.nickname} size=${p.rack.length}');
        }
        
        // Double-check context is still mounted before updating provider and navigating
        if (!context.mounted) {
          debugPrint('[createRoomSuccess] Context no longer mounted after processing, cannot navigate');
          return;
        }
        
        Provider.of<RoomDataProvider>(context, listen: false).updateRoom(room);
        Navigator.pushNamed(context, GameScreen.routeName);
        debugPrint('[createRoomSuccess] Successfully navigated to game screen');
      } catch (e) {
        debugPrint('[createRoomSuccess] Error creating room: $e');
        debugPrint('[createRoomSuccess] Stack trace: ${StackTrace.current}');
      }
    });
  }

  void joinRoomSuccessListener(BuildContext context) {
    _socketClient.on('joinRoomSuccess', (roomData) {
      try {
        // Check if context is still mounted before proceeding
        if (!context.mounted) {
          debugPrint('[joinRoomSuccess] Context no longer mounted, skipping room join');
          return;
        }
        
        debugPrint('[joinRoomSuccess] raw payload: ' + roomData.toString());
        var room = Room.fromJson(_normalizeRoom(roomData));
        debugPrint('[joinRoomSuccess] normalized: id=' + room.id +
            ', players=' + room.players.length.toString() +
            ', started=' + room.hasGameStarted.toString());
        // Ensure racks are dealt at join time if missing
        if (room.players.any((p) => p.rack.isEmpty)) {
          // Ensure letter distribution has tiles
          var ld = room.letterDistribution;
          debugPrint('[joinRoomSuccess] Letter distribution tiles remaining: ${ld.tilesRemaining}');
          
          if (ld.tilesRemaining == 0) {
            debugPrint('[joinRoomSuccess] Letter distribution is empty, initializing with Arabic tiles');
            ld = LetterDistribution.arabic();
            debugPrint('[joinRoomSuccess] After initialization, tiles remaining: ${ld.tilesRemaining}');
          }
          
          final List<Player> players = room.players;
          final newPlayers = players.map((p) {
            final need = 7 - p.rack.length;
            debugPrint('[joinRoomSuccess] Player ${p.nickname} needs $need tiles');
            final List<Tile> drawn = need > 0 ? ld.drawTiles(need) : <Tile>[];
            final owned = drawn.map((t) => t.copyWith(ownerId: p.id)).toList();
            debugPrint('[joinRoomSuccess] Player ${p.nickname} received tiles: ${owned.map((t) => t.letter).join(', ')}');
            return p.updateRack([...p.rack, ...owned]);
          }).toList();
          room = room.copyWith(players: newPlayers, letterDistribution: ld);
          debugPrint('[joinRoomSuccess] After dealing, letter distribution has ${ld.tilesRemaining} tiles remaining');
        }
        for (final p in room.players) {
          debugPrint('[joinRoomSuccess] rack ${p.nickname} size=' + p.rack.length.toString());
        }
        
        // Double-check context is still mounted before updating provider and navigating
        if (!context.mounted) {
          debugPrint('[joinRoomSuccess] Context no longer mounted after processing, cannot navigate');
          return;
        }
        
        Provider.of<RoomDataProvider>(context, listen: false).updateRoom(room);
        Navigator.pushNamed(context, GameScreen.routeName);
        debugPrint('[joinRoomSuccess] Successfully navigated to game screen');
      } catch (e) {
        debugPrint('[joinRoomSuccess] Error joining room: $e');
      }
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
      
      // Extract error message from different possible formats
      String errorMessage = 'حدث خطأ';
      if (data is String) {
        errorMessage = data;
      } else if (data is Map) {
        errorMessage = data['message'] ?? data['error'] ?? data['msg'] ?? 'حدث خطأ غير معروف';
      }
      
      debugPrint('[socket errorOccurred] parsed error: $errorMessage');
      
      // Check if context is still mounted before showing snackbar
      if (context.mounted) {
        showSnackBar(context, errorMessage);
      }
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
      // Check if context is still mounted before accessing Provider
      if (!context.mounted) {
        debugPrint('[updateRoomListener] Context no longer mounted, skipping update');
        return;
      }
      
      try {
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
          final incomingHasTiles = incoming.board.getAllTiles().isNotEmpty;
          final boardToUse = incomingHasTiles ? incoming.board : current.board;
          incoming = incoming.copyWith(
            board: boardToUse, // don't wipe board if server sent empty grid
            letterDistribution: current.letterDistribution,
            players: mergedPlayers,
          );
          // If any rack still empty, deal from local bag
          if (incoming.players.any((p) => p.rack.isEmpty)) {
            // Ensure letter distribution has tiles
            var ld = incoming.letterDistribution;
            debugPrint('[updateRoomListener] Letter distribution tiles remaining: ${ld.tilesRemaining}');
            
            if (ld.tilesRemaining == 0) {
              debugPrint('[updateRoomListener] Letter distribution is empty, initializing with Arabic tiles');
              ld = LetterDistribution.arabic();
              debugPrint('[updateRoomListener] After initialization, tiles remaining: ${ld.tilesRemaining}');
            }
            
            final dealt = incoming.players.map((p) {
              if (p.rack.isEmpty) {
                final need = 7;
                debugPrint('[updateRoomListener] Dealing $need tiles to player ${p.nickname}');
                final drawn = ld.drawTiles(need);
                final owned = drawn.map((t) => t.copyWith(ownerId: p.id)).toList();
                debugPrint('[updateRoomListener] Player ${p.nickname} now has ${owned.length} tiles: ${owned.map((t) => t.letter).join(', ')}');
                return p.updateRack(owned);
              }
              debugPrint('[updateRoomListener] Player ${p.nickname} already has ${p.rack.length} tiles');
              return p;
            }).toList();
            
            incoming = incoming.copyWith(players: dealt, letterDistribution: ld);
            debugPrint('[updateRoomListener] After dealing, letter distribution has ${ld.tilesRemaining} tiles remaining');
          }
          for (final p in incoming.players) {
            debugPrint('[updateRoom merge] rack ${p.nickname} size=' + p.rack.length.toString());
          }
        }
        provider.updateRoom(incoming);
      } catch (e) {
        debugPrint('[updateRoomListener] Error updating room: $e');
      }
    });
  }

  /// Mirrors opponent hover previews in the local UI
  void hoverUpdateListener(BuildContext context) {
    _socketClient.on('hoverUpdate', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
          debugPrint('[hoverUpdateListener] Context no longer mounted, skipping hover update');
          return;
        }
        
        final socketId = data['socketId'] as String?;
        final hover = data['hover'] as Map?;
        if (socketId != null && hover != null) {
          final letter = (hover['letter'] ?? '') as String;
          final row = (hover['row'] ?? -1) as int;
          final col = (hover['col'] ?? -1) as int;
          Provider.of<RoomDataProvider>(context, listen: false)
              .updateRemoteHover(socketId: socketId, letter: letter, row: row, col: col);
        }
      } catch (e) {
        debugPrint('[hoverUpdateListener] Error updating hover: $e');
      }
    });

    _socketClient.on('hoverCleared', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
          debugPrint('[hoverClearedListener] Context no longer mounted, skipping hover clear');
          return;
        }
        
        final socketId = (data is Map) ? data['socketId'] as String? : data as String?;
        if (socketId != null) {
          Provider.of<RoomDataProvider>(context, listen: false)
              .clearRemoteHover(socketId);
        }
      } catch (e) {
        debugPrint('[hoverClearedListener] Error clearing hover: $e');
      }
    });
  }

  /// Listens for tiles placed on the server and updates the full room state
  void tilesPlacedListener(BuildContext context) {
    _socketClient.on('tilesPlaced', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
          debugPrint('[tilesPlacedListener] Context no longer mounted, skipping tiles placed update');
          return;
        }
        
        var incoming = Room.fromJson(_normalizeRoom(data['room']));
        final provider = Provider.of<RoomDataProvider>(context, listen: false);
        final current = provider.room;
        if (current != null) {
          // For tilesPlaced, we accept the complete board state from the server
          // but we need to ensure player racks are properly updated
          final incomingHasTiles = incoming.board.getAllTiles().isNotEmpty;
          
          if (incomingHasTiles) {
            // Get the current player's socket ID to identify which player's rack to update
            final mySocketId = _socketClient.id;
            final currentPlayer = current.players.firstWhere(
              (p) => p.socketId == mySocketId,
              orElse: () => current.players.first,
            );
            
            // Calculate how many tiles were placed by comparing board states
            final currentBoardTiles = current.board.getAllTiles();
            final incomingBoardTiles = incoming.board.getAllTiles();
            final tilesAdded = incomingBoardTiles.length - currentBoardTiles.length;
            
            debugPrint('[tilesPlacedListener] Board tiles: ${currentBoardTiles.length} -> ${incomingBoardTiles.length} (+$tilesAdded)');
            debugPrint('[tilesPlacedListener] Current player rack: ${currentPlayer.rack.length} tiles');
            
            if (tilesAdded > 0) {
              // Remove the placed tiles from the current player's rack
              final updatedPlayers = current.players.map((p) {
                if (p.id == currentPlayer.id) {
                  // Remove tiles from rack based on how many were placed
                  final newRack = p.rack.take(p.rack.length - tilesAdded).toList();
                  debugPrint('[tilesPlacedListener] Updated player ${p.nickname} rack: ${p.rack.length} -> ${newRack.length}');
                  return p.updateRack(newRack);
                }
                return p;
              }).toList();
              
              // Update the room with the new board and updated player racks
              incoming = incoming.copyWith(
                board: incoming.board,
                letterDistribution: current.letterDistribution,
                players: updatedPlayers,
              );
              
              debugPrint('[tilesPlacedListener] Updated board and player racks after tile placement');
            }
          }
        }
        provider.updateRoom(incoming);
      } catch (e) {
        debugPrint('[tilesPlacedListener] Error updating tiles placed: $e');
      }
    });
  }
  
  /// Listens for move submission and updates room/turn
  void moveSubmittedListener(BuildContext context) {
    _socketClient.on('moveSubmitted', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
          debugPrint('[moveSubmittedListener] Context no longer mounted, skipping move submitted update');
          return;
        }
        
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
          final incomingHasTiles = incoming.board.getAllTiles().isNotEmpty;
          final boardToUse = incomingHasTiles ? incoming.board : current.board;
          incoming = incoming.copyWith(
            board: boardToUse,
            letterDistribution: current.letterDistribution,
            players: mergedPlayers,
          );
        }
        provider.updateRoom(incoming);
      } catch (e) {
        debugPrint('[moveSubmittedListener] Error updating move submitted: $e');
      }
    });
  }
  
  /// Listens for turn pass and updates room/turn
  void turnPassedListener(BuildContext context) {
    _socketClient.on('turnPassed', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
          debugPrint('[turnPassedListener] Context no longer mounted, skipping turn passed update');
          return;
        }
        
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
          final incomingHasTiles = incoming.board.getAllTiles().isNotEmpty;
          final boardToUse = incomingHasTiles ? incoming.board : current.board;
          incoming = incoming.copyWith(
            board: boardToUse,
            letterDistribution: current.letterDistribution,
            players: mergedPlayers,
          );
        }
        provider.updateRoom(incoming);
      } catch (e) {
        debugPrint('[turnPassedListener] Error updating turn passed: $e');
      }
    });
  }
  
  /// Listens for tile exchanges and updates room state
  void tilesExchangedListener(BuildContext context) {
    _socketClient.on('tilesExchanged', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
          debugPrint('[tilesExchangedListener] Context no longer mounted, skipping tiles exchanged update');
          return;
        }
        
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
      } catch (e) {
        debugPrint('[tilesExchangedListener] Error updating tiles exchanged: $e');
      }
    });
  }
  
  /// Listens for game over events
  void gameOverListener(BuildContext context) {
    _socketClient.on('gameOver', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
          debugPrint('[gameOverListener] Context no longer mounted, skipping game over update');
          return;
        }
        
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
          incoming = incoming.copyWith(
            board: incoming.board,
            letterDistribution: current.letterDistribution,
            players: mergedPlayers,
          );
        }
        provider.updateRoom(incoming);
      } catch (e) {
        debugPrint('[gameOverListener] Error updating game over: $e');
      }
    });
  }

  /// Listens for board reset events (new game)
  void boardResetListener(BuildContext context) {
    _socketClient.on('boardReset', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
          debugPrint('[boardResetListener] Context no longer mounted, skipping board reset update');
          return;
        }
        
        debugPrint('[boardResetListener] Board reset event received: $data');
        
        // Reset the local room state to start fresh
        final provider = Provider.of<RoomDataProvider>(context, listen: false);
        final current = provider.room;
        if (current != null) {
          // Create a fresh room with empty board and reset scores
          final resetPlayers = current.players.map((p) => p.copyWith(
            score: 0,
            rack: <Tile>[],
          )).toList();
          
          final resetRoom = current.copyWith(
            board: Board.empty(size: 15),
            players: resetPlayers,
            letterDistribution: LetterDistribution.arabic(),
            moveHistory: <Move>[],
            hasGameStarted: false,
            hasGameEnded: false,
          );
          
          provider.updateRoom(resetRoom);
          debugPrint('[boardResetListener] Board reset completed, starting fresh game');
        }
      } catch (e) {
        debugPrint('[boardResetListener] Error resetting board: $e');
      }
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
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
          debugPrint('[turnChangedListener] Context no longer mounted, skipping turn changed update');
          return;
        }
        
        final roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
        final currentPlayerId = data['currentPlayerId'] as String;
        roomDataProvider.setCurrentPlayer(currentPlayerId);
      } catch (e) {
        debugPrint('[turnChangedListener] Error updating turn changed: $e');
      }
    });
  }

  /// Removes all socket listeners to prevent memory leaks
  void removeAllListeners() {
    _socketClient.off('updateRoom');
    _socketClient.off('hoverUpdate');
    _socketClient.off('hoverCleared');
    _socketClient.off('tilesPlaced');
    _socketClient.off('moveSubmitted');
    _socketClient.off('turnPassed');
    _socketClient.off('tilesExchanged');
    _socketClient.off('gameOver');
    _socketClient.off('boardReset');
    _socketClient.off('turnChanged');
    _socketClient.off('errorOccurred');
    _socketClient.off('updatePlayers');
    _socketClient.off('roomsList');
    _socketClient.off('roomsUpdated');
    _socketClient.off('lobbyReadyUpdate');
    _socketClient.off('createRoomSuccess');
    _socketClient.off('joinRoomSuccess');
    debugPrint('[SocketMethods] All listeners removed');
  }
}

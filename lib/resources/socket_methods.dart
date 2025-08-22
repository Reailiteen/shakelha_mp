
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

  /// Validates if a room ID matches the server's expected format
  /// Server regex: /^[a-zA-Z0-9]{6}$/
  static bool isValidRoomId(String roomId) {
    return RegExp(r'^[a-zA-Z0-9]{6}$').hasMatch(roomId);
  }

  /// Gets a human-readable error message for invalid room IDs
  static String getRoomIdValidationError(String roomId) {
    if (roomId.isEmpty) {
      return 'Room ID cannot be empty';
    }
    if (roomId.length != 6) {
      return 'Room ID must be exactly 6 characters long (current: ${roomId.length})';
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(roomId)) {
      return 'Room ID can only contain letters and numbers (no special characters)';
    }
    return 'Invalid room ID format';
  }

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
      _socketClient.emit('createRoom', payload);
    }
  }

  /// Joins an existing game room
  void joinRoom(String nickname, String roomId) async {
    if (nickname.isEmpty || roomId.isEmpty) {
      return;
    }
    
    // Validate room ID format to match server regex: /^[a-zA-Z0-9]{6}$/
    if (!isValidRoomId(roomId)) {
      final errorMsg = getRoomIdValidationError(roomId);
      // Emit a local error event that the UI can listen to
      _socketClient.emit('localError', {
        'type': 'validation',
        'message': errorMsg,
        'details': 'Room ID must be exactly 6 alphanumeric characters (e.g., ABC123, abc123, 123ABC)'
      });
      return;
    }
    
    // Wait a bit for socket to be ready if not connected
    if (!_socketClient.connected) {
      int attempts = 0;
      while (!_socketClient.connected && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
      
      if (!_socketClient.connected) {
        return;
      }
    }
    
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
    _socketClient.emit('passTurn', {
      'roomId': roomId,
    });
  }
  
  /// Submits the current move (optionally with placedTiles payload)
  void submitMove(String roomId, {List<Map<String, dynamic>>? placedTiles}) {
    final payload = <String, dynamic>{
      'roomId': roomId,
      'socketId': _socketClient.id, // Add socketId as server expects it
    };
    if (placedTiles != null) {
      // Ensure proper serialization for server compatibility
      final serializedTiles = placedTiles.map((tileData) {
        // Ensure position and tile are properly serialized
        final position = tileData['position'] as Map<String, dynamic>;
        final tile = tileData['tile'] as Map<String, dynamic>;
        
        return {
          'position': {
            'row': position['row'] as int,
            'col': position['col'] as int,
          },
          'tile': {
            'letter': tile['letter'] as String,
            'points': tile['points'] as int,
          },
        };
      }).toList();
      
      payload['placedTiles'] = serializedTiles;
      
      debugPrint('[submitMove] Sending move to server: roomId=$roomId, tiles=${placedTiles.length}');
    }
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
        
        // Map server fields to client fields - handle different field names
        final playerId = (playerMap['_id'] ?? playerMap['id'] ?? playerMap['socketID'] ?? '').toString();
        final socketId = (playerMap['socketID'] ?? playerMap['socketId'] ?? playerId).toString();
        final nickname = (playerMap['nickname'] ?? 'Player').toString();
        
        return {
          'id': playerId,
          'nickname': nickname,
          'socketId': socketId,
          'score': playerMap['points'] ?? playerMap['score'] ?? 0,
          'type': 'human',
          'rack': playerMap['currentLetters'] ?? playerMap['rack'] ?? playerMap['tiles'] ?? <dynamic>[],
          'moves': playerMap['moves'] ?? <dynamic>[],
          'isCurrentTurn': false,
          'hasPassed': false,
          'hasExchanged': false,
        };
      }).toList();
      
      // Handle different turn field formats from server
      int currentIdx = 0;
      String createdBy = '';
      
      if (map.containsKey('turnIndex')) {
        currentIdx = map['turnIndex'] as int? ?? 0;
      } else if (map.containsKey('turn')) {
        final turnData = map['turn'] as Map?;
        if (turnData != null) {
          // Try different field names the server might use
          final turnPlayerId = turnData['_id'] ?? turnData['id'] ?? turnData['socketID'] ?? turnData['socketId'] ?? '';
          currentIdx = players.indexWhere((p) => p['id'] == turnPlayerId);
          if (currentIdx == -1) {
            currentIdx = 0;
          }
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
       
       debugPrint('[updateRoomListener] 🔍 Status: $status, hasGameStarted: $hasGameStarted, board exists: ${map['board'] != null}');
       
       if (map['board'] != null) {
        // Game is in progress, preserve the board
        final boardData = map['board'] as Map<String, dynamic>;
        
                 // Handle different board field names from server
         final size = boardData['size'] ?? boardData['boardSize'] as int? ?? 15;
         final gridData = boardData['board'] ?? boardData['grid'] as List? ?? [];
         
         // Debug the board data structure
         debugPrint('[updateRoomListener] 🔍 Board data: size=$size, gridData length=${gridData.length}');
         debugPrint('[updateRoomListener] 🔍 Raw gridData: $gridData');
        
        final grid = List.generate(size, (r) {
          if (r >= gridData.length) {
            return List.filled(size, null);
          }
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
         
         // Count actual tiles found in the grid
         int tileCount = 0;
         for (int r = 0; r < size; r++) {
           for (int c = 0; c < size; c++) {
             if (grid[r][c] != null) tileCount++;
           }
         }
         debugPrint('[updateRoomListener] 🔍 Found $tileCount tiles in grid');
         
         normalizedBoard = Board(size: size, grid: grid, cellMultipliers: Board.empty(size: size).cellMultipliers);
       } else {
         // New game or room not started, use empty board
         normalizedBoard = Board.empty(size: 15);
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
      
      return normalized;
    } catch (e, stackTrace) {
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
          return;
        }
        
        // Normalize the room data
        Map<String, dynamic> normalizedData;
        try {
          normalizedData = _normalizeRoom(roomData);
        } catch (normalizeError) {
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
          room = Room.fromJson(normalizedData);
        } catch (roomError) {
          return;
        }
        
        // Deal initial racks if empty
        if (room.players.every((p) => p.rack.isEmpty)) {
          // Ensure letter distribution has tiles
          var ld = room.letterDistribution;
          
          if (ld.tilesRemaining == 0) {
            ld = LetterDistribution.arabic();
          }
          
          final List<Player> players = room.players;
          final newPlayers = players.map((p) {
            final need = 7 - p.rack.length;
            final List<Tile> drawn = need > 0 ? ld.drawTiles(need) : <Tile>[];
            final owned = drawn.map((t) => t.copyWith(ownerId: p.id)).toList();
            return p.updateRack([...p.rack, ...owned]);
          }).toList();
          room = room.copyWith(players: newPlayers, letterDistribution: ld);
        }
        
        // Double-check context is still mounted before updating provider and navigating
        if (!context.mounted) {
          return;
        }
        
        Provider.of<RoomDataProvider>(context, listen: false).updateRoom(room);
        Navigator.pushNamed(context, GameScreen.routeName);
      } catch (e) {
        // Handle error silently
      }
    });
  }

  void joinRoomSuccessListener(BuildContext context) {
    _socketClient.on('joinRoomSuccess', (roomData) {
      try {
        // Check if context is still mounted before proceeding
        if (!context.mounted) {
          return;
        }
        
        var room = Room.fromJson(_normalizeRoom(roomData));
        
        // Ensure racks are dealt at join time if missing
        if (room.players.any((p) => p.rack.isEmpty)) {
          // Ensure letter distribution has tiles
          var ld = room.letterDistribution;
          
          if (ld.tilesRemaining == 0) {
            ld = LetterDistribution.arabic();
          }
          
          final List<Player> players = room.players;
          final newPlayers = players.map((p) {
            final need = 7 - p.rack.length;
            final List<Tile> drawn = need > 0 ? ld.drawTiles(need) : <Tile>[];
            final owned = drawn.map((t) => t.copyWith(ownerId: p.id)).toList();
            return p.updateRack([...p.rack, ...owned]);
          }).toList();
          room = room.copyWith(players: newPlayers, letterDistribution: ld);
        }
        
        // Double-check context is still mounted before updating provider and navigating
        if (!context.mounted) {
          return;
        }
        
        Provider.of<RoomDataProvider>(context, listen: false).updateRoom(room);
        Navigator.pushNamed(context, GameScreen.routeName);
      } catch (e) {
        // Handle error silently
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
      // Extract error message from different possible formats
      String errorMessage = 'حدث خطأ';
      if (data is String) {
        errorMessage = data;
      } else if (data is Map) {
        errorMessage = data['message'] ?? data['error'] ?? data['msg'] ?? 'حدث خطأ غير معروف';
      }
      
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
        return;
      }
      
      try {
                 debugPrint('[updateRoomListener] 📡 Room update received, board tiles: ${(roomData['board'] as Map?)?['board']?.length ?? 0}');
        
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
            
            if (ld.tilesRemaining == 0) {
              ld = LetterDistribution.arabic();
            }
            
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
        }
        provider.updateRoom(incoming);
        
        debugPrint('[updateRoomListener] ✅ Room updated, final board tiles: ${incoming.board.getAllTiles().length}');
      } catch (e) {
        // Handle error silently
      }
    });
  }

  /// Mirrors opponent hover previews in the local UI
  void hoverUpdateListener(BuildContext context) {
    _socketClient.on('hoverUpdate', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
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
        // Handle error silently
      }
    });

    _socketClient.on('hoverCleared', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
          return;
        }
        
        final socketId = (data is Map) ? data['socketId'] as String? : data as String?;
        if (socketId != null) {
          Provider.of<RoomDataProvider>(context, listen: false)
              .clearRemoteHover(socketId);
        }
      } catch (e) {
        // Handle error silently
      }
    });
  }

  /// Listens for tiles placed on the server and updates the full room state
  void tilesPlacedListener(BuildContext context) {
    _socketClient.on('tilesPlaced', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
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
            
            if (tilesAdded > 0) {
              // Remove the placed tiles from the current player's rack
              final updatedPlayers = current.players.map((p) {
                if (p.id == currentPlayer.id) {
                  // Remove tiles from rack based on how many were placed
                  final newRack = p.rack.take(p.rack.length - tilesAdded).toList();
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
            }
          }
        }
        provider.updateRoom(incoming);
      } catch (e) {
        // Handle error silently
      }
    });
  }
  
  /// Listens for move submission and updates room/turn
  void moveSubmittedListener(BuildContext context) {
    _socketClient.on('moveSubmitted', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
          return;
        }
        
        debugPrint('[moveSubmittedListener] Received move submission response: $data');
        
        // Check if the data contains room information
        if (data is Map && data.containsKey('room')) {
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
            
            // Always use the incoming board for moveSubmitted to ensure proper sync
            final boardToUse = incoming.board;
            
            incoming = incoming.copyWith(
              board: boardToUse,
              letterDistribution: current.letterDistribution,
              players: mergedPlayers,
            );
          }
          
          provider.updateRoom(incoming);
        } else {
          // The server is only sending notification, not room data
          // We need to explicitly request the updated room state
          final provider = Provider.of<RoomDataProvider>(context, listen: false);
          final current = provider.room;
          if (current != null) {
            // Try multiple approaches to get room data
            _socketClient.emit('getRoomUpdate', {'roomId': current.id});
            _socketClient.emit('joinRoom', {'roomId': current.id, 'socketId': _socketClient.id});
            
            // Also try to parse any room data that might be in the notification
            if (data is Map && data.containsKey('roomId')) {
              final roomId = data['roomId'] as String;
              _socketClient.emit('getRoomUpdate', {'roomId': roomId});
            }
          }
        }
      } catch (e) {
        // Handle error silently
      }
    });
  }
  
  /// Listens for turn pass and updates room/turn
  void turnPassedListener(BuildContext context) {
    _socketClient.on('turnPassed', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
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
        // Handle error silently
      }
    });
  }
  
  /// Listens for tile exchanges and updates room state
  void tilesExchangedListener(BuildContext context) {
    _socketClient.on('tilesExchanged', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
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
        // Handle error silently
      }
    });
  }
  
  /// Listens for game over events
  void gameOverListener(BuildContext context) {
    _socketClient.on('gameOver', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
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
        // Handle error silently
      }
    });
  }

  /// Listens for board reset events (new game)
  void boardResetListener(BuildContext context) {
    _socketClient.on('boardReset', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
          return;
        }
        
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
        }
      } catch (e) {
        // Handle error silently
      }
    });
  }
  
  /// Listens for error messages
  void errorOccurredListener(BuildContext context) {
    _socketClient.on('errorOccurred', (data) {
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
          return;
        }
        
        final roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
        final currentPlayerId = data['currentPlayerId'] as String;
        roomDataProvider.setCurrentPlayer(currentPlayerId);
      } catch (e) {
        // Handle error silently
      }
    });
  }
  
  /// Listens for board updates specifically
  void boardUpdateListener(BuildContext context) {
    _socketClient.on('boardUpdate', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
          return;
        }
        
        if (data is Map && data.containsKey('room')) {
          var incoming = Room.fromJson(_normalizeRoom(data['room']));
          final provider = Provider.of<RoomDataProvider>(context, listen: false);
          final current = provider.room;
          
          if (current != null) {
            // Always use the incoming board for board updates
            incoming = incoming.copyWith(
              letterDistribution: current.letterDistribution,
              players: current.players, // Keep existing players
            );
            
            provider.updateRoom(incoming);
          }
        }
      } catch (e) {
        // Handle error silently
      }
    });
  }
  
  /// Listens for room update responses (fallback for when moveSubmitted doesn't include room data)
  void roomUpdateResponseListener(BuildContext context) {
    _socketClient.on('roomUpdateResponse', (data) {
      try {
        // Check if context is still mounted before accessing Provider
        if (!context.mounted) {
          return;
        }
        
        if (data is Map && data.containsKey('room')) {
          var incoming = Room.fromJson(_normalizeRoom(data['room']));
          final provider = Provider.of<RoomDataProvider>(context, listen: false);
          final current = provider.room;
          
          if (current != null) {
            // Use the incoming room data but preserve local letter distribution
            incoming = incoming.copyWith(
              letterDistribution: current.letterDistribution,
            );
            
            provider.updateRoom(incoming);
          }
        }
      } catch (e) {
        // Handle error silently
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
    _socketClient.off('boardUpdate');
    _socketClient.off('roomUpdateResponse');
    _socketClient.off('errorOccurred');
    _socketClient.off('updatePlayers');
    _socketClient.off('roomsList');
    _socketClient.off('roomsUpdated');
    _socketClient.off('lobbyReadyUpdate');
    _socketClient.off('createRoomSuccess');
    _socketClient.off('joinRoomSuccess');
  }
}

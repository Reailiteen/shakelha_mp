import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;
  
  // Connection management
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 2);
  
  // Connection quality tracking
  DateTime? _lastPongTime;
  int _missedHeartbeats = 0;
  static const int _maxMissedHeartbeats = 3;

  SocketClient._internal() {
    _initializeSocket();
  }

  void _initializeSocket() {
    socket = IO.io('https://overseas-ettie-deltaquest-6ad8d7e6.koyeb.app/', <String, dynamic>{
      'transports': <String>['websocket', 'polling'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': _maxReconnectAttempts,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'timeout': 20000, // Increased from 5000 to 20000ms (20 seconds)
      'forceNew': true,
      'upgrade': true,
      'rememberUpgrade': true,
      'maxReconnectionAttempts': _maxReconnectAttempts,
      'randomizationFactor': 0.5,
    });
    
    _setupEventListeners();
  }

  void _setupEventListeners() {
    socket!.onConnect((_) {
      print('[SocketClient] Connected to server');
      _isReconnecting = false;
      _reconnectAttempts = 0;
      _missedHeartbeats = 0;
      _startHeartbeat();
    });
    
    socket!.onDisconnect((_) {
      print('[SocketClient] Disconnected from server');
      _stopHeartbeat();
      _scheduleReconnect();
    });
    
    socket!.onConnectError((error) {
      print('[SocketClient] Connection error: $error');
      _handleConnectionError(error);
    });
    
    socket!.onError((error) {
      print('[SocketClient] Socket error: $error');
      _handleSocketError(error);
    });

    // Add heartbeat response listener
    socket!.on('pong', (data) {
      _lastPongTime = DateTime.now();
      _missedHeartbeats = 0;
      print('[SocketClient] Heartbeat response received');
    });

    // Add connection timeout listener
    socket!.on('connect_timeout', (data) {
      print('[SocketClient] Connection timeout - attempting reconnection');
      _handleConnectionTimeout();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (socket?.connected == true) {
        _sendHeartbeat();
      } else {
        timer.cancel();
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _sendHeartbeat() {
    if (socket?.connected == true) {
      socket!.emit('ping');
      _missedHeartbeats++;
      
      // Check if we're missing too many heartbeats
      if (_missedHeartbeats >= _maxMissedHeartbeats) {
        print('[SocketClient] Too many missed heartbeats - reconnecting');
        _forceReconnect();
      }
    }
  }

  void _scheduleReconnect() {
    if (_isReconnecting || _reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }
    
    _isReconnecting = true;
    _reconnectTimer?.cancel();
    
    // Exponential backoff with jitter
    final delay = _reconnectDelay * (1 << _reconnectAttempts);
    final jitter = Duration(milliseconds: (math.Random().nextDouble() * 1000).round());
    final totalDelay = delay + jitter;
    
    print('[SocketClient] Scheduling reconnection attempt ${_reconnectAttempts + 1} in ${totalDelay.inSeconds}s');
    
    _reconnectTimer = Timer(totalDelay, () {
      _attemptReconnect();
    });
  }

  void _attemptReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('[SocketClient] Max reconnection attempts reached');
      _isReconnecting = false;
      return;
    }
    
    _reconnectAttempts++;
    print('[SocketClient] Attempting reconnection ${_reconnectAttempts}/${_maxReconnectAttempts}');
    
    try {
      socket?.connect();
    } catch (e) {
      print('[SocketClient] Reconnection attempt failed: $e');
      _scheduleReconnect();
    }
  }

  void _forceReconnect() {
    print('[SocketClient] Force reconnecting...');
    socket?.disconnect();
    socket?.connect();
  }

  void _handleConnectionError(dynamic error) {
    print('[SocketClient] Handling connection error: $error');
    
    if (error is String && error.contains('timeout')) {
      _handleConnectionTimeout();
    } else {
      _scheduleReconnect();
    }
  }

  void _handleSocketError(dynamic error) {
    print('[SocketClient] Handling socket error: $error');
    _scheduleReconnect();
  }

  void _handleConnectionTimeout() {
    print('[SocketClient] Connection timeout detected');
    _missedHeartbeats++;
    
    if (_missedHeartbeats >= _maxMissedHeartbeats) {
      _forceReconnect();
    } else {
      _scheduleReconnect();
    }
  }

  /// Manually connect to the server
  void connect() {
    if (socket?.connected != true && !_isReconnecting) {
      print('[SocketClient] Manually connecting...');
      socket?.connect();
    }
  }

  /// Manually disconnect from the server
  void disconnect() {
    print('[SocketClient] Manually disconnecting...');
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _isReconnecting = false;
    socket?.disconnect();
  }

  /// Check if currently connected
  bool get isConnected => socket?.connected == true;

  /// Get connection quality (0-100)
  int get connectionQuality {
    if (!isConnected) return 0;
    if (_missedHeartbeats == 0) return 100;
    return math.max(0, 100 - (_missedHeartbeats * 25));
  }

  /// Force a reconnection (useful for network changes)
  void forceReconnect() {
    print('[SocketClient] Force reconnection requested');
    _forceReconnect();
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }

  /// Cleanup resources
  void dispose() {
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    socket?.disconnect();
    socket?.dispose();
  }
}

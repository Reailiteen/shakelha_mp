import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    socket = IO.io('https://overseas-ettie-deltaquest-6ad8d7e6.koyeb.app/', <String, dynamic>{
      'transports': <String>['websocket', 'polling'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 800,
      'timeout': 5000,
    });
    
    // Add connection status listeners
    socket!.onConnect((_) {
      print('[SocketClient] Connected to server');
    });
    
    socket!.onDisconnect((_) {
      print('[SocketClient] Disconnected from server');
    });
    
    socket!.onConnectError((error) {
      print('[SocketClient] Connection error: $error');
    });
    
    socket!.onError((error) {
      print('[SocketClient] Socket error: $error');
    });
    
    socket!.connect();
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}

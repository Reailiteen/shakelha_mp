import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shakelha_mp/provider/responsive_provider.dart';
import 'package:shakelha_mp/provider/room_data_provider.dart';
import 'package:shakelha_mp/provider/tile_theme_provider.dart';
import 'package:shakelha_mp/screens/splash_screen.dart';
import 'package:shakelha_mp/theme.dart';
import 'package:shakelha_mp/resources/socket_client.dart';
import 'dart:async';
import 'dart:io';
import 'package:shakelha_mp/screens/home_shell.dart';
import 'package:shakelha_mp/screens/main_menu_screen.dart';
import 'package:shakelha_mp/screens/join_room_screen.dart';
import 'package:shakelha_mp/screens/create_room_screen.dart';
import 'package:shakelha_mp/screens/game_screen.dart';
import 'package:shakelha_mp/screens/shop_screen.dart';
import 'package:shakelha_mp/screens/pass_play_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _networkCheckTimer;
  bool _lastNetworkAvailable = true;

  @override
  void initState() {
    super.initState();
    _setupNetworkMonitoring();
  }

  void _setupNetworkMonitoring() {
    // Check network connectivity every 30 seconds
    _networkCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkNetworkConnectivity();
    });
    
    // Initial check
    _checkNetworkConnectivity();
  }

  Future<void> _checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final isNetworkAvailable = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (isNetworkAvailable != _lastNetworkAvailable) {
        _lastNetworkAvailable = isNetworkAvailable;
        _handleNetworkChange(isNetworkAvailable);
      }
    } on SocketException catch (_) {
      if (_lastNetworkAvailable) {
        _lastNetworkAvailable = false;
        _handleNetworkChange(false);
      }
    } catch (e) {
      print('[MyApp] Error checking network connectivity: $e');
    }
  }

  void _handleNetworkChange(bool isAvailable) {
    print('[MyApp] Network availability changed: $isAvailable');
    
    if (isAvailable) {
      print('[MyApp] Network available - ensuring socket connection');
      _ensureSocketConnection();
    } else {
      print('[MyApp] No network available');
    }
  }

  void _ensureSocketConnection() {
    try {
      final socketClient = SocketClient.instance;
      if (!socketClient.isConnected) {
        print('[MyApp] Network restored - connecting socket');
        socketClient.connect();
      } else if (socketClient.connectionQuality < 50) {
        print('[MyApp] Poor connection quality - reconnecting socket');
        socketClient.forceReconnect();
      }
    } catch (e) {
      print('[MyApp] Error ensuring socket connection: $e');
    }
  }

  @override
  void dispose() {
    _networkCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RoomDataProvider()),
        ChangeNotifierProvider(create: (context) => ResponsiveProvider()),
        ChangeNotifierProvider(create: (context) => TileThemeProvider()),
      ],
      child: MaterialApp(
        title: 'شكّلها',
        theme: darkTheme,
        builder: (context, child) {
          // Force RTL across the whole app (Arabic-first UI)
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        routes: {
          SplashScreen.routeName: (context) => const SplashScreen(),
          HomeShell.routeName: (context) => const HomeShell(),
          MainMenuScreen.routeName: (context) => const MainMenuScreen(),
          JoinRoomScreen.routeName: (context) => const JoinRoomScreen(),
          CreateRoomScreen.routeName: (context) => const CreateRoomScreen(),
          GameScreen.routeName: (context) => const GameScreen(),
          ShopScreen.routeName: (context) => const ShopScreen(),
          PassPlayScreen.routeName: (context) => const PassPlayScreen(),
        },
        initialRoute: SplashScreen.routeName,
      ),
    );
  }
}

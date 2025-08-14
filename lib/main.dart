import 'package:flutter/material.dart';
import 'package:mp_tictactoe/provider/room_data_provider.dart';
import 'package:mp_tictactoe/screens/create_room_screen.dart';
import 'package:mp_tictactoe/screens/game_screen.dart';
import 'package:mp_tictactoe/screens/join_room_screen.dart';
import 'package:mp_tictactoe/screens/main_menu_screen.dart';
import 'package:mp_tictactoe/screens/splash_screen.dart';
import 'package:mp_tictactoe/screens/shop_screen.dart';
import 'package:mp_tictactoe/screens/home_shell.dart';
import 'package:mp_tictactoe/screens/pass_play_screen.dart';
import 'package:mp_tictactoe/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RoomDataProvider(),
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

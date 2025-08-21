import 'package:flutter/material.dart';
import 'package:shakelha_mp/provider/room_data_provider.dart';
import 'package:shakelha_mp/provider/responsive_provider.dart';
import 'package:shakelha_mp/provider/tile_theme_provider.dart';
import 'package:shakelha_mp/screens/create_room_screen.dart';
import 'package:shakelha_mp/screens/game_screen.dart';
import 'package:shakelha_mp/screens/join_room_screen.dart';
import 'package:shakelha_mp/screens/main_menu_screen.dart';
import 'package:shakelha_mp/screens/splash_screen.dart';
import 'package:shakelha_mp/screens/shop_screen.dart';
import 'package:shakelha_mp/screens/home_shell.dart';
import 'package:shakelha_mp/screens/pass_play_screen.dart';
import 'package:shakelha_mp/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

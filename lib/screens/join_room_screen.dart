import 'package:flutter/material.dart';
import 'package:shakelha_mp/resources/socket_methods.dart';
import 'package:shakelha_mp/responsive/responsive.dart';
import 'package:shakelha_mp/widgets/custom_button.dart';
import 'package:shakelha_mp/widgets/custom_text.dart';
import 'package:shakelha_mp/widgets/custom_textfield.dart';
import 'package:shakelha_mp/widgets/game_page.dart';

class JoinRoomScreen extends StatefulWidget {
  static String routeName = '/join-room';
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _gameIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final SocketMethods _socketMethods = SocketMethods();
  List<Map<String, dynamic>> _publicRooms = const [];
  bool _loadingRooms = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[JoinRoomScreen] Initializing...');
    _socketMethods.joinRoomSuccessListener(context);
    _socketMethods.errorOccuredListener(context);
    _socketMethods.updateRoomListener(context);
    // Lobby listeners
    _socketMethods.roomsListListener(context, (rooms) {
      if (!mounted) return;
      debugPrint('[JoinRoomScreen] Received ${rooms.length} public rooms');
      setState(() {
        _publicRooms = rooms;
        _loadingRooms = false;
      });
    });
    _socketMethods.roomsUpdatedListener(() {
      // re-fetch when server signals changes
      if (!mounted) return;
      debugPrint('[JoinRoomScreen] Rooms updated, re-fetching...');
      _fetchRooms();
    });
    _fetchRooms();
  }

  @override
  void dispose() {
    // Clean up socket listeners to prevent context errors
    _socketMethods.removeAllListeners();
    super.dispose();
    _gameIdController.dispose();
    _nameController.dispose();
  }

  void _fetchRooms() {
    setState(() => _loadingRooms = true);
    _socketMethods.listRooms(status: 'open', page: 1, pageSize: 50);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GamePageShell(
      title: 'الانضمام إلى غرفة',
      child: Responsive(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                shadows: [Shadow(blurRadius: 20, color: Colors.blue)],
                text: 'الغرف العامة',
                fontSize: 36,
              ),
              const SizedBox(height: 8),
              // Socket connection status indicator
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: _socketMethods.socketClient.connected 
                          ? Colors.green.withOpacity(0.2) 
                          : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _socketMethods.socketClient.connected ? Colors.green : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _socketMethods.socketClient.connected ? Icons.wifi : Icons.wifi_off,
                            color: _socketMethods.socketClient.connected ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _socketMethods.socketClient.connected 
                              ? 'متصل بالخادم' 
                              : 'غير متصل بالخادم',
                            style: TextStyle(
                              color: _socketMethods.socketClient.connected ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      debugPrint('[JoinRoomScreen] Manual refresh requested');
                      debugPrint('[JoinRoomScreen] Socket connected: ${_socketMethods.socketClient.connected}');
                      debugPrint('[JoinRoomScreen] Socket ID: ${_socketMethods.socketClient.id}');
                      _fetchRooms();
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: 'تحديث القائمة',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: size.height * 0.4,
                child: _loadingRooms
                    ? const Center(child: CircularProgressIndicator())
                    : _publicRooms.isEmpty
                        ? const Center(child: Text('لا توجد غرف عامة حالياً. أنشئ غرفة أو حدّث القائمة.'))
                        : ListView.separated(
                            itemCount: _publicRooms.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final r = _publicRooms[i];
                              // Handle both MongoDB ObjectId and regular string IDs
                              final id = (r['_id'] ?? r['id'] ?? '').toString();
                              final name = r['name'] as String? ?? 'غرفة';
                              final seats = r['seats'] as String? ?? '2';
                              final status = r['status'] as String? ?? 'open';
                              
                              debugPrint('[JoinRoomScreen] Room $i: id=$id, name=$name, seats=$seats, status=$status');
                              debugPrint('[JoinRoomScreen] Full room data: $r');
                              
                              return ListTile(
                                leading: const Icon(Icons.videogame_asset),
                                title: Text(name),
                                subtitle: Text('المعرف: $id    المقاعد: $seats    الحالة: $status'),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    if (_nameController.text.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('اكتب لقبك أولاً')),
                                      );
                                      return;
                                    }
                                    debugPrint('[JoinRoomScreen] Joining room: $id with nickname: ${_nameController.text}');
                                    debugPrint('[JoinRoomScreen] Room data being sent: {nickname: ${_nameController.text}, roomId: $id}');
                                    _socketMethods.joinRoom(_nameController.text, id);
                                  },
                                  child: const Text('انضمام'),
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const CustomText(
                shadows: [Shadow(blurRadius: 20, color: Colors.blue)],
                text: 'الانضمام بالمعرّف (خاصة/عامة)',
                fontSize: 28,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _nameController,
                      hintText: 'اكتب لقبك',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _gameIdController,
                      hintText: 'اكتب معرّف الغرفة',
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: CustomButton(
                      onTap: () {
                        debugPrint('[JoinRoomScreen] Manual join - Nickname: ${_nameController.text}, Room ID: ${_gameIdController.text}');
                        _socketMethods.joinRoom(
                          _nameController.text,
                          _gameIdController.text,
                        );
                      },
                      text: 'انضمام',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

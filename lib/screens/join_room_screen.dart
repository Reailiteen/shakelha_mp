import 'package:flutter/material.dart';
import 'package:mp_tictactoe/resources/socket_methods.dart';
import 'package:mp_tictactoe/responsive/responsive.dart';
import 'package:mp_tictactoe/widgets/custom_button.dart';
import 'package:mp_tictactoe/widgets/custom_text.dart';
import 'package:mp_tictactoe/widgets/custom_textfield.dart';

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
    _socketMethods.joinRoomSuccessListener(context);
    _socketMethods.errorOccuredListener(context);
    _socketMethods.updateRoomListener(context);
    // Lobby listeners
    _socketMethods.roomsListListener(context, (rooms) {
      if (!mounted) return;
      setState(() {
        _publicRooms = rooms;
        _loadingRooms = false;
      });
    });
    _socketMethods.roomsUpdatedListener(() {
      // re-fetch when server signals changes
      if (!mounted) return;
      _fetchRooms();
    });
    _fetchRooms();
  }

  @override
  void dispose() {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('الانضمام إلى غرفة'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: _fetchRooms,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Responsive(
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
                              final id = r['id'] as String;
                              final name = r['name'] as String;
                              final seats = r['seats'] as String;
                              final status = r['status'] as String;
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
                      onTap: () => _socketMethods.joinRoom(
                        _nameController.text,
                        _gameIdController.text,
                      ),
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

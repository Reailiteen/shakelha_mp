import 'package:flutter/material.dart';
import 'package:mp_tictactoe/resources/socket_methods.dart';
import 'package:mp_tictactoe/resources/socket_client.dart';
import 'package:mp_tictactoe/responsive/responsive.dart';
import 'package:mp_tictactoe/widgets/custom_button.dart';
import 'package:mp_tictactoe/widgets/custom_text.dart';
import 'package:mp_tictactoe/widgets/custom_textfield.dart';

class CreateRoomScreen extends StatefulWidget {
  static String routeName = '/create-room';
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController(text: 'غرفتي');
  final SocketMethods _socketMethods = SocketMethods();
  bool _creating = false;
  bool _isPublic = false;
  int _maxPlayers = 2;

  @override
  void initState() {
    super.initState();
    _socketMethods.createRoomSuccessListener(context);
    _socketMethods.errorOccuredListener(context);
    // Also toggle overlay off on success/error at the screen level
    final socket = SocketClient.instance.socket!;
    socket.on('createRoomSuccess', (_) {
      if (!mounted) return;
      setState(() => _creating = false);
    });
    socket.on('errorOccurred', (_) {
      if (!mounted) return;
      setState(() => _creating = false);
    });
  }

  @override
  void dispose() {
    // Unsubscribe local listeners
    final socket = SocketClient.instance.socket!;
    socket.off('createRoomSuccess');
    socket.off('errorOccurred');
    super.dispose();
    _nicknameController.dispose();
    _roomNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
      appBar: AppBar(title: const Text('إنشاء غرفة')),
      body: Responsive(
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CustomText(
                    shadows: [Shadow(blurRadius: 40, color: Colors.blue)],
                    text: 'إنشاء غرفة',
                    fontSize: 48,
                  ),
                  SizedBox(height: size.height * 0.08),
                  AbsorbPointer(
                    absorbing: _creating,
                    child: Opacity(
                      opacity: _creating ? 0.6 : 1,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _nicknameController,
                            hintText: 'اكتب لقبك',
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _roomNameController,
                            hintText: 'اسم الغرفة (اختياري)',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('إظهار الغرفة للعامة'),
                              Switch(
                                value: _isPublic,
                                onChanged: (v) => setState(() => _isPublic = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('عدد اللاعبين'),
                              const SizedBox(width: 12),
                              DropdownButton<int>(
                                value: _maxPlayers,
                                items: const [2, 3, 4]
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
                                    .toList(),
                                onChanged: (v) => setState(() => _maxPlayers = v ?? 2),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.045),
                          CustomButton(
                            onTap: () {
                              if (_creating) return;
                              if (_nicknameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('رجاءً اكتب لقبك')),
                                );
                                return;
                              }
                              setState(() => _creating = true);
                              // Fire create request
                              _socketMethods.createRoom(
                                _nicknameController.text.trim(),
                                isPublic: _isPublic,
                                name: _roomNameController.text.trim().isEmpty ? 'غرفة' : _roomNameController.text.trim(),
                                occupancy: _maxPlayers,
                              );
                              // Safety timeout: clear overlay if no server response
                              Future.delayed(const Duration(seconds: 10), () {
                                if (!mounted) return;
                                if (_creating) {
                                  setState(() => _creating = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('لا يوجد استجابة من الخادم. جرّب مرة أخرى.')),
                                  );
                                }
                              });
                            },
                            text: 'إنشاء',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_creating)
              Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Card(
                      elevation: 6,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('جارٍ إنشاء الغرفة...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

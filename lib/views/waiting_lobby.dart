import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mp_tictactoe/provider/room_data_provider.dart';
import 'package:mp_tictactoe/resources/socket_methods.dart';
import 'package:mp_tictactoe/widgets/game_page.dart';
import 'package:mp_tictactoe/widgets/topbar.dart';
import 'package:provider/provider.dart';

class WaitingLobby extends StatefulWidget {
  const WaitingLobby({Key? key}) : super(key: key);

  @override
  State<WaitingLobby> createState() => _WaitingLobbyState();
}

class _WaitingLobbyState extends State<WaitingLobby> {
  late TextEditingController roomIdController;
  final SocketMethods _socket = SocketMethods();

  @override
  void initState() {
    super.initState();
    final room = Provider.of<RoomDataProvider>(context, listen: false).room;
    roomIdController = TextEditingController(
      text: room?.id ?? '',
    );
  }

  @override
  void dispose() {
    super.dispose();
    roomIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = Provider.of<RoomDataProvider>(context).room;
    final players = room?.players ?? const [];
    final mySocketId = _socket.socketClient.id;
    final isHost = room != null && room.hostSocketId != null && room.hostSocketId == mySocketId;

    return GamePageShell(
      title: 'بإنتظار اللاعبين',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          final cardPadding = EdgeInsets.symmetric(
            horizontal: isWide ? 24 : 16,
            vertical: isWide ? 24 : 16,
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF512103).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFB16F15),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: const Color(0xFFB16F15).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: cardPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB16F15).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.hourglass_top, 
                              color: const Color(0xFFF7D286),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'بإنتظار اللاعبين...',
                              style: TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFF7D286),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Room ID section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D462D).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFB16F15).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'معرّف الغرفة', 
                                    style: TextStyle(
                                      color: const Color(0xFFF7D286).withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SelectableText(
                                    roomIdController.text.isEmpty ? '—' : roomIdController.text,
                                    style: const TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFF7D286),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFB16F15).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFB16F15).withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                tooltip: 'نسخ',
                                icon: Icon(
                                  Icons.copy_rounded,
                                  color: const Color(0xFFF7D286),
                                ),
                                onPressed: roomIdController.text.isEmpty
                                    ? null
                                    : () async {
                                        await Clipboard.setData(ClipboardData(text: roomIdController.text));
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('تم نسخ معرّف الغرفة'),
                                            backgroundColor: const Color(0xFF2D462D),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Players section
                      if (players.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D462D).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFB16F15).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اللاعبون', 
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFF7D286),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...players.map((p) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFB16F15).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            Icons.person_outline, 
                                            size: 16,
                                            color: const Color(0xFFF7D286),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            p.nickname,
                                            style: const TextStyle(
                                              color: const Color(0xFFF7D286),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // Controls section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D462D).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFB16F15).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'إظهار الغرفة للعامة',
                                      style: TextStyle(
                                        color: const Color(0xFFF7D286).withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Switch(
                                      value: room?.isPublic ?? false,
                                      onChanged: isHost
                                          ? (v) => _socket.setRoomVisibility(roomId: room.id, isPublic: v)
                                          : null,
                                      activeColor: const Color(0xFFB16F15),
                                      activeTrackColor: const Color(0xFFB16F15).withOpacity(0.3),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF137F83).withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: room == null ? null : () => _socket.readyUp(roomId: room.id),
                                    icon: const Icon(Icons.check_circle_outline),
                                    label: const Text('جاهز'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF137F83),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB16F15).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFB16F15).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'سيتم توزيع البلاطات بعد ضغط جميع اللاعبين على "جاهز"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFFF7D286).withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

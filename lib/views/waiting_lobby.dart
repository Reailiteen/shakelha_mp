import 'package:flutter/material.dart';
import 'package:mp_tictactoe/provider/room_data_provider.dart';
import 'package:mp_tictactoe/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class WaitingLobby extends StatefulWidget {
  const WaitingLobby({Key? key}) : super(key: key);

  @override
  State<WaitingLobby> createState() => _WaitingLobbyState();
}

class _WaitingLobbyState extends State<WaitingLobby> {
  late TextEditingController roomIdController;

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Waiting for a player to join...'),
        const SizedBox(height: 20),
        CustomTextField(
          controller: roomIdController,
          hintText: '',
          isReadOnly: true,
        ),
        if ((room?.players.length ?? 1) < 2)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Share Room ID with a friend to join'),
          ),
      ],
    );
  }
}

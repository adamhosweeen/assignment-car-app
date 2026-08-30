import 'package:flutter/material.dart';

import 'package:assignment/widgets/common/coming_soon.dart';

/// Chat is not built in v1 — a placeholder holds the tab (V1_SPEC §4.3).
/// The schema (`conversations`, `messages`) and the model/repository
/// skeletons under `model/chat/` and `control/chat/` are ready for it.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Chat',
      icon: Icons.chat_bubble_outline,
      message: 'Message sellers and make offers directly in the app.',
    );
  }
}

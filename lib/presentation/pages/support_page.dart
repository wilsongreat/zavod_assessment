import 'package:flutter/material.dart';
import 'package:zavod_assessment_app/presentation/components/bubble_message_widget.dart';

import '../../utils/app_colors.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),
      body:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: const [
                  MessageBubble(
                    message: 'Hello! How can I help you today?',
                    isMe: false,
                    time: '10:00',
                  ),
                  MessageBubble(
                    message: 'I have a question about the app',
                    isMe: true,
                    time: '10:01',
                  ),
                  MessageBubble(
                    message: 'Sure, I\'d be happy to assist you with any questions about our app!',
                    isMe: false,
                    time: '10:02',
                  ),
                ],
              ),
            ),
             TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                suffixIcon: Icon(Icons.send, color: AppColors.kbg,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

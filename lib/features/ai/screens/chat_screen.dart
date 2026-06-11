import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:mini_project/features/ai/services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatUser currentUser = ChatUser(id: '1', firstName: 'Charles');
  ChatUser aiUser = ChatUser(
    id: '0',
    firstName: 'Life AI',
    profileImage:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ1zAFvJ-v-Dup8m2A9LntMzId3ZtL31QOBgDZ5HXmE4w&s=10',
  );

  List<ChatMessage> messages = <ChatMessage>[];
  bool _aiTyping = false;

  Future<void> _sendMessage(ChatMessage userMessage) async {
    setState(() {
      messages.insert(0, userMessage);
      _aiTyping = true;
    });

    final responseText = await AiService.getResponse(
      question: userMessage.text,
    );

    final aiResponse = ChatMessage(
      text: responseText,
      user: aiUser,
      createdAt: DateTime.now(),
    );

    setState(() {
      messages.insert(0, aiResponse);
      _aiTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Life AI')),
      body: _buildChatUI(),
    );
  }

  Widget _buildChatUI() {
    return DashChat(
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
      typingUsers: _aiTyping ? [aiUser] : [],
      messageOptions: MessageOptions(
        messageTextBuilder: (message, previousMessage, nextMessage) {
          if (message.user.id == aiUser.id) {
            return MarkdownBody(data: message.text, selectable: true);
          }

          return Text(
            message.text,
            style: TextStyle(
              color: message.user.id == '0' ? Colors.black : Colors.white,
            ),
          );
        },
      ),
    );
  }
}

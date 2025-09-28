import 'package:fit_ai/providers/api_key_provider.dart';
import 'package:fit_ai/providers/plan_provider.dart';
import 'package:fit_ai/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatAssistantScreen extends ConsumerStatefulWidget {
  @override
  _ChatAssistantScreenState createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends ConsumerState<ChatAssistantScreen> {
  final _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final message = _controller.text;
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'message': message, 'isMe': true});
      _isLoading = true;
    });

    _controller.clear();

    try {
      // Get the API key from the provider.
      final apiKey = ref.read(apiKeyProvider).value;
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key not found. Please set it in the app settings.');
      }

      // Get response from AI service, passing the API key.
      final response = await ref.read(aiServiceProvider).getChatResponse(
            message: message,
            apiKey: apiKey,
          );

      setState(() {
        _messages.add({'message': response, 'isMe': false});
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'message': 'Error: ${e.toString()}',
          'isMe': false,
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Show latest messages at the bottom
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages.reversed.toList()[index];
                return ChatBubble(
                  message: msg['message'],
                  isMe: msg['isMe'],
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ask about fitness, nutrition...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
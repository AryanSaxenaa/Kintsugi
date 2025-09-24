import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'text': 'Welcome to Kintsugi! How can I help you with your washing machine today?'},
  ];

  void _sendMessage() {
    if (_queryController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': _queryController.text.trim()});
      String userMessage = _queryController.text.trim();
      _queryController.clear();
      
      // Simulate bot response
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _messages.add({'role': 'assistant', 'text': 'This is a demo response to: "$userMessage". In the full app, I would analyze your washing machine query and provide detailed diagnostic information.'});
        });
        _scrollToBottom();
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E), // Navy blue background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.local_laundry_service, color: Color(0xFF1A237E), size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'Kintsugi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Greeting section
          if (_messages.length <= 1)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Hi there!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How can I help you today? Pick one of the prompts below or ask me away.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Feature buttons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildFeatureButton(Icons.build, 'Diagnose Issue', () {})),
                            const SizedBox(width: 12),
                            Expanded(child: _buildFeatureButton(Icons.help_outline, 'Get Help', () {})),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildFeatureButton(Icons.settings, 'Settings Guide', () {})),
                            const SizedBox(width: 12),
                            Expanded(child: _buildFeatureButton(Icons.lightbulb_outline, 'Tips', () {})),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Chat messages
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                itemCount: _messages.length > 1 ? _messages.length - 1 : 0, // Skip welcome message when showing chat
                itemBuilder: (context, index) {
                  final message = _messages[index + 1]; // Skip welcome message
                  final isUser = message['role'] == 'user';
                  return _buildMessage(message['text']!, isUser);
                },
              ),
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Color(0xFF1A237E)),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _queryController,
                      decoration: const InputDecoration(
                        hintText: 'Ask me anything',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                      onChanged: (text) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _queryController.text.trim().isEmpty 
                        ? Colors.grey[300] 
                        : const Color(0xFF1A237E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _queryController.text.trim().isEmpty 
                          ? Colors.grey[600] 
                          : Colors.white,
                      size: 18,
                    ),
                    onPressed: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.mic, color: Color(0xFF1A237E)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(String text, bool isUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_laundry_service, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF1A237E) : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: Color(0xFF1A237E), size: 16),
            ),
          ],
        ],
      ),
    );
  }
}

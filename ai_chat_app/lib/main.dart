import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const String GEMINI_API_KEY = '';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat App (Gemini)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  Future<String> fetchGeminiResponse(String prompt) async {
    if (GEMINI_API_KEY.isEmpty || GEMINI_API_KEY == 'YOUR_ACTUAL_GEMINI_API_KEY_HERE') {
      return "❌ ไม่พบ Gemini API Key (กรุณาแทนที่ในโค้ด)";
    }

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: GEMINI_API_KEY);
      final String fullPrompt = "You are a helpful assistant. Be concise and friendly. Answer in Thai if user asks in Thai. User Query: $prompt";
      final response = await model.generateContent([Content.text(fullPrompt)]);
      return response.text ?? "❌ AI ไม่ได้ให้คำตอบ";
    } catch (e) {
      if (e.toString().contains('Invalid API key')) {
        return "🛑 ERROR: API Key ไม่ถูกต้องหรือหมดอายุ (โปรดตรวจสอบ Key ของคุณ)";
      }
      return "❌ Exception: ${e.toString()}";
    }
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
    
    final userMessage = ChatMessage(text: text, isUser: true);
    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    final reply = await fetchGeminiResponse(text);

    final aiMessage = ChatMessage(text: reply, isUser: false);
    setState(() {
      _messages.add(aiMessage);
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Gemini'),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, index) => _messages[_messages.length - 1 - index],
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 8),
                  Text('Gemini is thinking...'),
                ],
              ),
            ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message to Gemini',
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              child: Text(isUser ? 'You' : 'G'), // G for Gemini
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : 'Gemini',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

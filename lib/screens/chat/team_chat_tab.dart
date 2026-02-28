import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../models/message.dart';
import '../../services/team_chat_api.dart';

class TeamChatTab extends StatefulWidget {
  final String teamId;
  final String currentUserId;
  final bool isAllowedToChat;

  const TeamChatTab({
    super.key,
    required this.teamId,
    required this.currentUserId,
    required this.isAllowedToChat,
  });

  @override
  State<TeamChatTab> createState() => _TeamChatTabState();
}

class _TeamChatTabState extends State<TeamChatTab> {
  final List<ChatMessage> messages = [];
  final ScrollController _chatScroll = ScrollController();
  final TextEditingController _msgController = TextEditingController();

  StompClient? stompClient;
  bool _historyLoaded = false;

  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  @override
  void initState() {
    super.initState();

    if (!widget.isAllowedToChat) {
      return;
    }

    _loadChatHistory();
    _initWebSocket();
  }

  Future<void> _loadChatHistory() async {
    if (_historyLoaded) return;
    _historyLoaded = true;

    final list = await TeamChatApi.fetchMessages(widget.teamId);
    setState(() => messages.addAll(list));
    _scrollToBottom();
  }

  void _initWebSocket() async {
    if (stompClient != null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    stompClient = StompClient(
      config: StompConfig(
        url: "wss://teamup-backend-omi4.onrender.com/ws",
        stompConnectHeaders: {"Authorization": "Bearer $token"},
        webSocketConnectHeaders: {"Authorization": "Bearer $token"},

        onConnect: (frame) {
          stompClient!.subscribe(
            destination: "/topic/teams/${widget.teamId}/chat",
            callback: (StompFrame frame) {
              if (frame.body == null) return;

              final msg = ChatMessage.fromJson(jsonDecode(frame.body!));

              if (msg.createdAt == null) return;
              if (messages.any((m) => m.id == msg.id)) return;

              setState(() => messages.add(msg));
              _scrollToBottom();
            },
          );
        },

        onWebSocketError: (e) => print("WS ERROR: $e"),
      ),
    );

    stompClient!.activate();
  }

  @override
  void dispose() {
    stompClient?.deactivate();
    _chatScroll.dispose();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAllowedToChat) {
      return _buildLockedChatMessage();
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _chatScroll,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: messages.length,
            itemBuilder: (_, i) => _chatBubble(messages[i]),
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildLockedChatMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cardSurface,
                border: Border.all(color: _textSecondary.withOpacity(0.3)),
              ),
              child: Icon(Icons.lock_outline, size: 32, color: _textSecondary),
            ),
            const SizedBox(height: 20),
            const Text(
              "Chat Blocat",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Trebuie să faci parte din echipă pentru a accesa chat-ul.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatBubble(ChatMessage msg) {
    final bool isMe = msg.senderId == widget.currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: const BoxConstraints(maxWidth: 260),
            decoration: BoxDecoration(
              color: isMe ? _accentGreen : _cardSurface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 2),
                bottomRight: Radius.circular(isMe ? 2 : 16),
              ),
              border: isMe
                  ? null
                  : Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Text(
              msg.content,
              style: TextStyle(
                color: isMe ? Colors.black : Colors.white.withOpacity(0.9),
                fontSize: 15,
                fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
                height: 1.3,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
            child: Text(
              isMe ? "You" : msg.senderUsername,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _textSecondary.withOpacity(0.8),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? MediaQuery.of(context).viewInsets.bottom + 12
            : 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF091210),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _cardSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: TextField(
                controller: _msgController,
                style: const TextStyle(color: Colors.white),
                cursorColor: _accentGreen,
                decoration: InputDecoration(
                  hintText: "Scrie un mesaj...",
                  hintStyle: TextStyle(color: _textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _accentGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.black, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();

    stompClient?.send(
      destination: "/app/teams/${widget.teamId}/chat.send",
      body: jsonEncode({"content": text}),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }
}
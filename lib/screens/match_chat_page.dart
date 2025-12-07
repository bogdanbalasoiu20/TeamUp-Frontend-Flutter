import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../models/message.dart';
import '../services/match_chat_api.dart';

class MatchChatTab extends StatefulWidget {
  final String matchId;
  final String currentUserId;

  const MatchChatTab({
    super.key,
    required this.matchId,
    required this.currentUserId,
  });

  @override
  State<MatchChatTab> createState() => _MatchChatTabState();
}

class _MatchChatTabState extends State<MatchChatTab> {
  final List<ChatMessage> messages = [];
  final ScrollController _chatScroll = ScrollController();
  final TextEditingController _msgController = TextEditingController();

  StompClient? stompClient;
  bool _historyLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _initWebSocket();
  }

  // -----------------------------------------------------------
  // LOAD HISTORY (ONE TIME)
  // -----------------------------------------------------------
  Future<void> _loadChatHistory() async {
    if (_historyLoaded) return;
    _historyLoaded = true;

    final list = await MatchChatApi.fetchMessages(widget.matchId);
    setState(() => messages.addAll(list));
    _scrollToBottom();
  }

  // -----------------------------------------------------------
  // WEBSOCKET INIT
  // -----------------------------------------------------------
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
            destination: "/topic/matches/${widget.matchId}/chat",
            callback: (StompFrame frame) {
              if (frame.body == null) return;

              final json = jsonDecode(frame.body!);
              final msg = ChatMessage.fromJson(json);

              /// Duplicate protection (id-based)
              if (messages.any((m) => m.id == msg.id)) return;

              /// Only newly saved messages come with createdAt
              if (msg.createdAt == null) return;

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

  // -----------------------------------------------------------
  // UI
  // -----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _chatScroll,
            padding: const EdgeInsets.all(12),
            itemCount: messages.length,
            itemBuilder: (_, i) => _chatBubble(messages[i]),
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _chatBubble(ChatMessage msg) {
    final bool isMe = msg.senderId == widget.currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Text(
              msg.senderUsername,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF0A6F4A) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              msg.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              decoration: InputDecoration(
                hintText: "Write a message...",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          GestureDetector(
            onTap: _sendMessage,
            child: const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF0A6F4A),
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // SEND MESSAGE (WS ONLY!)
  // -----------------------------------------------------------
  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    FocusScope.of(context).unfocus();

    stompClient?.send(
      destination: "/app/matches/${widget.matchId}/chat.send",
      body: jsonEncode({"content": text}),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../models/message.dart';
import '../../services/match_chat_api.dart';

class MatchChatTab extends StatefulWidget {
  final String matchId;
  final String currentUserId;
  final bool isAllowedToChat;

  const MatchChatTab({
    super.key,
    required this.matchId,
    required this.currentUserId,
    required this.isAllowedToChat,
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

    /// dacă userul NU are voie la chat → nu inițializăm nimic
    if (!widget.isAllowedToChat) {
      print("### USER NOT ALLOWED TO CHAT → SKIP WS & HISTORY");
      return;
    }

    _loadChatHistory();
    _initWebSocket();
  }

  // -----------------------------------------------------------
  // LOAD HISTORY
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

  // -----------------------------------------------------------
  // UI ROOT
  // -----------------------------------------------------------
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
            padding: const EdgeInsets.all(12),
            itemCount: messages.length,
            itemBuilder: (_, i) => _chatBubble(messages[i]),
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  // -----------------------------------------------------------
  // LOCKED VIEW
  // -----------------------------------------------------------
  Widget _buildLockedChatMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: const Text(
            "Join the match to access the chat",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // CHAT BUBBLE
  // -----------------------------------------------------------
  Widget _chatBubble(ChatMessage msg) {
    final bool isMe = msg.senderId == widget.currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 2),
              child: Text(
                msg.senderUsername,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              gradient: isMe
                  ? const LinearGradient(
                colors: [
                  Color(0xFF0A6F4A),
                  Color(0xFF0E8C60),
                ],
              )
                  : const LinearGradient(
                colors: [
                  Colors.white10,
                  Colors.white24,
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            child: Text(
              msg.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // INPUT BAR
  // -----------------------------------------------------------
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Write a message...",
                      hintStyle: TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF18C77A),
                    child: Icon(Icons.send, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // SEND MESSAGE
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

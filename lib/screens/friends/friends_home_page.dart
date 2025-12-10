import 'package:flutter/material.dart';
import 'friend_search_page.dart';
import '../friends/friends_tab.dart';
import '../friends/incoming_requests_tab.dart';
import '../friends/outgoing_requests_tab.dart';

class FriendsHomePage extends StatelessWidget {
  const FriendsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Friends",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Friends"),
              Tab(text: "Search"),
              Tab(text: "Incoming"),
              Tab(text: "Outgoing"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FriendsTab(),
            FriendSearchPage(),
            IncomingRequestsTab(),
            OutgoingRequestsTab(),
          ],
        ),
      ),
    );
  }
}

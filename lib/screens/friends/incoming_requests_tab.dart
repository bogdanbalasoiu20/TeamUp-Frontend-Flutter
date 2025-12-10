import 'package:flutter/material.dart';
import '../../services/friend_api.dart';
import '../../models/friend_request.dart';

class IncomingRequestsTab extends StatefulWidget {
  const IncomingRequestsTab({super.key});

  @override
  State<IncomingRequestsTab> createState() => _IncomingRequestsTabState();
}

class _IncomingRequestsTabState extends State<IncomingRequestsTab> {
  List<FriendRequest> requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await FriendApi.getIncoming();

    setState(() {
      requests = List<FriendRequest>.from(r);
      loading = false;
    });
  }


  Future<void> _respond(String id, bool accept) async {
    await FriendApi.respond(id, accept);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (requests.isEmpty) {
      return const Center(child: Text("No incoming requests"));
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final r = requests[i];

        return Card(
          child: ListTile(
            title: Text(r.requesterUsername),
            subtitle: Text("Sent at: ${r.createdAt}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _respond(r.id, true),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _respond(r.id, false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

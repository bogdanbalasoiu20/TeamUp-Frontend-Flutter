import 'package:flutter/material.dart';
import '../../services/friend_api.dart';
import '../../models/friend_request.dart';

class OutgoingRequestsTab extends StatefulWidget {
  const OutgoingRequestsTab({super.key});

  @override
  State<OutgoingRequestsTab> createState() => _OutgoingRequestsTabState();
}

class _OutgoingRequestsTabState extends State<OutgoingRequestsTab> {
  List<FriendRequest> requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await FriendApi.getOutgoing();
    setState(() {
      requests = r.cast<FriendRequest>();
      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (requests.isEmpty) {
      return const Center(child: Text("No outgoing requests"));
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final r = requests[i];
        return Card(
          child: ListTile(
            title: Text(r.addresseeUsername),
            subtitle: const Text("Pending"),
          ),
        );
      },
    );
  }
}

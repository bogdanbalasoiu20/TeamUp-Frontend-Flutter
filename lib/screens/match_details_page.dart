import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/participant.dart';
import '../models/match_info.dart';
import 'package:team_up_fe_new/utils/action_button_animated.dart';
import 'package:team_up_fe_new/utils/top_banner.dart';

class MatchDetailsTab extends StatelessWidget {
  final MatchInfo? match;

  final String creatorId;
  final String? currentUserId;
  final Participant? me;

  final Future<void> Function() onLeaveMatch;
  final Future<void> Function() onCancelMatch;
  final Future<void> Function() onInvitePlayers;

  const MatchDetailsTab({
    super.key,
    required this.match,
    required this.creatorId,
    required this.currentUserId,
    required this.me,
    required this.onLeaveMatch,
    required this.onCancelMatch,
    required this.onInvitePlayers,
  });

  bool get isCreator => currentUserId == creatorId;

  @override
  Widget build(BuildContext context) {
    if (match == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildMatchDetailsCard(),
        const SizedBox(height: 25),

        _sectionTitle("Location"),
        _buildLocationMap(),
        const SizedBox(height: 35),

        _sectionTitle("Your Status"),
        if (me == null)
          const Text(
            "You are not part of this match.",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        if (me != null) _buildStatusCard(context),
        const SizedBox(height: 35),

        if (isCreator) _sectionTitle("Match Admin"),
        if (isCreator) _buildAdminCard(context),
      ],
    );
  }

  // ============================================================
  // MATCH DETAILS CARD
  // ============================================================
  Widget _buildMatchDetailsCard() {
    final m = match!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            m.title.isEmpty ? "Match Details" : m.title,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          _detailRow(Icons.place, m.venueName),
          _detailRow(Icons.map, m.venueAddress),
          _detailRow(Icons.schedule, "${m.startsAt.toLocal()}".replaceAll(".000", "")),
          _detailRow(Icons.timer, "${m.durationMinutes} minutes"),
          _detailRow(Icons.people, "${m.currentPlayers}/${m.maxPlayers} players"),
          _detailRow(Icons.payments, "${m.totalPrice.toStringAsFixed(2)} lei"),

          if (m.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              "Notes",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              m.notes,
              style: const TextStyle(fontSize: 15, color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAP
  // ============================================================
  Widget _buildLocationMap() {
    final m = match!;

    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30),
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(m.lat, m.lng),
          zoom: 15,
          interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.teamup.app.team_up_application",
            tileProvider: NetworkTileProvider(), // important
          ),

          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(m.lat, m.lng),
                width: 40,
                height: 40,
                builder: (_) => const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // USER STATUS CARD
  // ============================================================
  Widget _buildStatusCard(BuildContext context) {
    final isAccepted = me!.status == "ACCEPTED";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Status: ${me!.status}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          if (!isCreator && isAccepted)
            ActionButtonAnimated(
              colors: const [Color(0xFFA30000), Color(0xFFE53935)],
              text: "Leave Match",
              onTap: () async {
                await onLeaveMatch();
                showTopBanner(context, "You left the match");
              },
            ),

          if (!isCreator && !isAccepted)
            const Text(
              "You can leave only after your request is accepted.",
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // CREATOR ADMIN PANEL
  // ============================================================
  Widget _buildAdminCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActionButtonAnimated(
            colors: const [Colors.blue, Colors.lightBlueAccent],
            text: "Invite Players",
            onTap: () async {
              await onInvitePlayers();
              showTopBanner(context, "Invite menu opened");
            },
          ),

          const SizedBox(height: 16),

          ActionButtonAnimated(
            colors: const [Color(0xFF6A0000), Color(0xFFDA1E28)],
            text: "Cancel Match",
            onTap: () async {
              await onCancelMatch();
              showTopBanner(context, "Match canceled");
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

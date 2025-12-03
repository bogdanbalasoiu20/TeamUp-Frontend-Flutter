import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:team_up_fe_new/utils/data_formator.dart';

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

        if (match!.notes.isNotEmpty) ...[
          _sectionTitle("Notes"),
          _buildNotesCard(match!.notes),
          const SizedBox(height: 25),
        ],

        _sectionTitle("Location"),
        _buildLocationMap(),
        const SizedBox(height: 35),

        _sectionTitle("Your Status"),
        _buildStatusCard(),
        const SizedBox(height: 25),

        if (isCreator || me?.status == "ACCEPTED") ...[
          _sectionTitle("Actions"),
          _buildActionCard(context),
        ],
      ],
    );
  }

  // ============================================================
  // STATUS CARD (separat, doar text)
  // ============================================================
  Widget _buildStatusCard() {
    final bool userIsCreator = isCreator;
    final bool isAccepted = me?.status == "ACCEPTED";

    String statusText;

    if (userIsCreator) {
      statusText = "Match Admin";
    } else if (me == null) {
      statusText = "Not part of this match";
    } else if (isAccepted) {
      statusText = "Confirmed player";
    } else {
      statusText = me!.status;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // ACTION CARD (separat, doar butoane)
  // ============================================================
  Widget _buildActionCard(BuildContext context) {
    final bool userIsCreator = isCreator;
    final bool isAccepted = me?.status == "ACCEPTED";

    // CREATOR → Invite + Cancel Match
    if (userIsCreator) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            ActionButtonAnimated(
              colors: const [Colors.blue, Colors.lightBlueAccent],
              text: "Invite Players",
              onTap: () async {
                await onInvitePlayers();
                showTopBanner(context, "Invite menu opened");
              },
            ),
            const SizedBox(height: 14),
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

    // PLAYER ACCEPTED → Leave Match
    if (!userIsCreator && isAccepted) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: ActionButtonAnimated(
          colors: const [Color(0xFFA30000), Color(0xFFE53935)],
          text: "Leave Match",
          onTap: () async {
            await onLeaveMatch();
            showTopBanner(context, "You left the match");
          },
        ),
      );
    }

    // PLAYER NON-ACCEPTED
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: const Text(
        "You can leave only after your request is accepted.",
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  // ============================================================
  // LOCATION MAP
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
          interactiveFlags: InteractiveFlag.none,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.teamup.app",
            tileProvider: NetworkTileProvider(),
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
          _detailRow(
            Icons.schedule,
            formatMatchTime(m.startsAt, m.endsAt),
          ),
          _detailRow(Icons.timer, "${m.durationMinutes} minutes"),
          _detailRow(Icons.people, "${m.currentPlayers}/${m.maxPlayers} players"),
          _detailRow(Icons.payments, "${m.totalPrice.toStringAsFixed(2)} lei"),


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

  Widget _buildNotesCard(String notes) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        notes,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white70,
          height: 1.35,
        ),
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

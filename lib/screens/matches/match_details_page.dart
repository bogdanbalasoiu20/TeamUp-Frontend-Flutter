import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:team_up_fe_new/screens/matches/edit_match_page.dart';
import 'package:team_up_fe_new/utils/data_formator.dart';

import '../../models/participant.dart';
import '../../models/match_info.dart';
import 'package:team_up_fe_new/utils/action_button_animated.dart';
import 'package:team_up_fe_new/utils/top_banner.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchDetailsTab extends StatelessWidget {
  final MatchInfo? match;

  final String creatorId;
  final String? currentUserId;
  final Participant? me;

  final Future<void> Function() onLeaveMatch;
  final Future<void> Function() onCancelMatch;
  final Future<void> Function() onInvitePlayers;
  final Future<void> Function() onRefreshRequest;

  const MatchDetailsTab({
    super.key,
    required this.match,
    required this.creatorId,
    required this.currentUserId,
    required this.me,
    required this.onLeaveMatch,
    required this.onCancelMatch,
    required this.onInvitePlayers,
    required this.onRefreshRequest
  });

  bool get isCreator => currentUserId == creatorId;

  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  @override
  Widget build(BuildContext context) {
    if (match == null) {
      return Center(
        child: CircularProgressIndicator(color: _accentGreen),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      children: [
        _buildLocationSection(),
        const SizedBox(height: 32),

        _buildSectionLabel("Game Info"),
        const SizedBox(height: 8),
        _buildHeaderInfo(),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                Icons.timer_outlined,
                "${match!.durationMinutes} min",
                "Duration",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                Icons.people_outline,
                "${match!.currentPlayers}/${match!.maxPlayers}",
                "Players",
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _buildStatCard(
          Icons.attach_money,
          "${match!.totalPrice.toStringAsFixed(2)} RON",
          "Total Price",
          fullWidth: true,
        ),

        if (match!.joinDeadline != null) ...[
          const SizedBox(height: 32),
          _buildSectionLabel("Join Deadline"),
          const SizedBox(height: 8),
          _buildInfoContainer(
            icon: Icons.lock_clock_outlined,
            text: formatMatchTime(match!.joinDeadline!, null),
          ),
        ],

        if (match!.notes.isNotEmpty) ...[
          const SizedBox(height: 32),
          _buildSectionLabel("Notes & Instructions"),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Text(
              match!.notes,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],

        const SizedBox(height: 32),
        _buildSectionLabel("Your Status"),
        const SizedBox(height: 8),
        _buildStatusCard(),

        if (isCreator || me?.status == "ACCEPTED") ...[
          const SizedBox(height: 32),
          _buildSectionLabel("Actions"),
          const SizedBox(height: 8),
          _buildActionButtons(context),
          const SizedBox(height: 40),
        ],
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: _textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("Venue Location"),
        const SizedBox(height: 8),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _accentGreen, width: 2.5),
            color: _cardSurface,
            boxShadow: [
              BoxShadow(
                color: _accentGreen.withOpacity(0.25),
                blurRadius: 15,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21.5),
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(match!.lat, match!.lng),
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
                      point: LatLng(match!.lat, match!.lng),
                      width: 40,
                      height: 40,
                      builder: (_) => Icon(
                        Icons.location_on,
                        color: _accentGreen,
                        size: 40,
                        shadows: const [
                          Shadow(blurRadius: 10, color: Colors.black)
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.location_on, color: _accentGreen, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                match!.venueName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        GestureDetector(
          onTap: _openNavigation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _accentGreen,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _accentGreen.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Center(
              child: Text(
                "Take me there",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          match!.title.isEmpty ? "Match Details" : match!.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.calendar_month, size: 16, color: _textSecondary),
            const SizedBox(width: 8),
            Text(
              formatMatchTime(match!.startsAt, match!.endsAt),
              style: TextStyle(color: _textSecondary, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: fullWidth ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Icon(icon, color: _accentGreen.withOpacity(0.9), size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoContainer({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _textSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final bool userIsCreator = isCreator;
    final bool isAccepted = me?.status == "ACCEPTED";

    String statusText;
    Color statusColor = _accentGreen;
    IconData statusIcon = Icons.info_outline;

    if (userIsCreator) {
      statusText = "You are the Host";
      statusIcon = Icons.star;
    } else if (me == null) {
      statusText = "Not Joined";
      statusColor = _textSecondary;
      statusIcon = Icons.person_off;
    } else if (isAccepted) {
      statusText = "Confirmed Player";
      statusIcon = Icons.check_circle;
    } else {
      statusText = me!.status;
      statusColor = Colors.orange;
      statusIcon = Icons.access_time;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bool userIsCreator = isCreator;
    final bool isAccepted = me?.status == "ACCEPTED";

    if (userIsCreator) {
      return Column(
        children: [
          ActionButtonAnimated(
            colors: const [Color(0xFF1B4D3E), Color(0xFF2C6E58)],
            text: "Edit Match",
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditMatchPage(match: match!),
                ),
              );

              if (updated == true) {
                await onRefreshRequest();
              }
            },
          ),
          const SizedBox(height: 16),
          ActionButtonAnimated(
            // Red: Deep Burgundy
            colors: const [Color(0xFF59181B), Color(0xFF8C262B)],
            text: "Cancel Match",
            onTap: () async {
              await onCancelMatch();
              showTopBanner(context, "Match canceled");
            },
          ),
        ],
      );
    }

    if (isAccepted) {
      return ActionButtonAnimated(
        colors: const [Color(0xFF59181B), Color(0xFF8C262B)],
        text: "Leave Match",
        onTap: () async {
          await onLeaveMatch();
          showTopBanner(context, "You left the match");
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          "Wait for acceptance to leave.",
          style: TextStyle(color: _textSecondary),
        ),
      ),
    );
  }

  Future<void> _openNavigation() async {
    final lat = match!.lat;
    final lng = match!.lng;

    final uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}
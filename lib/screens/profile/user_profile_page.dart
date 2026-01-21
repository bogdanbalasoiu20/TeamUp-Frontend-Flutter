import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/screens/profile/edit_profile_page.dart';
import 'package:team_up_fe_new/widgets/friend_button.dart';
import 'package:team_up_fe_new/widgets/player_card/fifa_card.dart';
import 'package:team_up_fe_new/widgets/player_card/player_card_ui.dart';
import 'package:team_up_fe_new/widgets/stats_modal.dart';
import '../../models/user_profile.dart';
import '../../services/user_api.dart';
import '../../services/friend_api.dart';

class UserProfilePage extends StatefulWidget {
  final String username;

  const UserProfilePage({super.key, required this.username});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserProfile? profile;
  bool loading = true;
  bool isMyProfile = false;
  bool isFriend = false;
  bool pendingSent = false;
  bool pendingReceived = false;
  String? requestId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  int computeAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedUser = prefs.getString("username");
      isMyProfile = (widget.username == loggedUser);

      // 1) Load profile
      final res = await UserApi.fetchProfile(widget.username);

      setState(() {
        profile = res;
      });

      // 2) Load relationship status
      final relation = await FriendApi.relationStatus(widget.username);

      setState(() {
        loading = false;
        isFriend = relation["isFriend"];
        pendingSent = relation["pendingSent"];
        pendingReceived = relation["pendingReceived"];
        requestId = relation["requestId"];
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _sendRequest() async {
    await FriendApi.sendRequest(profile!.id);
    await _load();
  }

  Future<void> _respond(bool accept) async {
    if (requestId == null) return;
    await FriendApi.respond(requestId!, accept);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text("User not found")),
      );
    }

    final p = profile!;


    //Test card
    final testCard = PlayerCardUi(
      name: p.username,
      rating: 84,
      position: p.position ?? "CM",
      imageUrl: p.photoUrl ??
          "https://i.imgur.com/BoN9kdC.png",
      stats: const {
        "PAC": 85,
        "SHO": 80,
        "PAS": 86,
        "DRI": 83,
        "DEF": 72,
        "PHY": 78,
      },
    );


    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF003B2F),
            Color(0xFF0A6F4A),
            Color(0xFF062D24),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // ---------------- HEADER GLASS ----------------
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.1),
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),
          title: Text(
            p.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black45,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // ---------------- FIFA CARD (TEST MODE) ----------------
              Center(
                child: GestureDetector(
                  onTap: () => _openPlayerStatsModal(context),
                  child: Transform.scale(
                    scale: 0.75,
                    child: FifaPlayerCard(data: testCard),
                  ),
                ),
              ),



              const SizedBox(height: 20),

              // ---------------- BUTTON ----------------
              SizedBox(
                width: double.infinity,
                child: _buildFriendButton(p),
              ),

              const SizedBox(height: 30),

              // ---------------- USER INFO ----------------
              _sectionTitle("User Info"),

              const SizedBox(height: 14),

              if (p.birthday != null)
                _glassInfoTile(
                  Icons.cake,
                  "Age",
                  "${computeAge(p.birthday!)} years old",
                ),

              if (p.position != null)
                _glassInfoTile(Icons.sports_soccer, "Position", p.position!),

              if (p.city != null && p.city!.trim().isNotEmpty)
                _glassInfoTile(Icons.location_on, "City", p.city!),

              if (p.description != null)
                _glassInfoTile(Icons.description_outlined, "About me", p.description!),

              _glassInfoTile(
                Icons.calendar_today,
                "Joined",
                "${p.createdAt.year}-${p.createdAt.month}-${p.createdAt.day}",
              ),

              const SizedBox(height: 30),

              // ---------------- PRIVATE INFO ----------------
              if (isMyProfile) ...[
                _sectionTitle("Private Info"),
                const SizedBox(height: 14),

                if (p.email != null)
                  _glassInfoTile(Icons.email, "Email", p.email!),

                if (p.phoneNumber != null)
                  _glassInfoTile(Icons.phone, "Phone", p.phoneNumber!),

                const SizedBox(height: 30),
              ],

              // ---------------- PLACEHOLDERS ----------------
              _placeholder("User statistics (coming soon)"),


              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendButton(UserProfile p) {
    if (isMyProfile) {
      return FriendButton(
        text: "Edit Profile",
        icon: Icons.edit,
        colors: const [Color(0xFF0A6F4A), Color(0xFF46C264)],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditProfilePage(
                birthday: p.birthday,
                phone: p.phoneNumber,
                description: p.description,
                city: p.city,
                position: p.position,
              ),
            ),
          ).then((v) {
            if (v == true) _load();
          });
        },
      );

    }

    if (isFriend) {
      return FriendButton(
        text: "Unfriend",
        icon: Icons.person_remove,
        colors: const [Color(0xFFA30000), Color(0xFFE53935)],
        onTap: () async {
          await FriendApi.unfriend(p.id);
          await _load();
        },
      );

    }

    if (pendingSent) {
      return FriendButton(
        text: "Friend Request Sent",
        icon: Icons.hourglass_top,
        colors: const [Colors.grey, Colors.grey],
        disabled: true,
        onTap: null,
      );

    }

    if (pendingReceived) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Accept Friend Request?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FriendButton(
                text: "Accept",
                icon: Icons.check,
                colors: const [Color(0xFF0A6F4A), Color(0xFF46C264)],
                onTap: () => _respond(true),
              ),
              const SizedBox(width: 12),
              FriendButton(
                text: "Decline",
                icon: Icons.close,
                colors: const [Color(0xFFA30000), Color(0xFFE53935)],
                onTap: () => _respond(false),
              ),
            ],
          ),
        ],
      );
    }


    // NOT FRIEND → ADD FRIEND
    return FriendButton(
      text: "Add Friend",
      icon: Icons.person_add,
      colors: const [Color(0xFF0A6F4A), Color(0xFF46C264)],
      onTap: () async {
        await _sendRequest();
        await _load();
      },
    );

  }



  // ---------------- GLASS INFO TILE (UI unchanged) ----------------
  Widget _glassInfoTile(IconData icon, String title, String value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.85), size: 26),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _placeholder(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ),
      ),
    );
  }


  void _openPlayerStatsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0E1B16),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                child: const PlayerStatsModalContent(),
              ),
            );
          },
        );
      },
    );
  }

}

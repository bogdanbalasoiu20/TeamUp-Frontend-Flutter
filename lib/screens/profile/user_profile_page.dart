import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/screens/profile/edit_profile_page.dart';
import 'package:team_up_fe_new/widgets/player_card/fifa_card.dart';
import 'package:team_up_fe_new/widgets/player_card/player_card_ui.dart';
import 'package:team_up_fe_new/widgets/stats_modal.dart';
import '../../models/user_profile.dart';
import '../../services/user_api.dart';
import '../../services/friend_api.dart';
import '../../services/player_card_api.dart';
import '../../models/live_form.dart';
import '../../services/live_form_api.dart';
import '../../utils/live_form_state.dart';

class UserProfilePage extends StatefulWidget {
  final String username;

  const UserProfilePage({super.key, required this.username});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> with SingleTickerProviderStateMixin {
  UserProfile? profile;
  bool loading = true;
  bool isMyProfile = false;
  bool isFriend = false;
  bool pendingSent = false;
  bool pendingReceived = false;
  String? requestId;
  Future<PlayerCardUi>? _playerCardFuture;
  LiveForm? _liveForm;

  late AnimationController _pulseController;

  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);
  final Color _dangerRed = const Color(0xFFCF6679);

  @override
  void initState() {
    super.initState();
    _load();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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

      final res = await UserApi.fetchProfile(widget.username);

      LiveForm? form;
      try {
        form = await LiveFormApi.getLiveForm(res.id);
      } catch (e) {
        debugPrint("Could not load live form: $e");
      }

      setState(() {
        profile = res;
        _liveForm = form;
        _playerCardFuture = PlayerCardService.getPlayerCard(res.id);
      });

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
      return Scaffold(
        backgroundColor: _bgDark,
        body: Center(child: CircularProgressIndicator(color: _accentGreen)),
      );
    }

    if (profile == null) {
      return Scaffold(
        backgroundColor: _bgDark,
        body: const Center(child: Text("User not found", style: TextStyle(color: Colors.white))),
      );
    }

    final p = profile!;

    return Scaffold(
      backgroundColor: _bgDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "PROFILE",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0A6F4A).withOpacity(0.4),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 60, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () => _openPlayerStatsModal(context),
                    child: Transform.scale(
                      scale: 0.85,
                      child: SizedBox(
                        width: 260,
                        height: 380,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Hero(
                              tag: 'player_card_${p.id}',
                              child: FutureBuilder<PlayerCardUi>(
                                future: _playerCardFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return SizedBox(
                                        height: 380,
                                        child: Center(child: CircularProgressIndicator(color: _accentGreen))
                                    );
                                  }
                                  if (snapshot.hasError || !snapshot.hasData) {
                                    return const SizedBox(height: 380, child: Center(child: Text("Card Error", style: TextStyle(color: Colors.white))));
                                  }
                                  return FifaPlayerCard(data: snapshot.data!);
                                },
                              ),
                            ),

                            if (_liveForm != null)
                              Positioned(
                                top: 70,
                                left: -30,
                                child: _buildFormArrowBadge(),
                              ),

                            Positioned(
                              top: 20,
                              right: 15,
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: 0.8 + (_pulseController.value * 0.2),
                                    child: _buildTapHintPill(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _buildActionButtons(p),

                const SizedBox(height: 32),

                _buildSectionHeader("User Info"),
                const SizedBox(height: 12),

                if (p.birthday != null)
                  _buildModernInfoTile(Icons.cake, "Age", "${computeAge(p.birthday!)} years old"),
                if (p.position != null)
                  _buildModernInfoTile(Icons.sports_soccer, "Position", p.position!),
                if (p.city != null && p.city!.trim().isNotEmpty)
                  _buildModernInfoTile(Icons.location_on, "City", p.city!),
                if (p.description != null && p.description!.isNotEmpty)
                  _buildModernInfoTile(Icons.description_outlined, "About me", p.description!),

                _buildModernInfoTile(
                  Icons.calendar_today,
                  "Joined TeamUp",
                  "${p.createdAt.year}-${p.createdAt.month.toString().padLeft(2, '0')}-${p.createdAt.day.toString().padLeft(2, '0')}",
                ),

                const SizedBox(height: 32),

                if (isMyProfile) ...[
                  _buildSectionHeader("Private Details"),
                  const SizedBox(height: 12),
                  if (p.email != null)
                    _buildModernInfoTile(Icons.email, "Email", p.email!),
                  if (p.phoneNumber != null)
                    _buildModernInfoTile(Icons.phone, "Phone", p.phoneNumber!),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildModernInfoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _accentGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons(UserProfile p) {
    if (isMyProfile) {
      return _buildModernButton(
        text: "Edit Profile",
        icon: Icons.edit,
        bgColor: _accentGreen,
        textColor: Colors.black,
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
      return _buildModernButton(
        text: "Unfriend",
        icon: Icons.person_remove,
        bgColor: _cardSurface,
        textColor: _dangerRed,
        borderColor: _dangerRed.withOpacity(0.3),
        onTap: () async {
          await FriendApi.unfriend(p.id);
          await _load();
        },
      );
    }

    if (pendingSent) {
      return _buildModernButton(
        text: "Request Sent",
        icon: Icons.hourglass_top,
        bgColor: _cardSurface,
        textColor: _textSecondary,
        onTap: null,
      );
    }

    if (pendingReceived) {
      return Row(
        children: [
          Expanded(
            child: _buildModernButton(
              text: "Accept",
              icon: Icons.check,
              bgColor: _accentGreen,
              textColor: Colors.black,
              onTap: () => _respond(true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildModernButton(
              text: "Decline",
              icon: Icons.close,
              bgColor: _cardSurface,
              textColor: Colors.white,
              borderColor: Colors.white24,
              onTap: () => _respond(false),
            ),
          ),
        ],
      );
    }

    return _buildModernButton(
      text: "Add Friend",
      icon: Icons.person_add,
      bgColor: _accentGreen,
      textColor: Colors.black,
      onTap: () async {
        await _sendRequest();
        await _load();
      },
    );
  }

  Widget _buildModernButton({
    required String text,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: borderColor != null ? BorderSide(color: borderColor) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: _cardSurface,
          disabledForegroundColor: Colors.white30,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTapHintPill() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_outlined, color: _accentGreen, size: 14),
              const SizedBox(width: 6),
              const Text(
                "STATS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormArrowBadge() {
    if (_liveForm == null) return const SizedBox.shrink();

    final state = getLiveFormState(_liveForm!.delta);
    IconData icon;
    Color color;

    switch (state) {
      case LiveFormState.onFire:
        icon = Icons.arrow_upward_rounded;
        color = Colors.orangeAccent;
        break;
      case LiveFormState.good:
        icon = Icons.trending_up_rounded;
        color = _accentGreen;
        break;
      case LiveFormState.off:
      case LiveFormState.bad:
        icon = Icons.trending_down_rounded;
        color = _dangerRed;
        break;
      case LiveFormState.normal:
      default:
        icon = Icons.remove_rounded;
        color = Colors.grey;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Icon(icon, color: color, size: 26),
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
              child: PlayerStatsModalContent(
                userId: profile!.id,
              ),
            );
          },
        );
      },
    );
  }
}
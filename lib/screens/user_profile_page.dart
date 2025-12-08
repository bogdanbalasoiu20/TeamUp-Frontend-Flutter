import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_up_fe_new/screens/edit_profile_page.dart';
import '../models/user_profile.dart';
import '../services/user_api.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final loggedUser = prefs.getString("username");
    isMyProfile = (widget.username == loggedUser);

    try {
      final res = await UserApi.fetchProfile(widget.username);
      setState(() {
        profile = res;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
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

              // ---------------- PROFILE PHOTO ----------------
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 58,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    backgroundImage:
                    p.photoUrl != null ? NetworkImage(p.photoUrl!) : null,
                    child: p.photoUrl == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ---------------- NAME + POSITION ----------------
              Text(
                p.username,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              if (p.position != null) ...[
                const SizedBox(height: 6),
                Text(
                  p.position!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],

              if (p.city != null && p.city!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  p.city!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.75),
                  ),
                )
              ],

              const SizedBox(height: 20),

              // ---------------- BUTTON ----------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isMyProfile) {
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
                    } else {
                      print("Friend request logic");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF46C264),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    isMyProfile ? "Edit Profile" : "Add Friend",
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
              _placeholder("FIFA-style card (coming soon)"),
              const SizedBox(height: 16),
              _placeholder("User statistics (coming soon)"),
              const SizedBox(height: 16),
              _placeholder("Friends list (coming soon)"),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- GLASS INFO TILE ----------------
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
}

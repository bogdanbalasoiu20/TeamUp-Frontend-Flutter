import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedUser = prefs.getString("username");

      isMyProfile = (widget.username == loggedUser);

      final result = await UserApi.fetchProfile(widget.username);

      print("### PROFILE RAW = ${result.toJson()}");
      print("### isMyProfile FE = $isMyProfile");
      print("### loggedUser FE = $loggedUser");
      print("### requestedProfile = ${widget.username}");

      setState(() {
        profile = result;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);

      print("### PROFILE ERROR = $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error while loading profile")),
      );
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ---------- HEADER ----------
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    p.username,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // ---------- PROFILE PHOTO ----------
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade300,
                child: p.photoUrl == null
                    ? const Icon(Icons.person, size: 55, color: Colors.white)
                    : ClipOval(
                  child: Image.network(
                    p.photoUrl!,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ---------- USERNAME ----------
              Text(
                p.username,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 6),

              // ---------- POSITION ----------
              if (p.position != null)
                Text(
                  p.position!,
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey.shade700),
                ),

              // ---------- CITY ----------
              if (p.city != null) ...[
                const SizedBox(height: 8),
                Text(
                  p.city!,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],

              const SizedBox(height: 25),

              // ---------- ACTION BUTTON ----------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildActionButton(),
              ),

              const SizedBox(height: 35),

              // ---------- ABOUT / USER INFO ----------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "User Info",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (isMyProfile && p.email != null)
                      _infoTile(Icons.email, "Email", p.email!),

                    if (isMyProfile && p.phoneNumber != null)
                      _infoTile(Icons.phone, "Phone", p.phoneNumber!),

                    if (p.birthday != null)
                      _infoTile(Icons.cake, "Birthday",
                          "${p.birthday!.year}-${p.birthday!.month.toString().padLeft(2, '0')}-${p.birthday!.day.toString().padLeft(2, '0')}"),

                    if (p.city != null)
                      _infoTile(Icons.location_on, "City", p.city!),

                    if (p.position != null)
                      _infoTile(Icons.sports_soccer, "Position", p.position!),

                    if (p.rank != null)
                      _infoTile(Icons.star, "Rank", p.rank!),

                    _infoTile(
                      Icons.calendar_today,
                      "Joined",
                      "${p.createdAt.year}-${p.createdAt.month.toString().padLeft(2, '0')}-${p.createdAt.day.toString().padLeft(2, '0')}",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ---------- FUTURE FEATURES ----------
              _placeholder("Aici va fi cardul FIFA-style"),
              const SizedBox(height: 20),
              _placeholder("Aici vor apărea statisticile userului"),
              const SizedBox(height: 20),
              _placeholder("Aici va fi lista de prieteni"),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade700),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    )),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _placeholder(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (isMyProfile) {
            print("Edit my profile");
          } else {
            print("Friend request logic");
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E8B57),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          isMyProfile ? "Edit Profile" : "Add Friend",
          style: const TextStyle(fontSize: 17, color: Colors.white),
        ),
      ),
    );
  }
}

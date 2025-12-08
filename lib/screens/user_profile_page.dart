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
      // 1. Luăm username-ul logat local
      final prefs = await SharedPreferences.getInstance();
      final loggedUser = prefs.getString("username");

      // 2. Verificăm dacă profilul este al meu
      isMyProfile = (widget.username == loggedUser);

      // 3. Fetch profile
      final result = await UserApi.fetchProfile(widget.username);

      setState(() {
        profile = result;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);

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

              const SizedBox(height: 25),

              // ---------- DESCRIPTION ----------
              if (p.description != null && p.description!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      p.description!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade800,
                      ),
                    ),
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
            // Open edit profile
            print("Edit my profile");
          } else {
            // Add friend or accept request
            print("Friend action");
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

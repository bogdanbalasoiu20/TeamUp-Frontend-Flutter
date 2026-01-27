import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/friends/friends_home_page.dart';
import 'package:team_up_fe_new/screens/profile/user_profile_page.dart';

void showLeftMenuModal(BuildContext context, String username) {
  const Color bgDarkStart = Color(0xFF091210);
  const Color bgDarkEnd = Color(0xFF13241E);
  const Color accentGreen = Color(0xFF00E676);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Menu",
    barrierColor: Colors.black.withOpacity(0.6),
    transitionDuration: const Duration(milliseconds: 300),

    pageBuilder: (_, __, ___) {
      return Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.80,
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bgDarkStart, bgDarkEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 30,
                      offset: Offset(5, 0),
                    )
                  ]
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -40,
                    bottom: 100,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.sports_soccer,
                        size: 300,
                        color: Colors.white.withOpacity(0.02),
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: accentGreen, width: 2),
                                  boxShadow: [
                                    BoxShadow(color: accentGreen.withOpacity(0.3), blurRadius: 10)
                                  ]
                              ),
                              child: const CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white12,
                                child: Icon(Icons.person, size: 35, color: Colors.white),
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8, height: 8,
                                        decoration: const BoxDecoration(color: accentGreen, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        "Online",
                                        style: TextStyle(color: Colors.white54, fontSize: 12),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildModernMenuItem(
                              icon: Icons.person_outline_rounded,
                              label: "My Profile",
                              subtitle: "Stats, details & card",
                              accentColor: accentGreen,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserProfilePage(username: username),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            _buildModernMenuItem(
                              icon: Icons.people_outline_rounded,
                              label: "Friends",
                              subtitle: "Find teammates",
                              accentColor: accentGreen,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const FriendsHomePage()),
                                );
                              },
                            ),

                          ],
                        ),
                      ),

                      const Spacer(),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))
                          ),
                          padding: const EdgeInsets.only(top: 20),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  "Log Out",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },

    transitionBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
          ),
        ),
        child: child,
      );
    },
  );
}

Widget _buildModernMenuItem({
  required IconData icon,
  required String label,
  String? subtitle,
  required Color accentColor,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: accentColor.withOpacity(0.1),
      highlightColor: accentColor.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: accentColor),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3), size: 20),
          ],
        ),
      ),
    ),
  );
}
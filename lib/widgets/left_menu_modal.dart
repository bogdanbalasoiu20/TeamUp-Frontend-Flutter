import 'package:flutter/material.dart';
import 'package:team_up_fe_new/screens/friends/friend_search_page.dart';
import 'package:team_up_fe_new/screens/friends/friends_home_page.dart';
import 'package:team_up_fe_new/screens/profile/user_profile_page.dart';

void showLeftMenuModal(BuildContext context, String username) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Menu",
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 250),


    pageBuilder: (_, __, ___) {
      return Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.75,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 22),
              decoration: const BoxDecoration(
                color: Color(0xFF003B2F),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // PROFILE
                  _menuItem(
                    icon: Icons.person_rounded,
                    label: "Profile",
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

                  // FRIENDS
                  _menuItem(
                    icon: Icons.people,
                    label: "Friends",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FriendsHomePage()),
                      );
                    },
                  ),


                  // LOGOUT
                  _menuItem(
                    icon: Icons.logout_rounded,
                    label: "Logout",
                    onTap: () {
                      Navigator.pop(context);
                    },
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
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      );
    },
  );
}


Widget _menuItem({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 26, color: Colors.white),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          )
        ],
      ),
    ),
  );
}

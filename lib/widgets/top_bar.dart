import 'package:flutter/material.dart';

class TopSheetBar extends StatelessWidget {
  final int unseenCount;
  final VoidCallback onNotificationsTap;
  final VoidCallback onMenuTap;
  final String title;

  const TopSheetBar({
    super.key,
    required this.unseenCount,
    required this.onNotificationsTap,
    required this.onMenuTap,
    this.title = "TeamUp",
  });

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 10;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(26, topPadding, 26, 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onMenuTap,
                  child: const Icon(
                    Icons.menu_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 12),


                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black45,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                ),

                const Spacer(),

                GestureDetector(
                  onTap: onNotificationsTap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications,
                        size: 30,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black45,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),

                      if (unseenCount > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                            child: Text(
                              unseenCount.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 1,
            color: Colors.white.withOpacity(0.12),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:team_up_fe_new/widgets/player_card/player_card_ui.dart';

class FifaPlayerCard extends StatelessWidget {
  final PlayerCardUi data;

  const FifaPlayerCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 380,
      child: Stack(
        children: [
          // ---------------- BACKGROUND ----------------
          Image.asset(
            "assets/images/cards/gold_card.png",
            width: 260,
            height: 380,
            fit: BoxFit.contain,
          ),

          // ---------------- RATING + POSITION ----------------
          Positioned(
            top: 50,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.rating.toString(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.white70,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                Text(
                  data.position,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.white70,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),



          // ---------------- AVATAR ----------------


          // workaround pentru NetworkImage (Flutter nu permite empty string)
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 55,
                backgroundImage: NetworkImage(data.imageUrl),
              ),
            ),
          ),

          // ---------------- NAME ----------------
          Positioned(
            top: 215,
            left: 20,
            right: 20,
            child: Text(
              data.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: Colors.black,
                shadows: [
                  Shadow(
                    blurRadius: 6,
                    color: Colors.white70,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),

          // ---------------- STATS ----------------
          Positioned(
            bottom: 45,
            left: 24,
            right: 24,
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3.8,
              children: data.stats.entries.map((e) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${e.value}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.white70,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      e.key,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

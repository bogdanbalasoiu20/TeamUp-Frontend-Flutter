import 'package:flutter/material.dart';
import 'package:team_up_fe_new/widgets/player_card/player_card_ui.dart';

class FifaPlayerCard extends StatelessWidget {
  final PlayerCardUi data;

  const FifaPlayerCard({super.key, required this.data});


  String _mapPosition(String? position) {
    if (position == null) return "MID";

    switch (position.toLowerCase()) {
      case "goalkeeper":
        return "GK";

      case "midfielder":
        return "MID";

      case "defender":
        return "DEF";

      case "forward":
        return "FWD";

      default:
        return position.toUpperCase();
    }
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 380,
      child: Stack(
        children: [
          // ---------------- BACKGROUND ----------------
          Positioned.fill(
            child: Center(
              child: Container(
                width: 260,
                height: 380,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/cards/gold_card.png"),
                    fit: BoxFit.contain,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 30,
                      spreadRadius: -8,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
              ),
            ),
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
                  _mapPosition(data.position),
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
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(data.imageUrl),
                ),
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

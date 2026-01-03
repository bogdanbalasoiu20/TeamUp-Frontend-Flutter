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
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            // ✅ EXACT ca înainte (varianta care știi că a mers)
            image: AssetImage("assets/images/cards/gold_card.png"),
            fit: BoxFit.contain,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [

              // 🔝 RATING + POSITION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.rating.toString(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        data.position,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.sports_soccer, size: 26),
                ],
              ),

              const SizedBox(height: 20),

              // 👤 AVATAR
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(data.imageUrl),
              ),

              const SizedBox(height: 12),

              // 👑 NAME
              Text(
                data.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),

              const Spacer(),

              // 📊 STATS
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 3.2,
                children: data.stats.entries.map((e) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${e.value}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        e.key,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

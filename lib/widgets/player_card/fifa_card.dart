import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:team_up_fe_new/widgets/player_card/player_card_ui.dart';

const List<String> fifaOutfieldOrder = [
  "PAC",
  "DRI",
  "SHO",
  "DEF",
  "PAS",
  "PHY",
];

const List<String> fifaGoalkeeperOrder = [
  "DIV",
  "REF",
  "HAN",
  "SPD",
  "KIC",
  "POS",
];

const Color _textColor = Color(0xFF252525);

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
    final TextStyle fifaFont = GoogleFonts.oswald(
      color: _textColor,
      shadows: [
        const Shadow(
          blurRadius: 1,
          color: Colors.white54,
          offset: Offset(0, 1),
        ),
      ],
    );

    return SizedBox(
      width: 260,
      height: 380,
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Container(
                width: 260,
                height: 380,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  image: DecorationImage(
                    image: AssetImage(
                      _cardBackgroundByRating(data.rating),
                    ),
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

          Positioned(
            top: 60,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.rating.toString(),
                  style: fifaFont.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                Text(
                  _mapPosition(data.position),
                  style: fifaFont.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

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

          Positioned(
            top: 210,
            left: 20,
            right: 20,
            child: Text(
              data.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: fifaFont.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),

          Positioned(
            bottom: 45,
            left: 24,
            right: 24,
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3.8,
              children: (data.position?.toLowerCase() == "goalkeeper"
                  ? const ["DIV", "REF", "HAN", "SPD", "KIC", "POS"]
                  : const ["PAC", "DRI", "SHO", "DEF", "PAS", "PHY"])
                  .where((key) => data.stats.containsKey(key))
                  .map((key) {
                final value = data.stats[key]!;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$value",
                      style: fifaFont.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      key,
                      style: fifaFont.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
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

String _cardBackgroundByRating(int rating) {
  if (rating >= 75) {
    return "assets/images/cards/gold_card.png";
  } else if (rating >= 65) {
    return "assets/images/cards/silver_card.png";
  } else {
    return "assets/images/cards/bronze_card.png";
  }
}
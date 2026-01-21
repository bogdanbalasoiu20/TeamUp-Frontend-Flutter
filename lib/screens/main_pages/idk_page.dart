import 'package:flutter/material.dart';
import '../../widgets/player_card/fifa_card.dart';
import '../../widgets/player_card/player_card_ui.dart';


class IdkPage extends StatefulWidget {
  const IdkPage({super.key});

  @override
  State<IdkPage> createState() => _IdkPageState();
}

class _IdkPageState extends State<IdkPage> {
  @override
  Widget build(BuildContext context) {
    final mockCard = PlayerCardUi(
      name: "Bogdan",
      position: "CM",
      rating: 82,
      imageUrl: "https://i.imgur.com/BoN9kdC.png",
      stats: {
        "PAC": 78,
        "SHO": 75,
        "PAS": 84,
        "DRI": 81,
        "DEF": 70,
        "PHY": 76,
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text("Player Card Preview"),
        centerTitle: true,
      ),
      body: Center(
        child: FifaPlayerCard(data: mockCard),
      ),
    );
  }
}

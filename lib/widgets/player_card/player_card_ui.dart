class PlayerCardUi {
  final String name;
  final String position;
  final int rating;
  final String imageUrl;
  final Map<String, int> stats;

  const PlayerCardUi({
    required this.name,
    required this.position,
    required this.rating,
    required this.imageUrl,
    required this.stats,
  });
}

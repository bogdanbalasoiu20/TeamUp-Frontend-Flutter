class MonthlyStats {
  final int totalThisMonth;
  final int totalLastMonth;
  final double percentageChange;
  final int openMatchesThisMonth;
  final int tournamentsThisMonth;

  MonthlyStats({
    required this.totalThisMonth,
    required this.totalLastMonth,
    required this.percentageChange,
    required this.openMatchesThisMonth,
    required this.tournamentsThisMonth,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    return MonthlyStats(
      totalThisMonth: json["totalThisMonth"],
      totalLastMonth: json["totalLastMonth"],
      percentageChange: (json["percentageChange"] as num).toDouble(),
      openMatchesThisMonth: json["openMatchesThisMonth"],
      tournamentsThisMonth: json["tournamentsThisMonth"],
    );
  }
}
import 'package:intl/intl.dart';


String formatMatchTime(DateTime? start, DateTime? end) {
  if (start == null) return "-";

  final date = DateFormat("EEEE, d MMM").format(start);
  final startTime = DateFormat("HH:mm").format(start);

  if (end == null) {
    return "$date • $startTime";
  }

  final endTime = DateFormat("HH:mm").format(end);

  return "$date • $startTime – $endTime";
}


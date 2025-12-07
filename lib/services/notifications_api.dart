import 'package:team_up_fe_new/exceptions/api_exception.dart';
import 'package:team_up_fe_new/exceptions/api_service.dart';
import 'package:team_up_fe_new/models/notification_item.dart';

class NotificationsApi {
  static Future<List<NotificationItem>> fetchAll({int page = 0}) async {
    final response = await ApiService.get(
      "/api/notifications?page=$page&size=50&sort=createdAt,desc",
    );

    final data = response["data"];
    final List items = data["content"];

    return items.map((e) => NotificationItem.fromJson(e)).toList();

  }

  static Future<void> markAsSeen(String id) async {
      await ApiService.patch("/api/notifications/$id/seen", {});
  }

  static Future<int> unseenCount() async {
      final response = await ApiService.get("/api/notifications/unseen-count");
      return response["data"] as int;
  }
}

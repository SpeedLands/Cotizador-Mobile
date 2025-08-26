import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../global/widgets/custom_scaffold.dart';
import '../../global/widgets/loading_indicator.dart';
import 'notification_controller.dart';

class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomScaffold(
    showBackButton: true,
    showDrawer: true,
    title: 'Notificaciones',
    body: Obx(() {
      if (controller.isLoading.value && controller.notifications.isEmpty) {
        return const AppLoadingIndicator();
      }

      if (controller.notifications.isEmpty) {
        return const Center(
          child: Text(
            'No tienes notificaciones nuevas.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchNotifications(),
        child: ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];

            // Usamos Dismissible para el efecto "swipe to delete"
            return Dismissible(
              key: Key(
                notification.id.toString(),
              ), // Clave única para cada item
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                controller.deleteNotification(notification.id);
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.isRead
                      ? Colors.grey.shade300
                      : Theme.of(context).primaryColor,
                  child: Icon(
                    notification.isRead
                        ? Icons.notifications_off
                        : Icons.notifications,
                    color: notification.isRead
                        ? Colors.grey.shade600
                        : Colors.white,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
                subtitle: Text(notification.body),
                onTap: () {
                  // Al tocar, la marcamos como leída
                  controller
                    ..markAsRead(notification.id)
                    ..handleActionUrl(notification.actionUrl);
                },
              ),
            );
          },
        ),
      );
    }),
  );
}

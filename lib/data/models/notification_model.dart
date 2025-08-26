class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.actionUrl,
    required this.createdAt,
  });

  // --- CONSTRUCTOR CORREGIDO Y A PRUEBA DE ERRORES ---
  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        title: json['title'].toString(),
        body: json['body'].toString(),
        // Convertimos '0', '1', 0, 1, o null a un booleano de forma segura
        isRead: (json['is_read']?.toString() ?? '0') == '1',
        actionUrl: json['action_url'].toString(),
        createdAt: json['created_at'].toString(),
      );
  final int id;
  final String title;
  final String body;
  final bool isRead;
  final String actionUrl;
  final String createdAt;
}

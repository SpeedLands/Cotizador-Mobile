import 'dart:convert';

class CustomReminder {
  CustomReminder({
    required this.notificationId,
    required this.quoteId,
    required this.title,
    required this.body,
    required this.scheduledDate,
  });

  // Método para crear un objeto CustomReminder desde un Map (desde JSON)
  factory CustomReminder.fromMap(Map<String, dynamic> map) => CustomReminder(
    notificationId: map['notificationId'] as int,
    quoteId: map['quoteId'] as int,
    title: map['title'] as String,
    body: map['body'] as String,
    scheduledDate: DateTime.parse(map['scheduledDate'] as String),
  );

  factory CustomReminder.fromJson(String source) =>
      CustomReminder.fromMap(json.decode(source) as Map<String, dynamic>);
  final int notificationId; // ID único para la notificación
  final int quoteId; // ID de la cotización a la que pertenece
  final String title;
  final String body;
  final DateTime scheduledDate;

  // Método para convertir un objeto CustomReminder a un Map (para JSON)
  Map<String, dynamic> toMap() => {
    'notificationId': notificationId,
    'quoteId': quoteId,
    'title': title,
    'body': body,
    'scheduledDate': scheduledDate.toIso8601String(),
  };

  String toJson() => json.encode(toMap());
}

import 'package:url_launcher/url_launcher.dart';

Future<void> launchWhatsApp(String phone) async {
  final Uri url = Uri.parse('https://wa.me/$phone');
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'No se pudo abrir WhatsApp en $url';
  }
}

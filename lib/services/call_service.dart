import 'package:url_launcher/url_launcher.dart';

class CallService {
  static Future<void> joinCall({required String roomName}) async {
    final url = Uri.parse('https://meet.jit.si/$roomName');

    final can = await canLaunchUrl(url);
    if (!can) {
      throw 'No se pudo abrir la videollamada';
    }

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

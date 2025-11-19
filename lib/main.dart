import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/auth/phone_auth_gate.dart';

class TecChatApp extends StatelessWidget {
  const TecChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tec Chat Celaya',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      debugShowCheckedModeBanner: false,
      home: const PhoneAuthGate(),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TecChatApp());
}

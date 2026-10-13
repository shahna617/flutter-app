import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/role_gate.dart';
import 'core/session/session_provider.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),
      ],
      child: MaterialApp(
        title: 'Guardly',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const RoleGate(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import 'theme/app_theme.dart';

import 'providers/auth_provider.dart';
import 'providers/tutor_provider.dart';
import 'providers/message_provider.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.initTokens();
  runApp(const HiTutorApp());
}

class HiTutorApp extends StatelessWidget {
  const HiTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => TutorProvider()),
        ChangeNotifierProvider(create: (context) => MessageProvider()),
      ],
      child: MaterialApp(
        title: 'HiTutor 好会帮',
        theme: AppTheme.lightTheme,
        initialRoute: Routes.splash,
        routes: Routes.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

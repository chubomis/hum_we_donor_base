import 'package:flutter/material.dart';
import 'package:hum_we_donor_base/screens/home_screen.dart';
import 'package:hum_we_donor_base/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
 
  await Supabase.initialize(
    url: 'https://wpvtvjpbdsgeqevigyzn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndwdnR2anBiZHNnZXFldmlneXpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjI3MTA5ODgsImV4cCI6MjAzODI4Njk4OH0.7y9fb226_YbOBuQgjRKNmnuTUrqT8USpvyMG6twoJpc',
  );
  
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setSize(Size(800, 600));
    await windowManager.setMinimumSize(Size(800, 600));
    await windowManager.setMaximumSize(Size(800, 600));
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

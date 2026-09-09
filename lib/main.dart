import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized before calling Supabase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL', // Paste your Project URL here
    anonKey: 'YOUR_SUPABASE_ANON_KEY', // Paste your anon key here
  );

  runApp(const VeluneApp());
}

// A handy variable to use the Supabase client anywhere in your app
final supabase = Supabase.instance.client;

class VeluneApp extends StatelessWidget {
  const VeluneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VELUNE',
      theme: ThemeData(
        brightness: Brightness.dark,
        // We will build the premium theme later
      ),
      home: const Scaffold(
        body: Center(
          child: Text('VELUNE Backend Initialized'),
        ),
      ),
    );
  }
}
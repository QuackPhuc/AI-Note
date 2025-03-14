import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Load notes in background
    await Provider.of<NoteProvider>(context, listen: false).loadNotes();
    
    // Add a small delay to show the splash screen
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (!mounted) return;
    
    // Navigate to home screen and remove splash screen from navigation stack
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'AI Note',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

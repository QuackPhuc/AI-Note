import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';
import '../services/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final AIService _aiService = AIService();
  bool _hasApiKey = false;
  bool _isObscured = true;
  bool _isDarkMode = false;
  bool _isLoadingSettings = true;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Tiếng Việt', 'Español', '中文'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini_api_key') ?? '';
    final isDarkMode = prefs.getBool('dark_mode') ?? false;
    final language = prefs.getString('language') ?? 'English';

    setState(() {
      _apiKeyController.text = apiKey;
      _hasApiKey = apiKey.isNotEmpty;
      _isDarkMode = isDarkMode;
      _selectedLanguage = language;
      _isLoadingSettings = false;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key cannot be empty')),
      );
      return;
    }

    await _aiService.saveApiKey(apiKey);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API key saved successfully')),
    );
    
    setState(() {
      _hasApiKey = true;
    });
  }

  Future<void> _saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDarkMode);
    setState(() {
      _isDarkMode = isDarkMode;
    });

    // Update the app theme
    if (!mounted) return;
    Provider.of<ThemeProvider>(context, listen: false).setDarkMode(isDarkMode);
  }

  Future<void> _saveLanguagePreference(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    setState(() {
      _selectedLanguage = language;
    });

    // Display a message that language change will take effect after restart
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Language will change after restarting the app')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoadingSettings 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appearance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Toggle between light and dark theme'),
                        value: _isDarkMode,
                        onChanged: _saveThemePreference,
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Language'),
                        subtitle: Text('Current: $_selectedLanguage'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Select Language'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _languages.length,
                                  itemBuilder: (context, index) {
                                    return RadioListTile<String>(
                                      title: Text(_languages[index]),
                                      value: _languages[index],
                                      groupValue: _selectedLanguage,
                                      onChanged: (value) {
                                        Navigator.pop(context);
                                        if (value != null) {
                                          _saveLanguagePreference(value);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('CANCEL'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                const Text(
                  'Gemini API Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter your Gemini API key to enable AI summarization features.',
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _apiKeyController,
                          decoration: InputDecoration(
                            labelText: 'Gemini API Key',
                            hintText: 'Enter your API key',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),
                          ),
                          obscureText: _isObscured,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveApiKey,
                          child: const Text('Save API Key'),
                        ),
                        if (_hasApiKey)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                const Text('API key is set'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How to get a Gemini API key:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1. Go to https://ai.google.dev/\n'
                          '2. Sign in with your Google account\n'
                          '3. Navigate to "API keys" section\n'
                          '4. Create a new API key\n'
                          '5. Copy and paste it here',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                const Text(
                  'About',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    title: const Text('AI Note'),
                    subtitle: const Text('Version 1.0.0'),
                    trailing: const Icon(Icons.info_outline),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'AI Note',
                        applicationVersion: '1.0.0',
                        applicationIcon: const FlutterLogo(),
                        children: [
                          const Text(
                            'A note-taking app with AI summarization capabilities powered by Google Gemini.',
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/user_settings.dart';

class ThemeSettingsSection extends StatelessWidget {
  final UserSettings settings;
  final Function(AppThemeMode) onThemeChanged;

  const ThemeSettingsSection({
    super.key,
    required this.settings,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildThemeOption(AppThemeMode.light, 'Light'),
        _buildThemeOption(AppThemeMode.dark, 'Dark'),
        _buildThemeOption(AppThemeMode.system, 'System'),
      ],
    );
  }

  Widget _buildThemeOption(AppThemeMode mode, String title) {
    return ListTile(
      leading: Radio<AppThemeMode>(
        value: mode,
        groupValue: settings.themeMode,
        onChanged: (value) {
          if (value != null) onThemeChanged(value);
        },
      ),
      title: Text(title),
      onTap: () => onThemeChanged(mode),
    );
  }
}

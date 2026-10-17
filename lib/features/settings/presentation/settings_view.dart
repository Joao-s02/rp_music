import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rp_music/bootstrap/composition_root.dart';
import 'package:rp_music/core/diagnostics/diagnostics_service.dart';
import 'package:rp_music/features/settings/domain/app_settings.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Appearance', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
          ),
          ListTile(
            title: const Text('Theme Mode'),
            subtitle: Text(settings.themeMode.name.toUpperCase()),
            leading: const Icon(Icons.brightness_6_rounded),
            trailing: DropdownButton<AppThemeMode>(
              value: settings.themeMode,
              onChanged: (mode) {
                if (mode != null) notifier.setThemeMode(mode);
              },
              items: const [
                DropdownMenuItem(value: AppThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: AppThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: AppThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),
          ListTile(
            title: const Text('UI Density'),
            subtitle: Text(settings.density.name.toUpperCase()),
            leading: const Icon(Icons.density_medium_rounded),
            trailing: DropdownButton<UiDensity>(
              value: settings.density,
              onChanged: (d) {
                if (d != null) notifier.setDensity(d);
              },
              items: const [
                DropdownMenuItem(value: UiDensity.compact, child: Text('Compact')),
                DropdownMenuItem(value: UiDensity.standard, child: Text('Standard')),
                DropdownMenuItem(value: UiDensity.comfortable, child: Text('Comfortable')),
              ],
            ),
          ),
          ListTile(
            title: const Text('Accent Color'),
            leading: const Icon(Icons.color_lens_rounded),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _colorCircle(0xFF6750A4, settings.primaryColorValue, notifier),
                const SizedBox(width: 8),
                _colorCircle(0xFF006C50, settings.primaryColorValue, notifier),
                const SizedBox(width: 8),
                _colorCircle(0xFF8B4A62, settings.primaryColorValue, notifier),
                const SizedBox(width: 8),
                _colorCircle(0xFF0061A4, settings.primaryColorValue, notifier),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Diagnostics & Privacy', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
          ),
          ListTile(
            title: const Text('Export Local Diagnostics Log'),
            subtitle: const Text('View and copy privacy-redacted logs for debugging'),
            leading: const Icon(Icons.bug_report_rounded),
            onTap: () => _showDiagnosticsDialog(context),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('About RP Music', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
          ),
          const ListTile(
            title: Text('Architecture'),
            subtitle: Text('Local-First Modular Monolith with Ports and Adapters'),
            leading: Icon(Icons.architecture_rounded),
          ),
          const ListTile(
            title: Text('Supported Platforms'),
            subtitle: Text('Windows, Android, and Web'),
            leading: Icon(Icons.devices_rounded),
          ),
        ],
      ),
    );
  }

  Widget _colorCircle(int value, int selectedValue, SettingsNotifier notifier) {
    final isSelected = value == selectedValue;
    return GestureDetector(
      onTap: () => notifier.setPrimaryColor(value),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Color(value),
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: isSelected ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : null,
        ),
        child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
      ),
    );
  }

  void _showDiagnosticsDialog(BuildContext context) {
    final diagnostics = DiagnosticsService();
    final jsonLogs = diagnostics.exportLogsJson(redactSensitive: true);
    final formatted = const JsonEncoder.withIndent('  ').convert(jsonLogs);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diagnostics Log (Redacted)'),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: SingleChildScrollView(
            child: SelectableText(
              formatted.isEmpty ? 'No diagnostic entries recorded.' : formatted,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copy to Clipboard'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: formatted));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Diagnostics copied to clipboard')),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

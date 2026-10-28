import 'package:flutter/material.dart';

import 'program_controller.dart';

class ExtensionDestination {
  ExtensionDestination(this.id, this.label, this.icon, this.color);
  final String id, label, icon;
  final int color;
}

List<ExtensionDestination> extensionDestinations(
  ProgramController? programs,
  String platform,
) {
  if (programs == null) return [];
  final entries = <ExtensionDestination>[];
  for (final source in programs.installed.values) {
    if (source.package.engine == 'javascript' &&
        source.package.slots.contains('screen') &&
        programs.allowed(source.package.id, 'navigation.add')) {
      entries.add(
        ExtensionDestination(
          source.package.id,
          'JS · ${source.package.name}'.substring(
            0,
            ('JS · ${source.package.name}').length.clamp(0, 14),
          ),
          'cloud',
          0xff9c8dff,
        ),
      );
      continue;
    }
    final spec = source.package.sourceSpec;
    if (spec?.navigationLabel == null ||
        !spec!.platforms.contains(platform) ||
        programs.allowed(source.package.id, 'navigation.add') != true ||
        programs.allowed(source.package.id, 'network.http') != true) {
      continue;
    }
    entries.add(
      ExtensionDestination(
        source.package.id,
        spec.navigationLabel!,
        spec.icon,
        spec.color,
      ),
    );
  }
  return entries;
}

class ExtensionNavigationIcon extends StatelessWidget {
  const ExtensionNavigationIcon(this.entry, {super.key});
  final ExtensionDestination entry;
  @override
  Widget build(BuildContext context) {
    if (entry.icon == 'playBadge') {
      return Container(
        width: 28,
        height: 21,
        decoration: BoxDecoration(
          color: Color(entry.color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 20,
        ),
      );
    }
    return Icon(switch (entry.icon) {
      'playOutline' => Icons.smart_display_outlined,
      'music' => Icons.music_note_outlined,
      'headphones' => Icons.headphones_outlined,
      _ => Icons.cloud_outlined,
    });
  }
}

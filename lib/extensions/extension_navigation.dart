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
  final source = programs?.owner('source');
  final spec = source?.package.sourceSpec;
  if (source == null ||
      spec?.navigationLabel == null ||
      !spec!.platforms.contains(platform) ||
      programs?.allowed(source.package.id, 'navigation.add') != true ||
      programs?.allowed(source.package.id, 'network.http') != true) {
    return [];
  }
  return [
    ExtensionDestination(
      source.package.id,
      spec.navigationLabel!,
      spec.icon,
      spec.color,
    ),
  ];
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
      'music' => Icons.music_note_outlined,
      'headphones' => Icons.headphones_outlined,
      _ => Icons.cloud_outlined,
    });
  }
}

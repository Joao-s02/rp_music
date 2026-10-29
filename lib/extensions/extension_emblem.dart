import 'package:flutter/material.dart';

/// Presentation only: never used to grant permissions or select providers.
class ExtensionEmblem extends StatelessWidget {
  const ExtensionEmblem({super.key, required this.id, this.size = 48});
  final String id;
  final double size;
  IconData get symbol => id.contains('radio')
      ? Icons.radio_rounded
      : id.contains('explor')
      ? Icons.explore_rounded
      : id.contains('youtube')
      ? Icons.smart_display_rounded
      : id.contains('letras') || id.contains('lyrics')
      ? Icons.lyrics_rounded
      : id.contains('biblioteca')
      ? Icons.library_music_rounded
      : id.contains('pulso')
      ? Icons.graphic_eq_rounded
      : id.contains('laboratorio')
      ? Icons.science_rounded
      : Icons.extension_rounded;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * .3),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              c.primary.withValues(alpha: .22),
              c.secondary.withValues(alpha: .20),
            ],
          ),
          border: Border.all(color: c.primary.withValues(alpha: .24)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(symbol, size: size * .53, color: c.primary),
            Positioned(
              right: size * .13,
              bottom: size * .12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Container(
                    width: size * .055,
                    height: size * (.06 + (i == 1 ? .04 : 0)),
                    margin: EdgeInsets.only(left: size * .035),
                    decoration: BoxDecoration(
                      color: c.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

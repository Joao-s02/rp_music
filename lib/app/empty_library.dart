import 'package:flutter/material.dart';

class EmptyLibrary extends StatelessWidget {
  const EmptyLibrary({super.key, required this.onChoose, required this.busy});
  final VoidCallback? onChoose;
  final bool busy;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        '● Sin música indexada · 0 pistas',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.offline_bolt_outlined, color: colors.primary),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.secondary.withValues(alpha: 0.22),
                      colors.primary.withValues(alpha: 0.06),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.waves_rounded,
                      size: 52,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tu biblioteca está en silencio',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'RP Music reproduce los archivos de audio locales almacenados en tu dispositivo sin necesidad de conexión ni cuentas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: onChoose,
                        icon: const Icon(Icons.folder_open),
                        label: Text(
                          busy ? 'Abriendo carpeta…' : 'Elegir carpeta',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Incluiremos también sus subcarpetas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'RUTAS RÁPIDAS SUGERIDAS',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) => Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final item in [
                      (Icons.folder_outlined, 'Carpeta común', '/Music/'),
                      (
                        Icons.sd_card_outlined,
                        'Memoria SD',
                        'Elegir si está disponible',
                      ),
                    ])
                      SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            leading: Icon(item.$1),
                            title: Text(
                              item.$2,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              item.$3,
                              style: const TextStyle(fontSize: 12),
                            ),
                            onTap: onChoose,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

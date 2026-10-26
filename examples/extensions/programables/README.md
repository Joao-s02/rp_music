# Primeros programas de RP Music — API 2

Requieren RP Music 0.3.0+9 o superior (API 2). La release 0.2.6 solo admite API 1.

- **Biblioteca viva**: filtros ejecutados por código Dart, resultados, listas manuales/automáticas y preferencias propias. Carátulas propias/mosaico se eligen desde Listas en la app.
- **Pulso nocturno**: nivel avanzado, disposición de controles antes de carátula y aleatorio que busca otro artista.

Instalables desde Extensiones → Explorar repositorio → Consultar, usando https://github.com/Joao-s02/rp-music-extensions, o importando sus `.rpmx`. Aceptar permisos es obligatorio; ninguno se activa al instalar el APK. Pueden coexistir y se elige propietario por función. El catálogo visual inicial tiene componentes limitados y el motor es experimental: usar archivos de confianza.

Fuentes `.dart` y paquetes `.rpmx` se conservan juntos. Para regenerar: `python tools/empaquetar_extension.py examples/extensions/programables/biblioteca-viva.rpmx`.

Contrato, límites y pruebas en [SDK API 2](../../../docs/EXTENSIONES-API-2.md).

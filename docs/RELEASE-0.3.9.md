# RP Music 0.3.9-alpha.1 — Explorador musical y radio JavaScript

API 3 añade consultas HTTP por etapas y reproducción remota con permisos, cancelación y revocación. API 2/Dart y extensiones anteriores se conservan.

Dos opciones nuevas en el [catálogo de extensiones](https://github.com/Joao-s02/rp-music-extensions), ambas 0.1.0 y requieren app 0.3.9:

- Explorador musical: artistas/álbumes/listas/canciones públicas de YouTube Music, navegación y resolución AAC sin cuenta.
- Radio por internet: Radio Browser, búsqueda/filtros/populares y favoritas privadas. Solo HTTPS MP3/AAC sin HLS.

Las extensiones se instalan por separado; no están dentro del APK/ZIP ni adjuntas aquí. Conviven con YouTube Dart sin sustituir Fuente.

**Descargas:** app 0.3.9+18, Android universal, ARM64 y Windows x64 portable completo, USO/PRUEBAS/CAMBIOS y SHA256SUMS. Instalar Android encima sin desinstalar; extraer todo el ZIP Windows.

**Verificación:** 138 pruebas aprobadas, una optativa omitida y análisis limpio. Navegación/resolución pública y lista100+100 comprobadas; radio AAC nativa Windows con pausa/reanudación/revocación aprobada.

**Pendiente:** Android físico, escucha prolongada y más redes/emisoras. Resolver YouTube no demuestra reproducción nativa Windows; ese límite se conserva. Sin cuentas/sincronización/descargas/importación desde estas pantallas JS. SDK experimental con límites, sin Node/npm/HTML libre ni aislamiento de proceso. No se modifican releases anteriores.

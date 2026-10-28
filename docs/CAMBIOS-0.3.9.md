# Cambios de RP Music 0.3.9

App0.3.9+18, API 3/JavaScript ampliada manteniendo API 1 y API 2/Dart.

- HTTP genérico por etapas con dominios/HTTPS/cabeceras/tamaños/plazos limitados y hasta cuatro consultas por acción.
- Audio remoto autorizado mediante el reproductor de RP Music; nuevo permiso separado para streams HTTPS públicos de emisoras de dominios variables.
- Cancelación y revocación descartan respuestas tardías; resoluciones de audio solo en memoria, invalidadas al cambiar paquete/permisos/desactivar.
- Formularios recogen sus valores iniciales y se restablecen desde árboles nuevos. Pila QuickJS Windows acotada512 KiB para JSON anidado, heap32 MiB/timeout1000 ms conservados; no es aislamiento OS.
- Explorador musical0.1.0: variante JavaScript independiente sobre YouTube Music público, artistas/álbumes/listas/canciones, navegación/Atrás/páginas/continuación y resolución AAC sin cuenta.
- Radio por internet0.1.0: Radio Browser, filtros/populares/páginas, hasta 30 favoritas privadas y renovación por UUID. Solo HTTPS MP3/AAC sin HLS.

Extensiones exclusivamente en https://github.com/Joao-s02/rp-music-extensions, fuera de los binarios/adjuntos de la app. Requieren0.3.9 y permisos explícitos. YouTube estable/Explorador Dart y Laboratorio JS previos intactos; propietario Fuente conservado.

138 pruebas aprobadas (130 de app + 8 externas), una optativa omitida y análisis limpio. Windows real: consultas/apertura pública, resolución de audio, lista100+100 y radio AAC con avance/pausa/reanudación/revocación aprobadas. Resolver YouTube no acredita reproducción nativa Windows. Android físico/escucha prolongada/más redes/emisoras pendientes. Sin cuentas/sincronización/descarga/importación desde las nuevas pantallas JS. Versiones anteriores no se modifican.

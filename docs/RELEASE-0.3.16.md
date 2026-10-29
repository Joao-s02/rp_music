# RP Music 0.3.16-alpha.1 — portadas, artistas y descargas

Mejora las descargas de canciones sueltas con respaldo del vídeo exacto para identificar su álbum y obtener portadas de mayor resolución. Las pruebas con La Incondicional y Las Noches verifican álbum/imagen incrustados; el respaldo conserva álbum y portada1200×1200 aun con MusicBrainz simulado fuera de servicio. La cobertura depende de cada canción y proveedor.

- **Explorar** reúne fuentes y pantallas de extensiones; la navegación conserva cinco destinos.
- Álbum local con búsqueda plegable mediante lupa e indicador animado de la canción actual, respetando pausa y movimiento reducido.
- Artistas agrupados sin duplicados por mayúsculas/espacios y separados por coma, «y» y «&». No modifica etiquetas de archivos existentes.
- Fotos públicas de artistas y portadas de álbumes en los resultados del Explorador.
- Descarga de álbum a archivo temporal con progreso por canción/bytes y reintento exclusivo de fallidas. Hasta512MiB por canción; requiere mantener la app abierta. Descargas individuales conservan64MiB.
- API3 incorpora diagnóstico por fases y caché pública optativa breve; todavía sin mejora de latencia medida en Android.

**Actualiza también las extensiones desde Explorar → Administrar extensiones → Explorar repositorio:** YouTube Android/Windows0.5.3, YouTube Explorador Android/Windows0.2.3 y Explorador musical JS0.1.1. Paquetes independientes en [rp-music-extensions](https://github.com/Joao-s02/rp-music-extensions), fuera de los APK/ZIP; versiones anteriores conservadas.

**Instalación:** Android universal o ARM64 desde Archivos, actualizando sin desinstalar. Windows: extraer el ZIP completo, incluidas DLL/data/licencias. Se conserva la firma compatible y la actualización Android por web/Archivos.

**Verificación:**163 pruebas aprobadas, una optativa omitida, análisis limpio, cuatro paquetes Dart probados con intérprete real y ensayos adicionales de metadatos/portadas públicas. Escritor a disco conserva audio de65MiB por SHA256. Binarios normales Android/Windows verificados estructuralmente; sin prueba física nueva ni nuevo veredicto Play Protect. Pendientes: SD/SAF/widgets/ARM64 físicos, escucha prolongada y latencia API3 Android.

Incluye Android universal, Android ARM64, Windows completo, USO, PRUEBAS, CAMBIOS y SHA256SUMS. Las descargas antiguas no se reparan automáticamente.

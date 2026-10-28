# Cambios de RP Music 0.3.7

- Soporte genérico opcional de exploración de fuentes: tipos de resultado, páginas de artistas/álbumes/listas y continuación.
- Importación de álbum/lista remotos como copias locales independientes; orden/repeticiones y referencias/metadatos persistentes tras reinicio. No descarga audio al importar.
- Variante YouTube Explorador 0.1.0 con identidad propia en el repositorio de extensiones. YouTube Android 0.4.0 estable conservada intacta; elección explícita de Fuente. No se incluyen paquetes de extensiones en los binarios o adjuntos.
- Se conserva la corrección M4A de 0.3.6, confirmada satisfactoria por el usuario.

App 0.3.7+16; distribución Android universal, ARM64 y Windows x64 completo. Explorador Android requiere 0.3.7; Letras locales 0.1.0 y demás extensiones anteriores conservan su compatibilidad.

Verificación: 114 pruebas aprobadas/una red optativa omitida; análisis limpio de cambios; UI a 360 px e importación/reinicio aprobados; siete comprobaciones del paquete real en dart_eval, navegación pública y páginas largas 100+100 pistas. No se suman repeticiones. Prueba física de Explorador pendiente.

Sin login Google ni sincronización bidireccional todavía. No garantiza discografía exhaustiva, contenido privado/regiones ni toda respuesta futura del servicio. YouTube Windows conserva fallos conocidos; Spotify/Play Store cancelados. No modifica automáticamente canciones antiguas afectadas por 0.3.5. Licencia concreta del proyecto sigue pendiente.

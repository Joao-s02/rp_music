---
tipo: fuente
alcance: fuente-historica
estado: consolidado
actualizado: 2026-10-24
---
# Entrevista consolidada

> **Fuente histórica de requisitos:** entrevista inicial, complementada por decisiones posteriores. No describe por sí sola la implementación actual; consultar [[02 Vision y decisiones]] y [[10 Estado del repositorio]].

Resumen fiel de las tres rondas de respuestas disponibles en esta conversación. No es una transcripción literal. Las aclaraciones posteriores prevalecen sobre las primeras respuestas. Las fechas individuales de las respuestas no se presuponen.

## Petición original

Entrevistar al usuario para definir un reproductor de música Flutter para Android, Windows y web: extremadamente optimizado, base sencilla y extensiones programables por cualquiera para añadir funciones, incluida conexión con YouTube.

## Ronda 1

1. Público: comunidad que pueda personalizarlo.
2. Sin extensiones: archivos del dispositivo; se aclara que es reproductor de música.
3. Acepta biblioteca, búsqueda, listas, favoritos, cola, aleatorio, repetición, carátulas, etiquetas y letras; ecualizador como extensión.
4. Prioriza fluidez: listas rápidas al entrar, reproducción y cambio de canción sin trabas.
5. Web opcional; prioridad en equivalencia de extensiones entre Android y Windows.
6. Desea todas las libertades posibles para las extensiones.
7. Varias opciones para instalarlas.
8. Acepta reiniciar después de instalar; no reinstalar toda la app.
9. Código abierto y futura publicación en Play Store.
10. Referencias: Spotify y Samsung con más personalización; Namida por carátulas y agrupación por álbum.

## Ronda 2

1. Cientos y miles de canciones; archivos pueden estar en varias ubicaciones.
2. Prefiere elegir carpeta específica.
3. Valora vista por carpetas; considera filtros detallados para extensiones. La ronda 3 precisa las vistas base.
4. Acepta segundo plano, pantalla apagada, controles de sistema, teclas multimedia, recordar cola/posición, gapless y fundido.
5. Música suele traer letras; búsqueda de letras faltantes como extensión.
6. Base completamente sin internet y sin cuenta; cuentas opcionales para extensiones de servicios. Menciona bibliotecas de YouTube Music y Spotify.
7. Prefiere dos niveles de permisos, normal y avanzado de confianza.
8. Quiere ver consumo por extensión; optimización estricta para la base y libertad de ampliar según hardware.
9. Personalización de todo, incluidas pantallas, tipografías, colores, controles y carátulas; acepta ajustes básicos sin extensiones.
10. Extensiones colaboran; usuario elige ante conflicto por la misma pantalla.
11. Está aprendiendo; conoce Flutter y Dart, proyecto ambicioso de sus primeros trabajos.
12. Ejemplos: YouTube Music, ecualizador y Spotify.

## Ronda 3

1. Una única carpeta raíz con subcarpetas organizadas por el usuario.
2. Base con canciones, álbumes, artistas y carpetas.
3. Acepta letras integradas y externas; elegir destino de cambios de metadatos, archivo o biblioteca.
4. Formatos: MP3, FLAC, M4A, MP4, WAV y OPUS.
5. Opción de cerrar Windows o continuar en bandeja.
6. Integraciones: buscar/explorar catálogo y reproducir dentro de la aplicación.
7. Acepta otros lenguajes para facilitar extensiones.
8. Acepta extensiones o capacidades específicas de plataforma.
9. Actualizaciones solo con aceptación; no confirma expresamente revisión del catálogo.
10. Acepta comenzar con reproductor local y extensión pequeña de pantalla/función antes de integraciones completas.
11. Autoriza eliminar código actual y empezar de cero. Declara Flutter listo, Git y GitHub CLI instalados y repositorio `rp_music` con alfa que no le gusta. No responde cuál plataforma desarrollar primero.
12. Antes de código nuevo solicita carpeta como bóveda Obsidian: red con todo contexto de entrevista para cualquier agente; actualizarla con cada nuevo contexto o hecho importante.

## Uso de esta fuente

Para requisitos actuales leer [[02 Vision y decisiones]], [[03 Biblioteca y reproduccion]] y [[04 Extensiones]]. Para respuestas incompletas o cuestiones sugeridas sin aprobación, consultar [[07 Preguntas e investigacion]].

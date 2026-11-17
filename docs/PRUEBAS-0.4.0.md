# Verificación de RP Music 0.4.0

## Comprobaciones automatizadas

La suite de la reforma aprobó 120 pruebas. Para reproducirla con el catálogo local aislado de la red, ejecuta `flutter test --no-pub --dart-define=RP_MUSIC_THEME_CATALOG= --reporter expanded`. Incluye persistencia y recuperación de biblioteca, favoritos y listas, sincronización de letras, limpieza de resultados con origen en línea, migración de listas automáticas y temas en 360 y 1280 píxeles. El análisis de Dart quedó limpio.

Android universal y ARM64 se compilaron y firmaron con la identidad de distribución. Windows x64 se compiló en release y el ZIP contiene 34 archivos con sus dependencias, guías y licencias. Se verificaron versión 0.4.0+30, arquitecturas, firmas y hashes de los adjuntos. Esta comprobación no sustituye los recorridos en un dispositivo.

## Recorrido pendiente en Android y Windows

1. Instala en un perfil de prueba limpio y selecciona una carpeta con música. Comprueba biblioteca, búsqueda, favoritos y listas.
2. Actualiza una instalación anterior conservando una copia de seguridad de los datos. Confirma que biblioteca, favoritos, listas, preferencias y portadas estén disponibles.
3. Reproduce una canción local con el dispositivo sin conexión. Cambia rápidamente entre pistas, pausa, reanuda y usa anterior/siguiente.
4. Conecta audífonos, bloquea la pantalla y comprueba los controles multimedia. En Android, revisa el widget y el comportamiento al desconectar los audífonos. En Windows, revisa bandeja y salida de audio.
5. Abre una letra incrustada sincronizada y otra importada manualmente. Comprueba avance, retroceso y cambio de canción. Las letras descargadas con marca de origen deben haber desaparecido del almacenamiento privado.
6. En Temas, descarga Minimalista del catálogo, cambia entre claro y oscuro, recorre todas las secciones y reinicia. Debe conservarse el tema elegido. Repite sin conexión después de instalarlo.
7. Importa la plantilla de prueba, vuelve al aspecto RP Music y quita el tema. Un archivo incompatible debe mostrar un mensaje y conservar el tema anterior.
8. En Android, comprueba la instalación sobre la versión anterior y el resultado real de Play Protect. Realiza una escucha prolongada en las condiciones habituales del usuario.

Las versiones antiguas se retirarán después de confirmar que la nueva satisface estas pruebas reales.

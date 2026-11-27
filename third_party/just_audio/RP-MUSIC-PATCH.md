# Cambios de RP Music en just_audio 0.10.6

La copia incluye el código distribuible de [just_audio 0.10.6](https://pub.dev/packages/just_audio/versions/0.10.6), el historial y el README de origen. `LICENSE` conserva la licencia MIT del plugin y la Apache-2.0 de ExoPlayer.

- `AudioPlayer.java` usa la salida estándar de Media3 en el candidato de recuperación Android y añade el tipo y el primer marco de las excepciones inesperadas al diagnóstico.
- La integración de `AndroidEqualizer` tolera errores de inicialización del efecto opcional para que el reproductor pueda cargar audio en dispositivos que no lo admiten.
- `RpEqualizerProcessor.java` aplica las bandas gráficas y paramétricas, la ganancia previa, el balance estéreo y el limitador de picos. Cada reproductor tiene su propio historial de filtrado.
- `JustAudioPlugin.java` recibe los ajustes por un canal local que también permite consultar las frecuencias de un ecualizador Android anterior para migrar su curva.

Los cambios están en el código Android. El código Dart y el de Darwin proceden de la versión publicada.

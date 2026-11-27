# Cambios de RP Music en just_audio 0.10.6

La copia incluye el código distribuible de [just_audio 0.10.6](https://pub.dev/packages/just_audio/versions/0.10.6), el historial y el README de origen. `LICENSE` conserva la licencia MIT del plugin y la Apache-2.0 de ExoPlayer.

- `AudioPlayer.java` instala un procesador PCM en la cadena Media3 de Android y elige una salida que permite procesar el audio decodificado.
- `RpEqualizerProcessor.java` aplica las bandas gráficas y paramétricas, la ganancia previa, el balance estéreo y el limitador de picos. Cada reproductor tiene su propio historial de filtrado.
- `JustAudioPlugin.java` recibe los ajustes por un canal local que también permite consultar las frecuencias de un ecualizador Android anterior para migrar su curva.

Los cambios están en el código Android. El código Dart y el de Darwin proceden de la versión publicada.

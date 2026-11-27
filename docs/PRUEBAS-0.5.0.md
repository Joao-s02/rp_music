# Pruebas de RP Music 0.5.0 Beta

## Verificación automatizada

- `flutter analyze --no-pub` pasó. La prueba específica del ecualizador pasó al comprobar que los modos Básico y Avanzado comparten las ganancias. Las pruebas de navegación del candidato cubren los anchos de 360 y 1280 píxeles.
- La suite de 0.5.0 registró 129 pruebas aprobadas y 15 fallidas. Al repetirla en el código de 0.4.9 con el mismo SDK, se reprodujeron los mismos 15 fallos y pasaron 128 pruebas. La suite completa sigue con fallos.
- Se compilaron los APK universal y ARM64 del código 44 y se verificó su firma. Windows x64 se compiló como 0.5.0+44.

## Validación en dispositivos pendiente

1. Actualiza desde 0.4.9 y comprueba que se conservan la biblioteca, los favoritos, las listas y el tema activo. En Windows, extrae el ZIP completo antes de abrir `rp_music.exe`.
2. Reproduce una canción y abre el ecualizador desde el menú del reproductor. Aplica Graves en el modo Básico y comprueba que el modo Avanzado muestra el cambio. Modifica una banda y vuelve a abrir la app para comprobar que se guardó el ajuste.
3. Abre Ajustes → Apariencia → Temas y vuelve atrás. Comprueba que regresas a Ajustes y que el tema activo sigue aplicado al reproductor.
4. En Android, verifica la notificación y los controles de reproducción en segundo plano y comprueba que la instalación se completa en tu dispositivo.

# Referencias de interfaz

El ZIP aportado por el usuario se conserva extraído en `reference/`. PNG/HTML/DESIGN.md son referencias visuales: no se ejecutan sus scripts ni se incorporan sus canciones, imágenes remotas, cuentas o estadísticas de muestra a la app.

La implementación Flutter mantiene la identidad A y las funciones reales de la biblioteca; la interfaz no declara DSP, bit-perfect, DAC exclusivo, ecualizador, temporizador, letras ni historial que todavía no existen. El tema claro y las extensiones declarativas existentes se conservan.

`verification/` contiene capturas de la interfaz Flutter con datos sintéticos de pruebas a 360/1280 px y texto 130 %. Regenerar con `$env:RP_UI_SNAPSHOTS='1'; flutter test test/redesign_test.dart --no-pub`. Las fuentes Inter y Plus Jakarta Sans están incluidas en assets/fonts con sus licencias OFL, descargadas del repositorio oficial google/fonts.

Evidencia de notificación, estado de compilaciones y pendientes: `../boveda/16 Pruebas 0.2.2 y rediseno 0.2.3.md`.

La referencia de biblioteca vacía fue confirmada nuevamente para 0.2.4. La implementación incluye lupa expandible, ondas, explicación local, contador real y accesos orientativos al selector. Captura nativa en verification/android-0.2.4-empty.png. Los números de biblioteca/almacenamiento y perfil del mock no son datos reales que deban copiarse. Ver la nota 18 de la bóveda para validación.

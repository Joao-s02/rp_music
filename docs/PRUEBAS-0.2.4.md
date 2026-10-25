# RP Music 0.2.4 — prueba local

Incluye actualizaciones opcionales, correcciones de búsqueda/segundo plano, diagnóstico copiable y nueva biblioteca vacía. Distribución preliminar: [v0.2.4-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.4-alpha.1).

## Instalar y conservar datos

Actualiza sobre 0.2.3 sin desinstalar. El paquete y certificado se mantienen, y biblioteca/listas/favoritos usan el formato anterior. Ambos APK son 0.2.4+6:

- `RP-Music-0.2.4-android-arm64.apk`: para Galaxy A34 y Poco X6, más pequeño.
- `RP-Music-0.2.4-android.apk`: universal.
- Windows: extrae todo `RP-Music-0.2.4-windows-x64.zip` y abre `rp_music.exe` junto a sus DLL y data.

La primera versión con actualizador debe instalarse así: 0.2.3 no tiene la función. La firma Android sigue siendo de desarrollo.

## 1. Búsqueda móvil

Pulsa la lupa de Biblioteca. Debe expandirse y abrir el teclado sin cerrarlo inmediatamente. Escribe varias letras, borra y prueba con teclado abierto/cerrado. Cierra la búsqueda desde la X. Comprueba también con tamaño de texto aumentado.

La biblioteca vacía muestra cero pistas reales y Elegir carpeta. Las tarjetas Music/SD abren el selector del sistema: elige allí una carpeta disponible; no otorgan acceso automáticamente ni indican espacio libre inventado.

## 2. Reproducción en segundo plano

Reproduce una lista de varias canciones, pulsa Inicio y apaga la pantalla. Como prueba sugerida, escucha al menos veinte minutos incluyendo varios cambios automáticos. Prueba pausa/reanudación desde notificación y anterior/siguiente.

Pausar conserva el servicio preparado, liberando el bloqueo de CPU de la reproducción; Detener en el reproductor completo libera además el servicio y la notificación. Si One UI/HyperOS mantiene restricciones adicionales, se puede revisar batería desde Ajustes de RP Music. No se concede una exención automáticamente.

Si vuelve a cortarse, no cierres la app antes de copiar/exportar el diagnóstico. Indica modelo, versión Android, cuánto tiempo pasó, si la pantalla estaba apagada y si ocurrió al cambiar de canción.

## 3. Diagnóstico y logs

En Ajustes → Diagnóstico multimedia:

- **Copiar texto** copia el informe completo con el último error y eventos recientes.
- **Exportar log** permite guardar un TXT en la ubicación elegida.
- **Importar log** abre un TXT/LOG de hasta 256 KB para leerlo; no ejecuta su contenido ni lo envía a internet.
- **Actualizar** vuelve al informe actual.

El registro conserva los últimos cien eventos de esta sesión. Incluye datos técnicos del dispositivo, estados e índices; revisa el texto antes de compartirlo. Un cierre forzado puede perder el registro no exportado.

## 4. Actualizaciones

En Ajustes → Actualizaciones, prueba desactivar/reactivar la consulta automática, incluir/excluir versiones de prueba y Buscar actualizaciones. La consulta automática se limita a una vez al día y no impide abrir la biblioteca si falla la conexión. Las versiones de prueba están activadas por defecto mientras se distribuyen alfas.

Solo aparece una actualización si existe una release compatible posterior en GitHub. Hasta publicar otra posterior a esta, no tiene por qué aparecer ninguna oferta. No se crean versiones de muestra públicas para esta prueba.

Cuando exista una nueva versión: revisa novedades/tamaño, pulsa Descargar, comprueba progreso y cancelación, y después Instalar actualización. Android puede pedir habilitar RP Music como fuente; al volver, pulsa Instalar de nuevo y confirma en el instalador. Se verifican integridad, paquete, versión superior y certificado antes de abrirlo. No hay instalación silenciosa.

Windows ofrece consulta y enlace a la descarga; no reemplaza automáticamente el programa abierto.

## Evidencia y límites

42 pruebas automatizadas aprobadas y análisis limpio. En emulador API 37 se comprobó cambio automático en segundo plano, pausa/reanudación y liberación al detener, tanto en debug como mediante sonda release. El teclado del APK final aceptó texto con foco y teclado visibles. La validación nativa rechazó hash/versión incorrectos y aceptó un APK real de prueba del mismo certificado con código superior antes de pedir permiso de fuente.

Falta retesteo prolongado en Galaxy A34 5G Android 16/Poco X6 y una actualización completa entre dos releases públicas futuras, con aceptación del instalador y comprobación de datos conservados. Los pendientes anteriores de instalación Tecno y cierre subjetivo Windows se mantienen.

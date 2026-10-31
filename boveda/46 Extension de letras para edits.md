---
tipo: entrevista-y-propuesta
estado: desarrollo-local-en-verificacion
actualizado: 2026-10-30
---
# Extension de letras para edits

## Decisión vigente e implementación local — 2026-10-30

### Validación física posterior en A34

Usuario conecta Samsung Galaxy A34 (SM-A346M), Android16/API36, y autoriza las pruebas. RP Music se actualiza por ADB de0.3.16+25 a0.3.17+26 sin desinstalar; fecha inicial de instalación conservada y biblioteca visible sin reconfiguración. RP Edits no estaba instalado antes de esta prueba.

Nueve pruebas instrumentales finales aprobadas en23.937s y diez unitarias/lint sin errores. Matriz seis proporciones/calidades con audio, tiempos, dimensiones visibles y30fps reales; bucle de vídeo, cancelación, foto/desenfoque/movimiento con audio completo12s, render/marca, persistencia, respaldo/plantilla, rutas y ambas orientaciones. Se corrigieron el ritmo del bucle (primera ejecución7/8) y la opacidad de la foto entre fotogramas (ampliación8/9). Media3 del editor fijado en1.11.1; no cambia dependencias del reproductor. Para esta primera versión, vídeos de fondo limitados a30fps/29.97 nominal, con comprobación al importar; fotos sin esa restricción.

APK release R8 firmado corregido instalado; apertura real desde Letras → Crear un edit → RP Edits comprobada con pista local. Edición0–5s, texto permanente y marca desactivada verificada. Selector Android guarda un MP4 nuevo en Descargas: `RP-Edits-prueba-A34-20261030.mp4`,3,285,004bytes,5026ms, audio y150cuadros a30fps; presentación720×1280, codificación1280×720 más rotación. El vídeo con música del usuario no se sube a Git ni se guarda en la bóveda. Proyectos sintéticos identificados y paquete de pruebas retirados; proyecto de prueba real conservado. Originales musicales sin escritura por parte del editor.

APK corregido SHA256 `32a8eac6bfbee6d8df2a7c7cd2a40656631364f8029462af39f96cc094ffb94e`. Sin emulador ni compiladores persistentes. Candidatos locales comprobados en ese A34; otras marcas/versiones Android, usos prolongados y port Windows pendientes. No publicados como release ni confirmación humana del usuario sobre toda la experiencia. Esta fase sustituye los pendientes físicos de la fase inicial siguiente únicamente con el alcance indicado.

Correcciones y evidencia guardadas/enviadas exclusivamente al repositorio privado de RP Edits, commit `66461f7`. Principal sin commit/push ni release nueva en este trabajo.

### Cierre de esta fase local

Código inicial de RP Edits guardado y enviado únicamente a su repositorio privado, commit `676f7b1`. No se publica release ni se envía RP Music. Candidato del editor firmado `RP-Edits-0.1.0-android.apk`, aproximadamente1.9MB, SHA256 `648ba53057cb9a185a3ff13a2ba3387f51a6ab79f69ec427d223a069fd492809`; compilación debug/release con R8, diez unitarias y lint sin errores en el perfil1536MiB/un trabajador. Separados modelo, datos/importación/respaldo, renderer, exportación, layout, controles y diálogos de tiempos. Las letras usan reloj global de composición; prueba final del vídeo en bucle/fps/cancelación preparada, no ejecutada en este APK final.

RP Music0.3.17+26: análisis final limpio; APK normal release compilado166.2s (70.7MB), firmado/verificado con perfil sin instalador y transición de certificados. Candidato en `dist/editor-candidate`, no publicado. Suite previa165 aprobadas/una omitida mantiene alcance sobre la integración; sin compilación nueva de Windows, editor/lanzador Windows pendientes.

La imagen API37 fuerza4096MiB aunque se pidan1024MiB y no terminó su proceso con el cierre normal. Se finalizó el proceso propio y se comprobó después que no quedaban Java/emulador/QEMU; muestra de RAM disponible8.9GB. No volver a abrir esa imagen para esta tarea en este equipo. Compilaciones finales ejecutadas de una en una y sin procesos persistentes. Se solicitó Android por USB para completar integración y pruebas físicas sin emulador; no hay teléfono conectado al cerrar esta fase. **Primera versión estable todavía no declarada**: entrega local de candidatos con validación física/integración final pendientes.

El usuario acepta el APK complementario y exige una primera versión cuidada, modular y comprobada porque no prevé actualizarla con frecuencia. Después solicita repositorio propio: se crea **https://github.com/Joao-s02/rp_edits**, privado, y se traslada el código a `C:/joao/flutter/music_reprod/rp_edits`. Esto sustituye para este editor la ubicación inicial en rp-music-extensions y la decisión pendiente de instalación descritas como antecedentes abajo.

Desarrollo inicial RP Edits0.1.0: Kotlin Android con modelo JSON portable, persistencia/importación/archivos de respaldo separados, renderer Canvas compartido, Media3 como adaptador de exportación y controles de edición separados. Android8+ (API26) para el editor; no cambia el mínimo Android de RP Music. Host candidato0.3.17+26 con contrato de solicitud común y adaptador Android que descubre complementos instalados con protocolo compatible y firma coincidente. Windows conserva contrato y pantalla de disponibilidad, sin editor ni lanzador Windows implementado todavía. No se agrega Media3 ni recursos del editor al anfitrión.

Verificación intermedia: diez pruebas unitarias del editor, APK debug y lint Android sin errores; seis exportaciones1:1/9:16/16:9 en720/1080 con audio y letras cambiantes verificadas en emulador API37 (fragmento1500ms, contenedor1520ms). El MP4 vertical usa orientación de presentación; no confundir anchura codificada con la visible. Render determinista/marca opcional y recuperación AtomicFile comprobados. RP Music:165 pruebas aprobadas/una optativa omitida, análisis sin incidencias; la primera ejecución carecía de DLL QuickJS en PATH, corregido sin modificar el motor. Copias/rotación en verificación ampliada: rechazo de traversal funciona y la prueba requiere aceptar también ZipException emitida por Android antes del validador propio. No afirmar cierre de toda la suite ampliada aún.

Instalación debug del host sobre0.3.15 del emulador rechazada por firmas diferentes; datos existentes conservados, sin desinstalar. Integración completa pendiente de candidatos con firma compatible. Sin prueba física ni release del editor. Historial de investigación/entrevista conservado abajo.

## Solicitud confirmada

El usuario propone un editor opcional mediante extensión para mantener el reproductor sencillo y evitar sobrecargar su visión. Desea acceso desde Letras, fondo con imagen de galería, tamaño y fuente de letras personalizables, desplazamiento y animaciones seleccionables, alternativas con portada/letras sincronizadas, posición ajustable y textos libres colocados por el usuario.

Desea exportación opcional de vídeo, opción sin la marca RP Music, calidad seleccionable y diferentes proporciones. Menciona 4x4 y 9:11 como ejemplos: confirmar si son proporciones literales o si se refiere a cuadrado/vertical habituales. Solicita profundizar mediante preguntas antes de implementar.

## Contexto comprobado y límites

Se revisaron [[04 Extensiones]], [[31 Arquitectura vigente]], [[10 Estado del repositorio]] y [[41 Letras dinamicas y reproductor fijo 0.3.12]], además de permisos/slots en program_package.dart. La vista Escena existente no equivale a exportación de vídeo. El contrato actual no ofrece un editor audiovisual/exportador: requerirá investigación y probablemente capacidades genéricas nuevas en el anfitrión. Separar una extensión no garantiza eliminar el peso de un codificador nativo; distribución, tamaño y carga bajo demanda quedan por estudiar.

La lógica, recursos, pruebas y paquetes específicos deben vivir en rp-music-extensions. La app solo incorporaría soporte genérico necesario, sujeto al diseño posterior. No se ha elegido motor, dependencia, API nueva ni método de exportación. Música original intacta; proyectos y resultados independientes como propuesta coherente con la política vigente.

## Respuestas confirmadas — 2026-10-30

El usuario aclara que el peso de la extensión no es un problema. El objetivo es que quienes solo escuchan/descargan música no instalen el editor ni sus componentes pesados. Esto reemplaza la interpretación inicial de optimizar el peso total del editor.

1. Editor Android primero; Windows después. Cambios genéricos necesarios en la app deben contemplar ambas plataformas desde el comienzo, para facilitar el port.
2. Fragmentos y canción completa a elección; vídeo siempre con el audio seleccionado.
3. Cuatro modos iniciales imprescindibles: frase que cambia, varias líneas desplazándose, palabras apareciendo y resaltado karaoke.
4. Ajuste manual de sincronización permitido. Tiempos por palabra no se deben inferir como precisión real a partir de tiempos por línea.
5. Mover, redimensionar, girar letras/textos y controlar aparición/desaparición de letras. Los textos libres añadidos duran todo el vídeo.
6. Imagen de galería, portada, color/degradado, desenfoque, oscurecimiento y movimiento suave. Intentar vídeo de fondo desde el inicio; se acepta posponerlo si dificulta la entrega.
7. Proporciones 1:1, 9:16 y 16:9; 720p/1080p, ambas a 30 fps.
8. Proyectos, plantillas y borradores; interruptor libre para mostrar/ocultar RP Music.

## Integración pendiente de decisión

Se consulta si acepta un APK complementario opcional, abierto desde Letras. El usuario pide primero explicar su funcionamiento; **no ha aceptado ese formato**. Un APK complementario sería otra aplicación instalada, con almacenamiento/permisos y actualización propios; no un .rpmx ni una simple pantalla del proceso principal. La integración mediante acciones explícitas de Android y acceso temporal a archivos es una propuesta, no código comprobado. Windows necesitaría su implementación equivalente, manteniendo un contrato de proyecto común.

Investigación primaria del 2026-10-30:

- Media3 Composition admite secuencias de audio, imágenes y vídeo: https://developer.android.com/media/media3/transformer/composition . Candidato para prueba Android, sin garantizar aún animaciones ni exportación en equipos concretos.
- Transformer ofrece recorte, imagen con duración/fps y selección H.264/AAC: https://developer.android.com/media/media3/transformer/transformations . MP4 por defecto y codificación dependiente de MediaCodec/dispositivo: https://developer.android.com/media/media3/transformer/supported-formats .
- Android permite abrir componentes de otras aplicaciones con intents explícitos: https://developer.android.com/guide/components/intents-filters . Compartir originales sin modificarlos y transferir solo archivos autorizados requeriría implementación y pruebas.
- Componentes diferidos Flutter Android se construyen con la aplicación completa y AAB; la guía estándar usa Play Core/Play Store: https://docs.flutter.dev/perf/deferred-components . No equivale al catálogo .rpmx ni resuelve automáticamente distribución opcional por APK/GitHub.

No elegir todavía arquitectura de instalación ni añadir dependencias audiovisuales a la app base. Primero explicar alternativas y resolver la preferencia del usuario.

## Preguntas iniciales conservadas como antecedente

- Plataforma inicial y prioridad entre Android y Windows.
- Fragmentos frente a canción completa; audio incluido y fuentes locales/remotas.
- Animación por línea frente a palabra; tiempos disponibles y edición manual de sincronización.
- Fondo estático inicialmente o también vídeo; complejidad del editor y textos por intervalos.
- Proporciones, resoluciones, cuadros por segundo y exportación sin marca.
- Guardar proyectos, reutilizar plantillas y punto de entrada desde Letras.

Propuesta de experiencia, sin aprobación aún: Letras → Crear edit → elegir fragmento → personalizar lienzo → previsualizar → exportar. Las respuestas determinarán la primera versión y una prueba técnica de exportación antes de prometer formatos o rendimiento.

## Verificación

Solo lectura del contexto/código y registro documental. Sin cambios funcionales, compilaciones, pruebas de vídeo ni publicación. README revisado: conserva capacidades publicadas; no se anuncia esta propuesta como disponible.

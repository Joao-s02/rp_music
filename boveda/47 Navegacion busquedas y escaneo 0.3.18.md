---
tipo: entrega-y-evidencia
estado: publicado-con-validacion-y-limites
actualizado: 2026-10-31
---
# Navegacion busquedas y escaneo 0.3.18

## Alcance autorizado

Cuatro cambios: separación y cabecera desplazable de fuentes; Atrás en álbum local; conservar búsqueda al navegar; optimizar la carga de raíz Android (500/900 canciones según el usuario). Reutilizar el host y no modificar funciones ajenas. Compilados y release completa solicitados en esta conversación. Se conservan A01 e integración previa RP Edits; no se reintroduce A02. Sin cambios en repositorios externos.

## Implementación

ListView único y bajo demanda para controles y resultados de fuentes Dart, con mayor relleno/separación y teclado plegable por arrastre. Historial por colección para Atrás; PopScope en detalle local. ExtensionViewCache pertenece a ProgramController y limita ocho pantallas/30min; fuente limita resultados e historial. Fuentes y pantallas JS conservan estado/desplazamiento durante esta sesión, sin persistencia ni ejecución de acciones/audio al restaurar. Identidad de paquete y revisión de permisos invalidan resultados.

ScanProgress incorpora append para descubrimiento incremental; el controlador combina por ID sin perder el catálogo estable de respaldo. Android publica lotes durante recorrido SAF, reutiliza huellas/tags en esa primera fase, solo programa faltantes y recoge resultados terminados con dos trabajadores. Lotes de 128 o 160ms para metadatos. Windows comparte descubrimiento incremental/lotes, sin cambiar el motor. Esquemas/formatos/permisos y música original intactos.

## Evidencia

Análisis limpio (salida 0); suite completa con 181 aprobadas, cero fallidas y una optativa omitida (paquete externo de metadatos no suministrado), salida 0. 50 PNG previos preservados. Pruebas enfocadas adicionales de JS/fuentes aprobadas; verificación final adicional de posición de desplazamiento, navegación y JS: 13 aprobadas, salida 0; análisis final limpio, salida 0. Pruebas nuevas con fixtures genéricos y 500/900 archivos, navegación Atrás y restauración a 360/1280 con texto 1.6. Primeras pruebas detectaron errores de preparación del fixture (separadores Windows, tamaño de pantalla y ejecución asíncrona); corregidos sin ocultarlos como resultados de producto. Sin benchmark Android físico, instalación o Play Protect nuevo.

## Entrega

Aplicación 0.3.18+27, tag v0.3.18-alpha.1. Android universal y ARM64 normales compilados y firmados con identidad/linaje existentes, sin REQUEST_INSTALL_PACKAGES; Windows release normal compilado. Las tres operaciones finalizaron con salida 0. Sin instalación ni prueba física nueva. Borrador y publicación pública comprobados. Universal, ARM64, Windows completo, USO/PRUEBAS/CAMBIOS/SHA256 requeridos por [[27 Publicacion de releases - contenido obligatorio]]. [Uso](../docs/USO-0.3.18.md), [cambios](../docs/CAMBIOS-0.3.18.md), [pruebas](../docs/PRUEBAS-0.3.18.md).

## Publicación comprobada — 2026-10-31

0.3.18-alpha.1 publicada, app 0.3.18+27. ReleaseID 430101996; tag/código 45a2e25bcc9707243258b1998de82ebb6a73166b. Android universal y ARM64 firmados con identidad/linaje compatibles y sin permiso de instalar paquetes; Windows completo con 32 archivos/licencias/guías. Siete adjuntos comprobados en borrador y públicamente por tamaño/SHA-256, tag al commit correcto y manifiesto descargado idéntico. Análisis limpio; suite completa 181 aprobadas/cero fallidas/una optativa omitida, salida 0. Verificación final adicional de navegación/desplazamiento/JS: 13 aprobadas, salida 0. Sin prueba física nueva, benchmark Android ni validación nueva de Play Protect. No se modificó el catálogo ni los proveedores. Detalles y pendientes: [[47 Navegacion busquedas y escaneo 0.3.18]].

[Release pública](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.18-alpha.1). Las fases anteriores conservan su alcance histórico.

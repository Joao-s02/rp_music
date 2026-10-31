---
tipo: entrega-y-evidencia
estado: candidato-local
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

Aplicación 0.3.18+27, tag previsto v0.3.18-alpha.1. Android universal y ARM64 normales compilados y firmados con identidad/linaje existentes, sin REQUEST_INSTALL_PACKAGES; Windows release normal compilado. Las tres operaciones finalizaron con salida 0. Sin instalación ni prueba física nueva. Publicación pendiente de empaquetado y comprobación del borrador. Universal, ARM64, Windows completo, USO/PRUEBAS/CAMBIOS/SHA256 requeridos por [[27 Publicacion de releases - contenido obligatorio]]. [Uso](../docs/USO-0.3.18.md), [cambios](../docs/CAMBIOS-0.3.18.md), [pruebas](../docs/PRUEBAS-0.3.18.md).

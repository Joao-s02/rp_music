---
tipo: distribucion
estado: preparando
actualizado: 2026-10-24
---
# Release 0.2.0-alpha.1

## Solicitud y autorización

El usuario solicitó publicar una release en su repositorio GitHub con APK, ejecutable Windows e instrucciones. Esa petición autoriza publicar los adjuntos y las fuentes correspondientes. No se modifica la release anterior.

Repositorio comprobado: `Joao-s02/rp_music`, remoto `origin`, rama predeterminada `main`. Antes de publicar, `HEAD` y `origin/main` coincidían. Release anterior observada: `v0.1.0alfa`.

## Preparación

- Versión de aplicación `0.2.0+2`; etiqueta de distribución `v0.2.0-alpha.1`, marcada preliminar por las funciones pendientes.
- Compilaciones solicitadas en modo release, en lugar de distribuir los debug de la primera prueba.
- Android conserva la firma de desarrollo configurada en el proyecto: no es una clave estable para tiendas.
- Windows se distribuye como ZIP con ejecutable, DLL y datos completos, no como EXE aislado.
- Guía en `docs/USO.md`, notas en `docs/releases/0.2.0-alpha.1.md` y ejemplo `descubrir.json`.
- `dist/` está ignorado por Git para no incorporar binarios al historial; los binarios se adjuntarán a la release.
- Se preparan sumas SHA-256 de los adjuntos.

## Publicación

Pendiente de completar y verificar. Registrar URL, commit etiquetado, compilaciones y adjuntos cuando GitHub confirme la publicación. No confundir este estado de preparación con una release ya disponible.

Relaciones: [[10 Estado del repositorio]], [[11 Reconstruccion - primera base]], [[09 Registro de cambios]].

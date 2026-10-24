---
tipo: distribucion
estado: publicada-y-verificada
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

Publicada el 2026-10-24: [RP Music 0.2.0-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.0-alpha.1).

- GitHub confirma `isDraft=false`, `isPrerelease=true`.
- Etiqueta `v0.2.0-alpha.1` en commit `bdd01f012e3f6e8e61ac13ad6565ce32911beae8`. Las fuentes de la reconstrucción y las instrucciones se publicaron en `main`; las actualizaciones de esta nota son posteriores a la etiqueta.
- Compilaciones release Android y Windows completadas. Android: APK de 54 203 100 bytes; Windows: ZIP de 12 740 958 bytes.
- Adjuntos confirmados en estado `uploaded`: APK, ZIP, `USO.md`, `descubrir.json` y `SHA256SUMS.txt`.
- Se comprobó que el ZIP contiene EXE, DLL del motor Flutter y audio, `data/icudtl.dat`, guía y ejemplo. Se comprobó la estructura del APK.
- Los digest SHA-256 y tamaños informados por GitHub coinciden con los archivos locales. No se descargaron nuevamente los binarios ni se probaron en un equipo limpio.
- SHA-256 APK: `e69f72cd5aa2f19cceb6dead44c97edc9da9cd2c603b33c330aac4de90c548b6`.
- SHA-256 ZIP: `37c12adec28863fe0ab4d2a8e99333175559f123cc49a9476dde3a538186f2fd`.
- No se reemplazó la release anterior. Se excluyeron del versionado los archivos temporales de sesión de Kotlin.

Relaciones: [[10 Estado del repositorio]], [[11 Reconstruccion - primera base]], [[09 Registro de cambios]].

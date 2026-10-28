# RP Music 0.3.6-alpha.1 — corrección de descargas M4A

Corrige un fallo de 0.3.5 al añadir etiquetas a MP4/M4A fragmentados: la información de inicialización quedaba detrás del audio y algunos lectores no podían interpretarlo. Ahora se conserva delante de los fragmentos, sin recodificar audio. Las estructuras no soportadas conservan el audio original con aviso.

**Descargas:** Android universal/global, ARM64 y Windows x64 portable completo. App 0.3.6+15; instalar Android encima sin desinstalar. Windows requiere todo el ZIP.

**Extensiones sin cambios:** YouTube Android 0.4.0 y Letras locales 0.1.0 siguen siendo compatibles. Se instalan desde https://github.com/Joao-s02/rp-music-extensions ; no se adjuntan a la app.

**Archivos anteriores:** actualizar no los reescribe automáticamente. Usar copia reparada o volver a descargar con la app actualizada. Ninguna canción privada se incluye en esta release.

**Verificación:** 110 pruebas aprobadas y análisis limpio de cambios. Una copia del archivo real se reparó y decodificó conservando todos sus bloques de audio; también pasó un M4A fragmentado sintético. Falta validar el arreglo y la biblioteca/selector en Android físico. YouTube Windows conserva límites previos.

Siete adjuntos: universal, ARM64, Windows, USO.md, PRUEBAS-0.3.6.md, CAMBIOS-0.3.6.md y SHA256SUMS.txt. Ver guías para pruebas pendientes y límites.

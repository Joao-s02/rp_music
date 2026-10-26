# Release 0.3.0-alpha.1

Fecha: 2026-10-26. Estado: publicada y adjuntos verificados.

El usuario autorizó publicar 0.3.0 mientras prueba 0.3.1. Se prepara una copia separada desde el último commit publicado más los cambios de extensiones API 2 y catálogo, excluyendo fuente/capacidad/permiso/dependencias/pruebas de YouTube de 0.3.1. La copia de trabajo 0.3.1 y sus APK/paquete se conservan.

Incluye Biblioteca viva, Pulso nocturno, listas manuales/automáticas y carátulas, permisos, varias activas, modo seguro e instalación desde archivo/GitHub. Se conserva el ajuste solicitado de estado Instalada/Actualizar. Por ello los binarios de publicación se recompilan desde esta copia y no se reutilizan los APK/ZIP viejos de catálogo que precedían ese ajuste.

Versionado: 0.3.0+9, tag v0.3.0-alpha.1, prerelease. YouTube Music requiere 0.3.1 Android y no forma parte de esta release; el catálogo separado puede mostrar ese paquete futuro, cuya descripción indica el requisito. No se concedió red a programas en esta versión.

Preparación verificada: análisis limpio. Pruebas, compilaciones, firma, adjuntos y publicación se confirman al cierre. Relaciones: [[23 Extensiones programables - primer prototipo]], [[09 Registro de cambios]], [[10 Estado del repositorio]].


Candidato final verificado: 68 pruebas aprobadas, análisis limpio (repetido tras separación final), prueba nativa Windows aprobada y dos UI repetidas a 360/1280 aprobadas. Windows release, APK universal y ARM64 reconstruidos desde esta copia. APK 0.3.0+9, firma eba2769ed11d359c8f89f6991bc6867c7766f6f46a4295bc5386e7d41ce7d38d, recursos multimedia y ZIP alignment 16 KB verificados. Sin .rpmx embebidos, integration_test, sondas ni permiso network.youtube. Windows EXE 0.3.0+9 y ZIP con DLL/data/guía verificados.

Adjuntos preparados en dist/0.3.0-release:

- descubrir.json: 302 bytes; SHA-256 76084eb69679570de96816966eed12edae84e09c79021931025b1738f5930b16
- PRUEBAS-0.3.0.md: 4803 bytes; SHA-256 6536c316b2cbed1c4cb0762ae44c6b9e1a361c4ba7bd47d9fd447e870049a017
- RP-Music-0.3.0-android-arm64.apk: 24854934 bytes; SHA-256 fc292b391ce12b456b2418c05512cf1b78cd44f35895a79024eb11d99c5a0718
- RP-Music-0.3.0-android.apk: 67313840 bytes; SHA-256 c0265c15eaad75c8c29d1b192505ac817411642b26c9beeb7bb9707789151e33
- RP-Music-0.3.0-windows-x64.zip: 15440012 bytes; SHA-256 85abdfc716360a0a659e1496d95547c12e9613b1ff277ecb682706d8b8c659ed
- USO.md: 2077 bytes; SHA-256 e6b47959359f9c7716cde18f3848759a2fdaa69066c0bd455fe6bbc9cf928dae
- SHA256SUMS.txt: 532 bytes; SHA-256 f97ad9423460101dd832590ad5eaf3b144685e023ec1deb248c9f4ada50d68af


## Publicación confirmada

v0.3.0-alpha.1 publicada como prerelease el 2026-10-26. URL: https://github.com/Joao-s02/rp_music/releases/tag/v0.3.0-alpha.1 . Código etiquetado: f7b143ac1f9a81137f0fee2be5646e5b945a71f1. Borrador desactivado, siete adjuntos remotos comprobados uno a uno con tamaño y SHA-256 iguales a los archivos locales. La app 0.3.1 y su integración YouTube siguen fuera de esta release.

Se publican los nuevos binarios de dist/0.3.0-release, no los viejos de dist/0.3.0-catalogo: los nuevos incorporan estado Instalada/Actualizar. Se conservan todos los paquetes anteriores. La fuente publicada no incluye dependencias ni adaptador de YouTube de 0.3.1. El working tree local se mantiene en 0.3.1 para continuar sus pruebas.

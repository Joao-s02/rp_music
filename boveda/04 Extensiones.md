---
tipo: requisitos-y-contratos
estado: vigente-con-limites-experimentales
actualizado: 2026-10-27
---
# Extensiones

## Visión y alcance confirmado

Añadir funciones y personalizar pantallas sin recompilar la app. Se aceptaron varias activas, permisos separados, niveles normal/avanzado, elección de conflictos, recuperación, instalación por archivo y catálogo por repositorio. Actualizaciones con aceptación, no silenciosas.

Biblioteca viva: filtros combinados, acciones, listas manuales/automáticas, carátulas propias/mosaico. Nivel avanzado deseado: reemplazar reproductor, modificar aleatorio y reglas de listas. No equivale a acceso irrestricto ni a reorganizar código compilado de la base.

## Separación obligatoria de repositorios

**Toda nueva extensión se desarrolla/publica exclusivamente en https://github.com/Joao-s02/rp-music-extensions . Nunca en https://github.com/Joao-s02/rp_music .**

- Extensiones: fuentes/lógica específicas, parsers/clientes de servicios, paquetes .rpmx, recursos, documentación, pruebas particulares y catálogo.
- App: reproductor, SDK/motor, permisos/instalación, capacidades HTTP/UI genéricas y fixtures sintéticos mínimos del motor.
- No añadir extensiones nuevas como ejemplos/fixtures del principal, assets del APK/ZIP ni adjuntos de sus releases. Enlazar catálogo y compatibilidad.
- La lógica de fuente migró fuera de la app en 0.3.2. Material heredado de Biblioteca viva/Pulso en ejemplos/pruebas del principal sigue como deuda de migración; actualizar extensiones solo en su repositorio. No afirmar separación total ni borrar historia publicada.

## Implementación actual

API 1 declarativa conservada. API 2 ejecuta Dart mediante dart_eval y devuelve JSON a componentes Flutter del anfitrión, como elección técnica provisional. Máximo 16 programas instalados; permisos, propietario para biblioteca/reproductor/aleatorio/fuente, retorno a base y desactivación por fallos repetidos. Las reglas automáticas conservan su proveedor por lista, no un único propietario global de todas las listas. Listas/datos conservados para recuperación; reglas automáticas inactivas al desactivar proveedor.

Permisos: library.read, playback.control, playlists.manage, storage.private, behavior.override, network.http, navigation.add y storage.download (0.3.4). network.youtube se reconoce solo como antecedente que requiere actualizar paquete. Nivel avanzado no concede IO, procesos ni código nativo.

El programa filtra, decide siguiente pista y selecciona presentaciones definidas por contrato. La fuente elegida/autorizada declara icono/etiqueta, busca y resuelve audio por HTTP acotado. No hay widgets Flutter arbitrarios, edición del código compilado, colaboración general entre paquetes ni cuota dura de memoria. Métricas actuales: tiempo de llamada/fallos; no RAM/CPU/batería atribuida.

Formato y límites: [API 2](../docs/EXTENSIONES-API-2.md). Componentes/flujos: [[31 Arquitectura vigente]].

## Paquetes del catálogo para 0.3.5

| Paquete | Versión | Alcance |
| --- | --- | --- |
| YouTube Android | 0.4.0 | Búsqueda de letras corregida y metadatos/portada/letras para nuevas descargas. Retesteo físico/selector pendiente. |
| Letras locales | 0.1.0 | Búsqueda automática al seleccionar canción sin letra; caché privada, sin modificar música. |
| Biblioteca viva | 0.1.1 | Artistas colaboradores, filtros/acciones/listas automáticas. |
| Pulso nocturno | 0.1.0 | Disposición del reproductor y política de aleatorio por contrato avanzado. |

YouTube Windows 0.3.0 es candidato manual fuera del catálogo recomendado: sus pruebas nativas fallaron. No presentarlo como funcional. YouTube Android 0.4.0 y Letras locales 0.1.0 requieren app 0.3.5 y consentimiento de permisos.

Catálogo fija revisión Git, comprueba SHA-256 y muestra Descargar/Instalada/Actualizar. Conserva fuente 0.1.0 para app 0.3.1, 0.2.0 para 0.3.2 y 0.2.1 para 0.3.3; Biblioteca viva 0.1.0 para anteriores y 0.1.1 para 0.3.3+. Fuente 0.3.0 conservada para app 0.3.4. Spotify ya no se ofrece en el catálogo; su paquete histórico se conserva. Hash no acredita autoría; no hay firma/catálogo auditado obligatorio implementado.

## Integraciones y siguiente investigación

Vía no oficial experimental y prioridad Android aceptadas para primera fuente: solo audio, sin vídeo visible ni cuenta. Búsqueda/reproducción publicadas, no solo investigadas. Prueba física positiva de 0.3.1 y segundo plano se conservan como antecedentes en [[24 YouTube Music - definicion e investigacion]]. Ahora la fuente reside en su paquete, con transporte genérico del anfitrión.

Pendientes: Windows de esa fuente, cuentas, listas/favoritos/historial online, artistas/álbumes completos, ecualizador, interoperabilidad y aislamiento más fuerte. Ecualizador es próxima extensión deseada, sin especificación ni DSP implementados. Spotify cancelado por el usuario el 2026-10-27; su paquete publicado es antecedente y se retiró del catálogo con 0.3.5. Play Store cancelada; las condiciones de servicios externos requieren investigación específica vigente.

El 2026-10-27 el usuario confirma reproducción satisfactoria de YouTube Android y solicita priorizar metadatos completos en descargas, mediante otro servicio o complemento si hace falta. Requisito implementado/publicado para 0.3.5; decisiones y evidencia en [[33 Metadatos de descargas YouTube]].

Alcance posterior confirmado: enriquecer automáticamente nuevas descargas YouTube con letras incrustadas y corregir búsqueda de letras que falla en las canciones probadas por el usuario. Extensión aparte para buscar automáticamente letras faltantes en biblioteca local. Reconocer letras ya incrustadas corresponde a la base. Decisión posterior confirmada: solo caché privada, sin modificar archivos locales. [[33 Metadatos de descargas YouTube]].

Entrega 0.3.5: el usuario elige **solo caché privada**, sin editar música local. Nueva capacidad lyrics/permiso lyrics.cache y proveedor independiente de source. Candidatos externos YouTube Android 0.4.0 y Letras locales 0.1.0, minAppVersion 0.3.5. Catálogo publicado sin Spotify; paquetes históricos conservados. Evidencia y límites en [[33 Metadatos de descargas YouTube]].

Antecedentes: [[22 Extensiones - alcance del primer sistema]], [[23 Extensiones programables - primer prototipo]], [[28 Pruebas 0.3.1 y mejoras 0.3.2]], [[29 Pruebas 0.3.2 y mejoras 0.3.3]].

## Entrega 0.3.4

[[32 Pruebas 0.3.3 y mejoras 0.3.4]]: variantes YouTube separadas Android/Windows y Spotify de vistas previas públicas sin cuenta, exclusivamente en el repositorio externo. Android y Spotify vista previa están publicados en catálogo; Windows es candidato manual. No equivalen a Spotify completo. Núcleo añade storage.download, operación genérica de letras y múltiples accesos de fuente con elección explícita de propietario. Publicación de app 0.3.4 y hashes externos confirmados en la nota; variantes anteriores conservadas.

## Publicación 0.3.5 confirmada

App 0.3.5-alpha.1 publicada: https://github.com/Joao-s02/rp_music/releases/tag/v0.3.5-alpha.1. Catálogo público verificado con YouTube Android 0.4.0 y Letras locales 0.1.0 para anfitrión 0.3.5, Biblioteca viva 0.1.1 y Pulso nocturno 0.1.0. Spotify fuera del catálogo, variantes anteriores intactas. Nueva capacidad lyrics/permiso lyrics.cache con library.read/network.http; resultados locales solo en caché privada. El estado público no elimina las validaciones físicas pendientes. [[33 Metadatos de descargas YouTube]].

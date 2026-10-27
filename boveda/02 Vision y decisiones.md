---
tipo: requisitos
estado: vigente
actualizado: 2026-10-27
---
# Vision y decisiones

## Propósito confirmado

Reproductor local sencillo y fluido, personalizable por una comunidad mediante extensiones. Android y Windows prioritarios; web opcional y no soportada por la entrega actual. La visión completa no equivale al alcance publicado.

| Área | Decisión vigente |
| --- | --- |
| Tecnología | Flutter/Dart. Paquetes concretos son decisiones técnicas provisionales: [[31 Arquitectura vigente]]. |
| Base | Archivos de una raíz del dispositivo, uso musical sin cuenta y sin conexión. |
| Red opcional | Actualizaciones configurables y extensiones de fuentes en línea. |
| Distribución | Distribución oficial exclusivamente en el repositorio GitHub del usuario; Play Store cancelada por decisión expresa el 2026-10-27. Universal/ARM64/Windows con guías/hashes según [[27 Publicacion de releases - contenido obligatorio]]. |
| Licencia | Deseo de código abierto confirmado; licencia del proyecto sin elegir. No hay LICENSE en la raíz al revisar esta consolidación; se conservan licencias de recursos y dependencias. |
| Personalización | Instalar sin recompilar la app, con consentimiento para permisos/actualizaciones. Reiniciar es aceptable; no implica carga arbitraria de código nativo. |
| Rendimiento | Fluidez de biblioteca/audio; sin presupuestos numéricos acordados. |
| Documentación | Bóveda mantenida y README revisado en cada actualización, con estado/evidencia separados del historial. |

## Decisiones posteriores a la entrevista

La reconstrucción del alfa ya se ejecutó. La arquitectura provisional está implementada/publicada; no atribuir sus paquetes como elección del usuario en la entrevista. Antecedentes en [[11 Reconstruccion - primera base]] y [[09 Registro de cambios]].

Se aprobaron actualizador opcional, permisos/recuperación de extensiones, varias activas y catálogo por repositorio. Se aceptó priorizar Android para la primera fuente experimental sin cuenta; no se abandonó Windows de la app. Ecualizador reservado a futura extensión, no al núcleo.

## Dirección visual

Spotify, Samsung y Namida fueron referencias de experiencia. Después se eligió icono A/Nocturnal Pulse y se entregaron diseños concretos para biblioteca, álbum y reproductor. Tema y tipografías ya integrados: [[15 Identidad visual e icono]]. Una función dibujada no pasa a estar implementada por aparecer en la referencia.

Capacidades actuales: [[10 Estado del repositorio]]. Requisitos de audio/biblioteca: [[03 Biblioteca y reproduccion]]. Extensiones: [[04 Extensiones]]. Preguntas abiertas: [[07 Preguntas e investigacion]]. Origen inicial: [[08 Entrevista consolidada]].

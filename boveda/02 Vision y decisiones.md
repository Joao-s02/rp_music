---
tipo: requisitos
estado: confirmado
actualizado: 2026-10-24
---
# Vision y decisiones

## Propósito

Crear un reproductor de música para una comunidad que pueda personalizarlo. Una aplicación base sencilla y de apariencia sencilla debe cubrir las funciones habituales; las extensiones permiten ampliar sus capacidades según los recursos y preferencias de cada usuario.

## Decisiones confirmadas

| Área | Decisión |
| --- | --- |
| Tecnología principal | Flutter; el usuario conoce Dart y Flutter. |
| Plataformas prioritarias | Android y Windows. |
| Web | Opcional; no condiciona la primera entrega. |
| Contenido base | Archivos musicales del dispositivo. |
| Conectividad base | Uso musical completo sin internet y sin cuenta; comprobación opcional de actualizaciones planteada posteriormente, ver [[17 Actualizaciones opcionales desde la app]]. |
| Público | Comunidad interesada en personalizar el reproductor. |
| Licencia y distribución | Código abierto; publicación en Play Store deseada a futuro. Licencia concreta pendiente. |
| Prioridad de optimización | Interfaz fluida al abrir biblioteca, reproducir y cambiar canciones. |
| Extensiones | Instalables sin reinstalar ni recompilar toda la app; reiniciar tras instalar es aceptable. |
| Actualizaciones de extensiones | Solo con aceptación del usuario. |
| Código actual | El usuario quiere reemplazar la versión alfa y empezar de cero. |
| Documentación | Crear primero una bóveda y mantenerla con todo contexto importante futuro. |

## Referencias visuales

- Spotify: le gusta el reproductor, pero quiere más personalización.
- Reproductor de Samsung: también le gusta, con la misma limitación de personalización.
- Namida: aprecia la presentación de carátulas y la agrupación automática por álbum.

Estas referencias orientan la experiencia; no se ha aprobado una maqueta ni un diseño visual concreto.

## Límites de lo decidido

No están elegidos el motor de audio, gestor de estado, persistencia, runtime de extensiones, lenguaje de sus programas ni licencia. No hay metas numéricas de rendimiento aceptadas. Las integraciones con servicios son objetivos sujetos a investigación, no capacidades garantizadas.

Detalles: [[03 Biblioteca y reproduccion]], [[04 Extensiones]], [[05 Rendimiento]], [[07 Preguntas e investigacion]]. Origen: [[08 Entrevista consolidada]].

## Actualizaciones opcionales — 2026-10-25

El usuario plantea consultar versiones al inicio si hay internet y permitir descargar/actualizar desde la app. La reproducción local sigue sin depender de conexión. Viabilidad y flujo propuesto, todavía sin implementación, en [[17 Actualizaciones opcionales desde la app]]. Frecuencia, canal y activación predeterminada no están decididos.

Actualización 0.2.4: el usuario aprobó implementar la consulta opcional de versiones y sus controles. El uso musical sigue completo sin conexión/cuentas; la consulta automática diaria puede desactivarse. Implementación y límites en [[18 Pruebas 0.2.3 y correcciones 0.2.4]].

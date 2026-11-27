# Pruebas de RP Music 0.5.1 Beta

## Verificaciones previas

El análisis estático de los cambios pasó. Una sonda PCM verificó las operaciones del procesador de Android. Una prueba con la DLL de libmpv utilizada en 0.5.0 verificó las cadenas de filtros gráficos y paramétricos. Se comprobó el recorrido de ida y vuelta del JSON de perfiles. Flutter Test quedó bloqueado al conectar con su proceso local.

Windows x64 se compiló como 0.5.1+45 y se abrió desde el ZIP extraído. Se comprobaron el CRC del ZIP, sus dependencias principales y el hash de libmpv.

## Pruebas en Android y Windows

1. Actualiza una instalación anterior y abre tu biblioteca. Comprueba que conserva listas, favoritos, temas y ajustes.
2. Reproduce una canción y abre el ecualizador. Aplica un preajuste y arrastra un punto en Avanzado. Añade un filtro de 1000 Hz con ganancia y Q distintos y comprueba el cambio de sonido.
3. En Android, prueba preamplificación, balance con audífonos estéreo y limitador. Con la DLL habitual de Windows, comprueba que el panel informa que esos controles no están disponibles.
4. Guarda un perfil, expórtalo e impórtalo. Aplica el perfil y compara bandas y filtros.
5. Edita una cola corta y deja que termine. Pulsa «Reiniciar cola» y comprueba que comienza con la primera canción de la cola editada.
6. Activa Repetir todo y luego pruébalo con Aleatorio. Comprueba que inicia otra vuelta y que con canciones distintas evita repetir inmediatamente la última.
7. Durante una canción, usa **Cola → ⋮ → Mezclar cola**. La canción en curso continúa y cambia el orden de las pendientes.

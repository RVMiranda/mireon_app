# Prompt maestro — Aplicación Flutter de Galería Multimedia para Android e iOS

Quiero desarrollar una aplicación móvil multiplataforma utilizando **Flutter**, destinada inicialmente a Android e iOS.

La aplicación será una galería multimedia moderna, elegante, privada y enfocada especialmente en proporcionar una experiencia de reproducción de vídeo superior a la de una galería convencional.

La aplicación debe funcionar principalmente de manera local y offline, respetando estrictamente la privacidad del usuario.

No quiero una simple aplicación CRUD de fotografías. Quiero construir un producto de galería multimedia completo, con especial atención a:

* UX/UI.
* Reproducción de vídeo.
* Gestos.
* Navegación multimedia.
* Organización.
* Perfiles locales.
* Privacidad.
* Seguridad.
* Administración de archivos.

---

# 1. Objetivo general

Crear una aplicación de galería multimedia que permita:

* Visualizar fotografías.
* Reproducir vídeos.
* Navegar rápidamente entre elementos.
* Compartir archivos.
* Agregar contenido a favoritos.
* Eliminar contenido.
* Organizar contenido.
* Explorar carpetas.
* Ver la ubicación de los archivos.
* Crear y administrar perfiles locales.
* Ocultar contenido.
* Proteger perfiles mediante PIN o contraseña.
* Administrar archivos y carpetas.
* Comprimir y descomprimir archivos.
* Mover y copiar archivos.
* Proporcionar una experiencia avanzada de reproducción de vídeo.

La aplicación debe estar preparada inicialmente para:

* Android.
* iOS.

La arquitectura debe permitir incorporar posteriormente nuevas plataformas si resulta conveniente.

---

# 2. Filosofía del producto

La aplicación debe sentirse como un producto moderno y terminado.

Debe ser:

* Rápida.
* Elegante.
* Intuitiva.
* Minimalista.
* Privada.
* Fluida.
* Personalizable.
* Resistente a errores.
* Fácil de mantener.

La aplicación debe priorizar:

1. Privacidad.
2. UX.
3. Rendimiento.
4. Seguridad.
5. Arquitectura.
6. Compatibilidad multiplataforma.
7. Mantenibilidad.

---

# 3. Stack tecnológico

Utiliza Flutter y Dart modernos y estables.

Preferencias:

* Flutter estable.
* Dart estable.
* Material 3.
* Cupertino cuando resulte apropiado para iOS.
* Arquitectura Clean Architecture.
* MVVM o una variante equivalente bien estructurada.
* Repository Pattern.
* Dependency Injection.
* Async/Await.
* Streams cuando sean apropiados.
* Manejo reactivo del estado.

Para state management puedes utilizar una solución madura como:

* Riverpod.

Preferir Riverpod si no existe una razón técnica sólida para utilizar otra alternativa.

Para navegación:

* GoRouter.

Para persistencia local:

* Hive/Isar/SQLite/Drift según las necesidades reales del proyecto.

Para preferencias simples:

* SharedPreferences o una alternativa apropiada.

Para reproducción:

* Una solución compatible con Android e iOS y mantenida activamente.

Evalúa opciones como:

* video_player.
* ExoPlayer mediante integración cuando sea necesario.
* AVPlayer en iOS mediante plugins.
* Media3 en Android mediante plugins/integración nativa.

No acoples la lógica de negocio directamente al plugin de reproducción.

---

# 4. Arquitectura

Utiliza Clean Architecture.

Separar claramente:

Presentation
↓
Domain
↓
Data

Una estructura inicial puede ser:

lib/
core/
constants/
errors/
extensions/
utils/
security/
permissions/
platform/
widgets/

features/
media/
data/
domain/
presentation/

```
video_player/
  data/
  domain/
  presentation/

favorites/
  data/
  domain/
  presentation/

profiles/
  data/
  domain/
  presentation/

file_manager/
  data/
  domain/
  presentation/

settings/
  data/
  domain/
  presentation/
```

app/
router/
theme/
configuration/

No copies exactamente esta estructura si encuentras una arquitectura mejor.

La estructura debe mantenerse coherente y escalable.

---

# 5. SOLID

Respetar estrictamente:

* Single Responsibility Principle.
* Open/Closed Principle.
* Liskov Substitution Principle.
* Interface Segregation Principle.
* Dependency Inversion Principle.

Además:

* DRY.
* KISS.
* Separation of Concerns.
* Encapsulation.

No crear clases gigantes.

No crear Widgets gigantes.

No colocar lógica de negocio dentro de Widgets.

No colocar acceso al sistema de archivos dentro de Widgets.

No colocar acceso a MediaStore/Photos framework dentro de ViewModels.

No hacer que la UI conozca implementaciones concretas de almacenamiento.

La dependencia debe seguir una dirección clara:

UI
→ ViewModel/Notifier
→ UseCase
→ Repository
→ DataSource
→ Platform API

---

# 6. Diferencias Android / iOS

IMPORTANTE:

No asumir que Android e iOS tienen el mismo modelo de almacenamiento.

Antes de implementar cualquier funcionalidad relacionada con:

* Fotos.
* Vídeos.
* Archivos.
* Carpetas.
* Permisos.
* Eliminación.
* Movimiento.
* Copia.
* Protección.
* Acceso al sistema de archivos.

Analiza específicamente:

### Android

Considerar:

* MediaStore.
* Scoped Storage.
* Photo/Video permissions.
* Storage Access Framework.
* Content URIs.
* Android Keystore.

### iOS

Considerar:

* PhotoKit.
* Photos permissions.
* Photo library authorization.
* Files app.
* Security-scoped resources cuando corresponda.
* Keychain.
* App sandbox.

No intentar forzar una implementación idéntica en ambas plataformas cuando el sistema operativo no lo permita.

Crear abstracciones comunes y adaptadores específicos de plataforma.

Ejemplo:

MediaRepository
↓
AndroidMediaDataSource
iOSMediaDataSource

FileRepository
↓
AndroidFileDataSource
iOSFileDataSource

SecurityRepository
↓
AndroidSecurityDataSource
iOSSecurityDataSource

---

# 7. Privacidad

La privacidad es uno de los requisitos fundamentales.

La aplicación debe ser:

LOCAL-FIRST.

No recopilar información innecesaria.

No enviar fotografías o vídeos a servidores.

No subir miniaturas.

No enviar metadatos.

No implementar analytics.

No implementar tracking.

No implementar publicidad.

No implementar telemetría.

No crear cuentas obligatorias.

No requerir conexión a Internet.

La aplicación debe funcionar completamente offline siempre que el sistema operativo lo permita.

No agregar permiso de Internet salvo que posteriormente exista una funcionalidad que realmente lo necesite.

---

# 8. Permisos

Solicitar únicamente permisos estrictamente necesarios.

Nunca solicitar permisos innecesarios.

Analizar las diferencias entre:

Android:

* READ_MEDIA_IMAGES.
* READ_MEDIA_VIDEO.
* Versiones anteriores.
* Photo Picker.
* Storage Access Framework.

iOS:

* PHPhotoLibrary.
* Acceso limitado a fotografías.
* Permisos de lectura.
* Permisos de escritura cuando corresponda.

La aplicación debe:

* Explicar al usuario por qué necesita acceso.
* Solicitar permisos en el momento apropiado.
* Manejar permisos denegados.
* Manejar permisos parciales.
* Manejar permisos revocados posteriormente.
* Evitar pedir permisos nuevamente de manera molesta.

---

# 9. Biblioteca multimedia

La aplicación debe descubrir fotografías y vídeos locales.

Formatos de imagen deseados:

* JPG.
* JPEG.
* PNG.
* GIF.
* TIFF.
* TIF.
* RAW y formatos RAW comunes cuando exista soporte.
* Otros formatos compatibles.

Formatos de vídeo deseados:

* MP4.
* AVI.
* MOV.
* MKV.
* Otros formatos soportados.

IMPORTANTE:

No asumir compatibilidad universal.

Un contenedor no garantiza que el codec interno sea compatible.

Diseñar una capa de detección de:

* Extensión.
* MIME type.
* Codec cuando esté disponible.
* Capacidad de reproducción.

Cuando un formato no pueda reproducirse:

* No producir crash.
* Mostrar estado de incompatibilidad.
* Mostrar información útil.
* Permitir intentar abrirlo con otra aplicación cuando sea posible.

---

# 10. Home

Diseñar una pantalla principal moderna.

Puede contener:

* Recientes.
* Fotos recientes.
* Vídeos recientes.
* Favoritos.
* Álbumes.
* Carpetas.
* Perfiles.
* Accesos rápidos.

Utilizar un sistema visual basado en:

* Categorías.
* Bloques.
* Secciones.
* Tarjetas discretas.
* Grids.
* Espacios adecuados.

No saturar la pantalla.

---

# 11. Diseño visual

Quiero una estética moderna inspirada conceptualmente en las aplicaciones modernas de fotografía, especialmente en:

* Organización por bloques.
* Categorías.
* Grandes superficies de contenido.
* Jerarquía visual.
* Navegación sencilla.
* Animaciones suaves.

NO copiar directamente el diseño de Apple Photos.

La aplicación debe tener identidad visual propia.

Evitar:

* Gradientes genéricos.
* Glassmorphism exagerado.
* Neumorphism.
* Sombras excesivas.
* Colores demasiado saturados.
* Animaciones innecesarias.

Utilizar colores vibrantes pero agradables.

Debe existir:

### Tema claro

### Tema oscuro

### Seguir configuración del sistema

Utilizar Material 3 como base cuando corresponda.

En iOS, utilizar componentes/convenciones Cupertino cuando realmente mejoren la experiencia.

---

# 12. Fotos

La sección de fotografías debe permitir:

* Visualizar.
* Zoom.
* Pan.
* Compartir.
* Favoritos.
* Eliminar.
* Información.
* Ver ubicación.
* Abrir con otra aplicación.
* Organizar.
* Mover cuando el sistema operativo lo permita.
* Copiar cuando el sistema operativo lo permita.

Utilizar:

* Lazy loading.
* Miniaturas.
* Caché.
* Paging cuando sea necesario.

Nunca cargar toda la biblioteca en memoria.

---

# 13. Visor multimedia continuo

ESTA ES UNA FUNCIONALIDAD FUNDAMENTAL.

Cuando el usuario seleccione una fotografía o vídeo desde la galería, NO quiero que el visor se limite a mostrar únicamente ese elemento.

El visor debe funcionar como un:

## Media Viewer continuo

Ejemplo:

El usuario está viendo:

Foto 105.

Puede deslizar hacia la izquierda:

Foto 106.

Desliza nuevamente:

Vídeo 107.

Desliza hacia la derecha:

Foto 106.

Desliza nuevamente:

Foto 105.

Todo esto debe ocurrir SIN salir del visor.

No regresar a la cuadrícula.

No abrir nuevamente la pantalla.

No realizar una navegación completa entre pantallas.

Debe sentirse como una experiencia continua.

---

# 14. Navegación horizontal del visor

El visor debe permitir:

* Swipe izquierda → siguiente elemento.
* Swipe derecha → elemento anterior.

Debe funcionar con:

* Fotos.
* Vídeos.

Idealmente también permitir:

* Foto → vídeo.
* Vídeo → foto.
* Vídeo → vídeo.
* Foto → foto.

La lista utilizada debe respetar el contexto actual.

Por ejemplo:

Si el usuario está viendo la carpeta "Vacaciones":

Swipe izquierda/derecha debería recorrer los elementos de esa carpeta.

Si está en Favoritos:

Debe recorrer solamente favoritos.

Si está en un perfil:

Debe recorrer solamente contenido disponible para ese perfil.

Si está en una búsqueda/filtro:

Debe respetar ese resultado.

---

# 15. Arquitectura del Media Viewer

No crear una pantalla independiente completamente nueva cada vez que cambia el elemento.

Crear un componente reutilizable conceptualmente como:

MediaViewerScreen
MediaViewerController
MediaItemPager
MediaViewerState

Debe poder recibir:

* Lista/contexto de elementos.
* Índice inicial.
* Tipo de contenido.
* Configuración.

Debe mantener:

* Índice actual.
* Elemento actual.
* Estado del vídeo.
* Posición del vídeo.
* Zoom.
* Orientación.
* Controles.

Cuando se cambia de elemento:

* Liberar recursos del anterior cuando corresponda.
* Preparar el siguiente.
* Mantener la interfaz fluida.

No cargar múltiples vídeos completos en memoria.

---

# 16. Gestos del Media Viewer

El sistema debe diferenciar entre:

### Swipe horizontal

Cambiar elemento.

### Pinch

Zoom.

### Pan

Mover una imagen ampliada.

### Tap

Mostrar/ocultar controles.

### Swipe vertical

Cuando esté reproduciendo vídeo, utilizar para:

* Lado izquierdo → brillo.
* Lado derecho → volumen.

### Gestos del reproductor

Deben coexistir correctamente con:

* Swipe entre elementos.
* Zoom.
* Pan.
* Seek.

Diseñar una estrategia de prioridades para evitar conflictos.

---

# 17. Reproductor de vídeo

Esta es la funcionalidad más importante de la aplicación.

El reproductor debe sentirse moderno, fluido y minimalista.

Funciones:

* Play.
* Pause.
* Seek.
* Barra de progreso.
* Duración.
* Adelantar.
* Retroceder.
* Siguiente.
* Anterior.
* Repetir.
* Silenciar.
* Volumen.
* Brillo.
* Zoom.
* Orientación.
* Fullscreen.
* Favoritos.
* Compartir.
* Eliminar.
* Información.
* Abrir con otra aplicación.

---

# 18. Gestos de vídeo

Implementar controles mediante gestos.

Propuesta inicial:

### Horizontal

Swipe izquierda/derecha:

* Seek dentro del vídeo.

Pero debe existir una forma clara de diferenciarlo del:

* Swipe para cambiar de elemento multimedia.

Diseña una estrategia UX adecuada.

Una posible solución es:

* Swipe horizontal corto → seek.
* Swipe horizontal iniciado desde los bordes o después de alcanzar un umbral específico → cambiar de elemento.

Sin embargo, NO asumas que esta es necesariamente la mejor solución.

Analiza el conflicto y propón la mejor experiencia.

---

# 19. Brillo y volumen

Durante reproducción:

Swipe vertical en lado izquierdo:

* Aumentar/disminuir brillo.

Swipe vertical en lado derecho:

* Aumentar/disminuir volumen.

Mostrar temporalmente:

* Icono.
* Barra.
* Porcentaje o nivel.

El feedback debe ser claro pero discreto.

El control de brillo debe respetar las capacidades de cada plataforma.

Si iOS o Android tienen restricciones diferentes, crear implementaciones específicas.

---

# 20. Zoom del vídeo

Permitir:

* Zoom in.
* Zoom out.
* Pan.
* Restaurar.
* Ajustar a pantalla.
* Ajustar manteniendo proporción.

No deformar el contenido.

El zoom debe ser fluido.

Evitar que el usuario quede atrapado en un estado de zoom.

---

# 21. Orientación

Permitir:

* Vertical.
* Horizontal.
* Fullscreen.
* Rotación manual.
* Rotación automática.

Al cambiar orientación:

Mantener:

* Vídeo.
* Posición.
* Volumen.
* Estado relevante.
* Elemento actual.

No reiniciar innecesariamente la reproducción.

---

# 22. Reproductor y navegación entre vídeos

Si el usuario está viendo un vídeo:

Swipe izquierda:

→ siguiente multimedia.

Swipe derecha:

→ anterior multimedia.

Esto debe funcionar incluso cuando el vídeo está:

* Reproduciéndose.
* Pausado.
* En fullscreen.
* Con zoom.
* Con controles ocultos.

Definir claramente cuándo el gesto debe:

* Buscar dentro del vídeo.
* Cambiar al siguiente elemento.

La UX debe ser consistente.

---

# 23. Perfiles locales

Crear perfiles locales.

Ejemplo:

Perfil:

"Jony"

Puede mostrar:

* Todo el contenido permitido.

Perfil:

"Jony2"

Puede mostrar:

* Fotografías seleccionadas.
* Vídeos seleccionados.
* Carpetas seleccionadas.

Los perfiles:

* Son locales.
* No necesitan cuenta.
* No requieren servidor.
* No sincronizan información.

---

# 24. Perfil privado

Debe existir la posibilidad de crear perfiles protegidos.

Ejemplo:

"Privado"

El contenido de este perfil no debe aparecer en la biblioteca general si el usuario así lo configura.

Protección:

* PIN.
* Contraseña.

Nunca almacenar:

* PIN en texto plano.
* Contraseña en texto plano.

Utilizar mecanismos seguros:

Android:

* Android Keystore.

iOS:

* Keychain.

Crear una abstracción:

SecureStorageService

con implementaciones específicas de plataforma.

---

# 25. Diferenciar ocultación y cifrado

IMPORTANTE.

Debes diferenciar claramente:

### Ocultación lógica

El contenido sigue existiendo en el sistema de archivos/fototeca, pero la aplicación decide no mostrarlo.

### Protección real

El archivo se mueve o copia a un espacio protegido y/o cifrado.

Analiza cuidadosamente las restricciones de Android e iOS.

No prometer que una aplicación Flutter pueda esconder completamente archivos de otras aplicaciones en todos los escenarios.

Documenta qué nivel de protección es realmente posible en cada plataforma.

---

# 26. Favoritos

Permitir:

* Agregar.
* Quitar.
* Filtrar.
* Visualizar favoritos.

El estado debe persistir localmente.

Diseñar un identificador robusto.

Considerar:

* URI.
* Asset ID.
* MediaStore ID.
* Identificador de PhotoKit.
* Hash cuando resulte necesario.

La solución debe tolerar:

* Archivos movidos.
* Archivos eliminados.
* Permisos cambiados.
* Cambios en la biblioteca.

---

# 27. Gestor de archivos

Crear una sección de administración de archivos.

Debe permitir cuando el sistema operativo lo permita:

* Navegar carpetas.
* Crear carpetas.
* Eliminar carpetas.
* Mover archivos.
* Copiar archivos.
* Renombrar.
* Eliminar.
* Selección múltiple.
* Comprimir.
* Descomprimir.
* Mostrar tamaño.
* Mostrar fecha.
* Mostrar extensión.
* Mostrar ubicación.

Utilizar ZIP como primer formato de compresión.

Las operaciones pesadas deben ejecutarse fuera del hilo principal.

Mostrar:

* Progreso.
* Cancelación.
* Éxito.
* Error.

---

# 28. Diferencias del gestor de archivos entre plataformas

IMPORTANTE:

Android e iOS NO tienen el mismo acceso al sistema de archivos.

No asumir que una función disponible en Android existe igual en iOS.

Antes de implementar:

* Crear carpetas.
* Mover archivos de la galería.
* Manipular Photos Library.
* Manipular Files.
* Eliminar contenido.

Determina qué permite realmente cada sistema.

Cuando una operación no sea posible directamente:

* Explicar la limitación.
* Utilizar APIs oficiales.
* Ofrecer una alternativa compatible.

No utilizar hacks de sistema.

---

# 29. Información del archivo

Mostrar cuando sea posible:

* Nombre.
* Extensión.
* MIME type.
* Tamaño.
* Resolución.
* Duración.
* Fecha.
* Fecha de modificación.
* Ubicación.
* Codec.
* FPS.
* Bitrate cuando esté disponible.

No recopilar esta información remotamente.

Toda la información debe procesarse localmente.

---

# 30. Compartir

Implementar compartir mediante las APIs apropiadas de cada plataforma.

Android:

* Android Sharesheet.

iOS:

* Share Sheet.

No implementar un sistema de compartir propio innecesario.

---

# 31. Eliminación

Al eliminar:

* Mostrar confirmación configurable.
* Utilizar las APIs oficiales.
* Respetar permisos.
* Manejar eliminaciones parciales.
* Actualizar la UI inmediatamente.
* Manejar errores.

No asumir que eliminar una referencia local elimina necesariamente el archivo físico.

---

# 32. Rendimiento

La aplicación debe soportar bibliotecas grandes.

Ejemplo:

* 10,000 fotografías.
* 2,000 vídeos.

No cargar todo en memoria.

Utilizar:

* Lazy grids.
* Paging.
* Thumbnail generation.
* Caching.
* Background processing.
* Streams.
* Debouncing.
* Cancelación de tareas.

Evitar:

* Full-resolution thumbnails innecesarias.
* Procesamiento en UI thread.
* Instanciar reproductores innecesarios.
* Decodificar múltiples vídeos simultáneamente.

---

# 33. Caché

Crear una estrategia de caché.

Debe:

* Evitar duplicar archivos innecesariamente.
* Limitar memoria.
* Permitir limpiar caché.
* Evitar afectar el almacenamiento original.

Diferenciar claramente:

Cache
vs
Contenido del usuario.

Nunca eliminar contenido del usuario cuando el usuario limpia la caché.

---

# 34. Manejo de errores

Nunca permitir que un archivo defectuoso cierre la aplicación.

Manejar:

* Archivo corrupto.
* Codec no soportado.
* Formato desconocido.
* Archivo eliminado.
* URI inválida.
* Permiso denegado.
* Permiso revocado.
* Error de almacenamiento.
* Falta de espacio.
* Error de reproducción.
* Error de decodificación.

Mostrar estados útiles.

---

# 35. Accesibilidad

Considerar:

* Semantics.
* Content descriptions.
* Tamaños táctiles.
* Contraste.
* Tamaños de texto.
* Screen readers.
* Alternativas a gestos.
* Feedback visual.

Los gestos no deben ser la única manera de realizar acciones importantes.

---

# 36. Estado de la aplicación

Manejar correctamente:

* Background.
* Foreground.
* Suspensión.
* Rotación.
* Cambio de orientación.
* Pérdida de permisos.
* Cambios externos en la biblioteca.
* Cierre de aplicación.
* Reapertura.

Especialmente el reproductor debe manejar correctamente:

* Lifecycle.
* Audio focus.
* Interrupciones.
* Llamadas.
* Bluetooth.
* Auriculares.
* Background cuando sea permitido.

Analizar diferencias Android/iOS.

---

# 37. Audio

El reproductor debe manejar correctamente:

* Audio focus en Android.
* Interrupciones en iOS.
* Bluetooth.
* Auriculares.
* Volumen del sistema.
* Silenciar.
* Reanudación.

No asumir que Android e iOS funcionan igual.

---

# 38. Testing

Preparar el proyecto desde el inicio para:

### Unit tests

* UseCases.
* Repositories.
* Validaciones.
* Seguridad.
* Gestos.
* Estado del reproductor.

### Widget tests

* Pantallas.
* Componentes.
* Estados.
* Navegación.

### Integration tests

* Navegación.
* Permisos.
* Biblioteca.
* Reproductor.
* Perfiles.

No crear tests artificiales únicamente para obtener cobertura.

Priorizar lógica crítica.

---

# 39. Seguridad

Implementar:

* Secure storage.
* Keychain en iOS.
* Android Keystore.
* Hashing seguro.
* Cifrado estándar cuando sea necesario.

Nunca:

* Crear algoritmos criptográficos propios.
* Guardar contraseñas en texto plano.
* Registrar PIN.
* Registrar contraseñas.
* Registrar información sensible.

---

# 40. Logs

Los logs durante desarrollo deben ser controlados.

No registrar innecesariamente:

* Nombres de archivos privados.
* Rutas.
* PIN.
* Contraseñas.
* Metadatos sensibles.

En release:

* Reducir/eliminar logs de debugging.
* Evitar información sensible.

---

# 41. Offline

La aplicación debe funcionar sin Internet.

Las operaciones principales deben ser locales:

* Galería.
* Vídeo.
* Fotos.
* Favoritos.
* Perfiles.
* Archivos.
* Configuración.

No depender de:

* API.
* Backend.
* Cloud.
* Cuenta.
* Login.

---

# 42. Configuración

Crear una sección de ajustes.

Opciones iniciales:

* Tema:

  * Claro.
  * Oscuro.
  * Sistema.

* Reproducción:

  * Reproducción automática.
  * Repetición.
  * Fullscreen.
  * Orientación.
  * Gestos.

* Gestos:

  * Activar/desactivar.
  * Sensibilidad.
  * Acción de doble toque.

* Seguridad:

  * PIN.
  * Contraseña.
  * Bloqueo automático.

* Privacidad.

* Biblioteca.

No saturar la pantalla.

---

# 43. Navegación

Considerar inicialmente:

* Home.
* Fotos.
* Vídeos.
* Álbumes.
* Favoritos.
* Perfiles.
* Archivos.
* Configuración.

El Media Viewer NO debe sentirse como una pantalla independiente desconectada.

Debe poder abrirse desde:

* Fotos.
* Vídeos.
* Favoritos.
* Álbumes.
* Perfiles.
* Búsqueda.

Y conservar el contexto que lo originó.

---

# 44. Contexto del visor

Ejemplo:

El usuario entra a:

Favoritos.

Abre:

Video A.

Dentro del visor:

Swipe izquierda.

Debe pasar a:

Video B.

Pero Video B debe pertenecer al conjunto de favoritos.

Otro ejemplo:

Usuario entra a:

Carpeta "Vacaciones".

Abre:

Foto A.

Swipe izquierda.

Debe mostrar:

Foto B.

No debe saltar a contenido que está fuera de esa carpeta.

Por lo tanto, el MediaViewer debe recibir un:

MediaContext

que determine:

* Lista de elementos.
* Índice.
* Filtros.
* Perfil.
* Origen.

---

# 45. Animaciones

Utilizar animaciones discretas.

Por ejemplo:

* Transiciones suaves.
* Shared element transitions cuando aporten valor.
* Hero animations.
* Fade.
* Scale.

No utilizar animaciones solamente por decoración.

El rendimiento tiene prioridad.

---

# 46. UX del visor

El visor debe sentirse como una experiencia inmersiva.

Cuando se abre una fotografía:

* Ocultar controles innecesarios.
* Mostrar imagen.
* Permitir swipe.
* Permitir zoom.

Cuando se abre vídeo:

* Iniciar reproducción según configuración.
* Mostrar controles temporalmente.
* Permitir gestos.
* Permitir swipe entre elementos.

Al tocar:

Mostrar controles.

Al volver a tocar:

Ocultar controles.

---

# 47. Gestión de memoria del reproductor

IMPORTANTE.

No crear un reproductor completamente independiente para cada elemento.

Analizar una arquitectura donde:

* El elemento actual tenga prioridad.
* El siguiente/anterior pueda precargarse cuando sea apropiado.
* Se liberen recursos rápidamente.
* No se produzcan fugas de memoria.

Debe funcionar correctamente con bibliotecas grandes.

---

# 48. Formatos multimedia

No prometer compatibilidad total.

Crear una abstracción:

MediaDecoder / MediaCapabilityService

que permita determinar:

* Puede visualizarse.
* Puede reproducirse.
* Necesita aplicación externa.
* No es compatible.

Esto permitirá ampliar formatos posteriormente.

---

# 49. Arquitectura de plataforma

Crear interfaces comunes.

Ejemplo:

abstract class MediaDataSource

Implementaciones:

AndroidMediaDataSource
IOSMediaDataSource

También:

abstract class FileDataSource

AndroidFileDataSource
IOSFileDataSource

Y:

abstract class SecureStorageService

AndroidSecureStorageService
IOSSecureStorageService

No colocar `Platform.isAndroid` y `Platform.isIOS` repartidos por todo el proyecto.

Centralizar las diferencias de plataforma.

---

# 50. Dependencias

No agregar paquetes indiscriminadamente.

Para cada dependencia nueva:

1. Explicar por qué es necesaria.
2. Verificar mantenimiento.
3. Verificar compatibilidad Android/iOS.
4. Verificar compatibilidad con la versión actual de Flutter.
5. Evaluar alternativas.
6. Evitar dependencias abandonadas.

Priorizar:

* Paquetes oficiales.
* Paquetes ampliamente mantenidos.
* Soluciones maduras.

---

# 51. Proceso de desarrollo

NO desarrolles toda la aplicación de una sola vez.

Trabaja por fases.

## Fase 0 — Análisis

Analiza:

* Requisitos.
* Arquitectura.
* UX.
* Android.
* iOS.
* Permisos.
* Almacenamiento.
* Reproducción.
* Seguridad.
* Perfiles.
* Archivos.

Identifica riesgos.

---

## Fase 1 — Arquitectura

Crear:

* Proyecto Flutter.
* Estructura.
* Dependency Injection.
* State Management.
* Routing.
* Theme.
* Error handling.
* Core abstractions.

Todavía sin funcionalidades complejas.

---

## Fase 2 — Biblioteca

Implementar:

* Permisos.
* Descubrimiento multimedia.
* Fotos.
* Vídeos.
* Grid.
* Miniaturas.
* Paging.
* Home.

---

## Fase 3 — Media Viewer

Implementar:

* Visor de fotografías.
* Reproductor.
* Swipe izquierda/derecha.
* Contexto multimedia.
* Zoom.
* Pan.
* Controles.

Esta fase debe dejar funcionando correctamente la navegación continua entre elementos.

---

## Fase 4 — Reproductor avanzado

Implementar:

* Seek.
* Brillo.
* Volumen.
* Gestos.
* Zoom de vídeo.
* Orientación.
* Fullscreen.
* Audio focus.
* Interrupciones.
* Controles avanzados.

---

## Fase 5 — Favoritos y organización

Implementar:

* Favoritos.
* Álbumes.
* Carpetas.
* Información del archivo.
* Compartir.
* Eliminar.

---

## Fase 6 — Perfiles

Implementar:

* Crear perfil.
* Editar.
* Eliminar.
* Cambiar perfil.
* Asociar contenido.
* Ocultar contenido.

---

## Fase 7 — Seguridad

Implementar:

* PIN.
* Contraseña.
* Secure Storage.
* Keychain.
* Android Keystore.
* Bloqueo automático.

---

## Fase 8 — File Manager

Implementar:

* Carpetas.
* Crear.
* Eliminar.
* Mover.
* Copiar.
* Renombrar.
* ZIP.
* Unzip.

Respetar estrictamente las capacidades de cada plataforma.

---

## Fase 9 — Refinamiento

Implementar:

* Animaciones.
* Accesibilidad.
* Performance.
* Manejo de errores.
* Tests.
* Memory optimization.
* Seguridad.
* UX.

---

# 52. Regla fundamental para el desarrollo

Antes de implementar cada fase:

1. Explica qué vas a hacer.
2. Explica las decisiones arquitectónicas.
3. Indica qué archivos crearás.
4. Indica qué archivos modificarás.
5. Implementa.
6. Ejecuta `flutter analyze`.
7. Ejecuta los tests disponibles.
8. Ejecuta build cuando sea posible.
9. Corrige warnings y errores.
10. Revisa arquitectura.
11. Resume los cambios.
12. Espera aprobación antes de continuar.

No saltar automáticamente a la siguiente fase.

---

# 53. Calidad del código

El código debe:

* Ser legible.
* Ser mantenible.
* Ser testeable.
* Ser modular.
* Ser reutilizable.
* Tener responsabilidades claras.

Evitar:

* Código duplicado.
* Widgets gigantes.
* Providers gigantes.
* Repositories gigantes.
* Métodos de cientos de líneas.
* Variables ambiguas.
* Magic numbers.
* Strings duplicadas.
* Dependencias innecesarias.

Utilizar:

* Const constructors cuando sea posible.
* Immutable state.
* Value objects cuando aporten valor.
* Sealed classes para estados cuando sea apropiado.
* Result/Either pattern cuando sea útil.
* Manejo explícito de errores.

---

# 54. Documentación

Documentar las decisiones arquitectónicas importantes.

Especialmente:

* Permisos.
* MediaStore.
* PhotoKit.
* File System.
* Seguridad.
* Perfiles.
* Cifrado.
* Media Viewer.
* Gestos.
* Reproductor.

No llenar el código de comentarios obvios.

---

# 55. Resultado inicial solicitado

POR AHORA NO ESCRIBAS CÓDIGO.

Quiero únicamente que analices todo este proyecto y me entregues:

1. Resumen técnico.
2. Arquitectura recomendada.
3. Stack recomendado.
4. Paquetes Flutter recomendados.
5. Alternativas a esos paquetes cuando existan.
6. Estructura de carpetas.
7. Arquitectura Android.
8. Arquitectura iOS.
9. Estrategia de permisos.
10. Estrategia de MediaStore.
11. Estrategia de PhotoKit.
12. Estrategia del File Manager.
13. Estrategia del Media Viewer.
14. Estrategia de navegación swipe izquierda/derecha.
15. Estrategia del reproductor.
16. Estrategia de perfiles.
17. Estrategia de privacidad.
18. Estrategia de seguridad.
19. Modelo de datos inicial.
20. Flujo de navegación.
21. Riesgos técnicos.
22. Limitaciones de Android.
23. Limitaciones de iOS.
24. Plan de desarrollo por fases.
25. Dependencias necesarias.
26. Estrategia de testing.
27. Estrategia de rendimiento.
28. Estrategia para compatibilidad de formatos.

No implementes código todavía.

Si alguna característica que solicité no es posible exactamente como está descrita en Android o iOS, indícalo claramente y propón la alternativa técnicamente más adecuada.

No inventes APIs.

No inventes capacidades de Flutter.

Prioriza APIs oficiales del sistema operativo y paquetes Flutter mantenidos.

Cuando exista una diferencia entre Android e iOS, no sacrifiques la calidad de una plataforma para hacer que ambas tengan una implementación artificialmente idéntica.

El objetivo es construir una aplicación multiplataforma profesional, no simplemente una aplicación Android ejecutándose también en iOS.

Al terminar el análisis, espera mi aprobación antes de comenzar la implementación.

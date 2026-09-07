# Seguridad, privacidad y separación de responsabilidades

Fecha: 2026-09-06. Alcance: entregas 1 y 2 de la revisión de AGENTS.md.

## Protección implementada

Los perfiles se almacenan como un catálogo versionado en SecureStorageService.
Android usa flutter_secure_storage con cifrado AES-GCM y claves protegidas mediante
Keystore. iOS usa Keychain con accesibilidad unlocked_this_device, sin sincronización.
La entidad UserProfile contiene únicamente metadatos y un indicador de protección.

Una credencial nueva acepta PIN de 6–12 dígitos o contraseña de 10–128 caracteres.
PBKDF2-HMAC-SHA256 usa 600.000 iteraciones, sal aleatoria de 16 bytes y resultado de
32 bytes. El cálculo se ejecuta en un isolate mediante cryptography; no hay una
implementación propia de PBKDF2. No se guardan PIN ni contraseñas en texto plano.

Antes de verificar se persiste el intento. Los fallos sucesivos aplican esperas
de 1, 2, 4, 8, 16, 32 y hasta 60 segundos, usando el reloj del dispositivo. Reiniciar
la app no reinicia el contador. Esto no protege contra un dispositivo comprometido
o manipulación privilegiada del reloj/almacenamiento. El éxito reinicia el contador.

Al abrir la aplicación, el perfil protegido comienza bloqueado. Inactive, paused,
hidden y detached invalidan la sesión. Una verificación iniciada antes de un bloqueo
no vuelve a desbloquearla al terminar. La barrera está por encima del Navigator:
incluye las rutas restauradas y los diálogos. El contenido protegido se desmonta
para detener la reproducción; tras desbloquear se reconstruye y la posición no se
restaura todavía. Los perfiles públicos conservan su árbol oculto al ir a background.

Editar, quitar/cambiar credencial y eliminar un perfil protegido requieren su
credencial actual en el repositorio, incluso si se llama sin pasar por el diálogo.
Una operación fallida mantiene el formulario abierto y muestra un error.

## Migración desde SharedPreferences

1. Leer el catálogo antiguo sin modificarlo.
2. Conservar IDs, nombres, perfil activo y estado del onboarding. Los IDs de favoritos
   permanecen válidos.
3. Mover el verificador anterior al catálogo seguro marcado como legacy.
4. Escribir y leer de vuelta el catálogo seguro; crear un marcador no sensible
   de migración en preferencias.
5. Retirar solo las tres claves antiguas de perfiles.
6. En el primer desbloqueo correcto, sustituir el verificador antiguo por PBKDF2.
   Los PIN antiguos de cuatro dígitos siguen funcionando; las credenciales nuevas
   deben cumplir la política actual.

Si la escritura falla, no se borra la copia antigua. Si el proceso termina después
del commit seguro, la siguiente lectura termina la limpieza. Si el catálogo está
corrupto, es inaccesible o desaparece después de migrar, el acceso falla cerrado.
No se activa la opción resetOnError del plugin. No existe recuperación de PIN:
no hay servidor ni cuenta de recuperación. No se debe borrar almacenamiento como
solución automática a un fallo de lectura.

La migración elimina lógicamente las claves antiguas. No puede garantizar borrado
forense de páginas flash o copias de seguridad creadas antes de esta versión.

## Privacidad por plataforma

Android: se desactiva backup y se excluyen datos de app de backup/transferencia.
FLAG_SECURE protege la ventana de toda la aplicación, incluyendo capturas y vistas
recientes en sistemas compatibles. Es una decisión deliberada de esta entrega;
no está limitada al perfil activo.

iOS: el SceneDelegate cubre la ventana al quedar inactiva para evitar contenido en
la captura del selector de aplicaciones. Esto NO impide las capturas manuales.
Runner.entitlements configura el grupo Keychain del identificador de la aplicación.
Keychain puede sobrevivir a una reinstalación; se conserva el catálogo existente
y se exige la credencial, sin borrar datos automáticamente.

Los logs de errores propios usan mensajes controlados y el tipo de excepción;
no incluyen rutas, textos de excepción ni stack traces. El adaptador de vídeo
no acepta URLs HTTP(S). No se añadieron permisos de Internet a release.

## Límites del alcance

Esta entrega protege acceso a perfiles dentro de la aplicación. No cifra, mueve
ni oculta originales de Photos/MediaStore a otras aplicaciones. Los favoritos
siguen siendo referencias locales por perfil; el filtrado de contenido y una
bóveda cifrada corresponden a entregas posteriores. No hay protección absoluta
contra root/jailbreak, depuración privilegiada o extracción física.

La resolución completa de content URIs para compartir, capacidades de formatos,
descargas de recursos de PhotoKit y política global de caché siguen pendientes.
La inspección local ya evita interpretar una content URI como ruta física.

## Arquitectura resultante

- Perfiles: ProfilesNotifier → ProfileOperations → ProfilesRepository →
  SecureProfilesRepository → ProfilesLocalDataSource → SecureStorageService.
- El repositorio serializa operaciones para impedir que escrituras simultáneas
  pierdan cambios. Cada operación trabaja sobre un catálogo recién leído.
- La sesión de desbloqueo solo reside en ProfilesState; no se persiste.
- MediaViewerScreen conserva navegación, diálogos y presentación de acciones.
  Los paneles de imagen/vídeo, controles, zoom, guía e información son widgets separados.
- VideoPaneController coordina carga, cancelación, liberación y lifecycle.
  VideoGestureController mantiene seek, brillo, volumen y feedback con colas.
- MediaActionsController delega resolución, compartir, apertura e inspección.
  LocalMediaFileInspector y LocalImageSource contienen acceso/representación de archivos.
- ViewerPreferencesRepository encapsula preferencias de la guía.
- DeleteMediaUseCase depende de un puerto de eliminación, sin Riverpod, plugins ni
  imports de presentación. MediaDeletionController actualiza providers y referencias
  de favoritos de los perfiles después de la eliminación confirmada.
- VideoSurface es el único widget que conoce VideoPlayerController para dibujar
  su superficie. El estado de buffering viaja como dato del adaptador.

## Dependencias

Se conserva el stack existente. flutter_secure_storage 10.0.0 se fija para integrar
Keystore/Keychain sin adoptar los cambios de requisitos de la rama 11 en esta entrega.
cryptography ^2.9.0 proporciona PBKDF2 multiplataforma; crypto permanece solamente
para verificar el formato heredado durante la migración.

Alternativas evaluadas: canales nativos propios para Keystore/Keychain aumentarían
el mantenimiento; SharedPreferences no protege credenciales. Una implementación
criptográfica manual queda descartada. Argon2 es una alternativa futura, pero
requiere medir parámetros de memoria/tiempo en los dispositivos objetivo.

Fuentes consultadas:
- https://pub.dev/packages/flutter_secure_storage/versions/10.0.0
- https://pub.dev/packages/flutter_secure_storage/changelog
- https://pub.dev/packages/cryptography
- https://docs.flutter.dev/release/breaking-changes/uiscenedelegate

## Validación

Pruebas automatizadas: migración, preservación de datos ante fallo, limpieza
interrumpida, catálogo desaparecido/corrupto, autenticación de edición/eliminación,
espera persistente, escrituras simultáneas, validación de credenciales, bloqueo
durante verificación, barrera visual, PBKDF2 real, cancelación de carga de vídeo,
lifecycle, restauración de brillo y seek. Se conserva la suite anterior.

Verificación manual pendiente en Android e iOS:
- Migrar una instalación real con favoritos y PIN antiguo, reiniciar y desbloquear.
- Salir durante PBKDF2, abrir notificaciones y volver desde compartir.
- Confirmar diálogo de cambio/quitar PIN y eliminación con credencial incorrecta.
- Revisar selector de aplicaciones y política de capturas.
- Probar Keychain/Keystore inaccesible, permisos revocados e interrupciones de audio.
- Validar firma y entitlements iOS en macOS/Xcode; Windows no permite compilar iOS.


## Resultado de la verificación automática

Flutter 3.44.9 / Dart 3.12.2: flutter analyze --no-pub sin problemas;
flutter test --no-pub: 27 pruebas aprobadas; flutter build apk --debug --no-pub:
compilación correcta. Artefacto: build/app/outputs/flutter-apk/app-debug.apk.

Gradle conserva avisos del acceso nativo de Java y de migración futura a Built-in
Kotlin en photo_manager y share_plus. No son errores de compilación ni warnings
 del analizador Dart. La actualización de esas dependencias debe validarse junto
con la siguiente entrega de biblioteca/permisos. No se ejecutaron pruebas físicas
ni compilación iOS en este entorno Windows.


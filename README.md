# Mireon - Private Media

Galeria multimedia Flutter local y privada para Android e iOS. Incluye biblioteca paginada, visor continuo,
reproduccion con gestos, favoritos por perfil y bloqueo local de perfiles.

La proteccion de perfiles controla el acceso dentro de esta aplicacion; los
originales de la fototeca no estan cifrados ni ocultos a otras aplicaciones.

Consulta [las decisiones de seguridad y arquitectura](docs/security-and-architecture.md)
para la migracion de credenciales, limites de proteccion y verificaciones de dispositivo.

Validacion del proyecto:

```text
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

La compilacion y validacion de iOS requieren macOS y Xcode. El proyecto conserva
la firma Android de desarrollo; los APK generados no constituyen una publicacion.
# Crónicas 3.5

Aplicación Flutter para Android y web con una ficha editable de personaje de D&D 3.5 y un compendio local de 66 conjuros importados de `Conjuros_DnD_3.5_Compendio.xlsx`. Los datos del compendio están empaquetados en `assets/data/spells.json`; la app no necesita conexión para consultarlos. La ficha se guarda localmente en el dispositivo o en el almacenamiento del navegador.

## Requisitos

- Flutter estable (incluye Dart) instalado y agregado al `PATH`.
- Para Android: Android Studio con Android SDK y las licencias del SDK aceptadas.
- Para compilar para web: Chrome instalado para la vista previa local.

Comprueba la instalación con:

```powershell
flutter doctor
```

## Preparar las plataformas

Desde la carpeta del proyecto, genera los archivos nativos de Android y web (se hace una sola vez):

```powershell
flutter create --platforms=android,web .
flutter pub get
```

Si `flutter create` solicita confirmar la sobrescritura de archivos del proyecto, conserva `lib/main.dart`, `pubspec.yaml` y `assets/data/spells.json`.

## Ejecutar en Android

Conecta un dispositivo con depuración USB habilitada o inicia un emulador desde Android Studio. Comprueba que Flutter lo detecte y ejecuta la aplicación:

```powershell
flutter devices
flutter run -d <ID_DEL_DISPOSITIVO>
```

Para generar el APK de distribución:

```powershell
flutter build apk --release
```

El archivo resultante queda en `build/app/outputs/flutter-apk/app-release.apk`. Para publicar en Google Play, genera un paquete Android App Bundle:

```powershell
flutter build appbundle --release
```

La firma de publicación debe configurarse en el proyecto Android antes de distribuir en Google Play.

## Ver la aplicación en web

Inicia Flutter en Chrome:

```powershell
flutter run -d chrome
```

Para generar archivos web estáticos:

```powershell
flutter build web --release
```

Sirve `build/web` con un servidor web estático. Por ejemplo, con Python:

```powershell
cd build/web
python -m http.server 8000
```

Luego abre `http://localhost:8000`. También puedes desplegar el contenido de `build/web` en cualquier hosting estático con HTTPS. La ficha se conserva en el almacenamiento local del navegador; borrar los datos del sitio la elimina.

## Funciones

- Ficha editable con identidad, seis características, combate, salvaciones, habilidades, dotes, equipo y notas.
- Guardado automático local sin crear cuenta.
- Compendio integrado con búsqueda por nombre, escuela o clase, filtros por nivel y clase, y consulta de los detalles de cada conjuro.
- Diseño adaptable a pantallas móviles y de escritorio.

# Crónicas 3.5

Aplicación Flutter para Android y web con una ficha editable de personaje de D&D 3.5, un compendio local de 66 conjuros importados de `Conjuros_DnD_3.5_Compendio.xlsx`, un selector con las descripciones de los nueve alineamientos de `Alineamientos_DnD_3.5.xlsx` y un selector local de 75 deidades de los planos D&D, Olimpo, Faraónico, Asgardiano y Fe del Sol, importadas de `Dioses_DnD_3.5.xlsx`, `Dioses DND Olimpo.xlsx`, `Dioses Faraonicos.xlsx` y `Panteon_Asgardiano.xlsx`, además de la información de Taia compartida por el usuario. Los datos están empaquetados en `assets/data/spells.json`, `assets/data/alignments.json` y `assets/data/deities.json`; la app no necesita conexión para consultarlos. La ficha se guarda localmente en el dispositivo o en el almacenamiento del navegador.

## Requisitos

- Flutter estable (incluye Dart) instalado y agregado al `PATH`.
- Para Android: Java 17, Android SDK (plataforma 36, Build Tools 36.0.0 y Platform Tools) y sus licencias aceptadas. Android Studio es opcional; es útil para administrar emuladores.
- Para compilar para web: Chrome instalado para la vista previa local.

Comprueba la instalación con:

```powershell
flutter doctor
```

Si Flutter todavía indica que faltan licencias de Android, acepta las licencias e instala los paquetes de compilación:

```powershell
flutter doctor --android-licenses
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"
```

## Preparar las dependencias

Las plataformas Android y web ya están configuradas en el proyecto. Desde su carpeta, descarga las dependencias de Dart y Flutter:

```powershell
flutter pub get
```

Solo si eliminas las carpetas de las plataformas, puedes regenerarlas sin reemplazar el código de la app:

```powershell
flutter create --platforms=android,web .
```

Comprueba el análisis estático y ejecuta las pruebas con:

```powershell
flutter analyze
flutter test
```

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
Con un dispositivo conectado y la depuración USB habilitada, también puedes instalar el APK compilado con:

```powershell
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Ver la aplicación en web

Inicia Flutter en Chrome:

```powershell
flutter run -d chrome
```

Para generar archivos web estáticos:

```powershell
flutter build web --release
```

Para probar la app en un navegador sin abrir Chrome directamente:

```powershell
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8000
```

Abre `http://localhost:8000`. El contenido de `build/web` también puede publicarse en cualquier hosting estático con HTTPS. La ficha se conserva en el almacenamiento local del navegador; borrar los datos del sitio la elimina.

## Funciones

- Ficha editable con identidad, seis características, combate, salvaciones, habilidades, dotes, equipo y notas.
- Selector de alineamiento con categorías, siglas y descripciones locales.
- Selector de 75 deidades de D&D, Olimpo, Faraónico, Asgardiano y Fe del Sol, identificadas con cápsulas visuales, con filtros por plano, alineamiento de clérigos, dominio y texto (nombre, ámbito, dominio o alineamiento), y consulta de sus descripciones.
- Guardado automático local sin crear cuenta.
- Compendio integrado con búsqueda por nombre, escuela o clase, filtros por nivel y clase, y consulta de los detalles de cada conjuro.
- Diseño adaptable a pantallas móviles y de escritorio.

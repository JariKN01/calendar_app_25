# Agenda App

Een cross-platform kalender en agenda applicatie gebouwd met Flutter, met ondersteuning voor Android, Web en Windows platforms.

## Functies

- 📅 Kalenderweergave en evenementenbeheer
- 🔐 Gebruikersauthenticatie
- 📱 Cross-platform ondersteuning (Android, Web, Windows)
- 🎯 Gebeurtenissen bijhouden en plannen
- 🏠 Home dashboard
- 🎨 Modern Material Design UI

## Aan de slag

### Vereisten

- Flutter SDK (3.24.3 of later)
- Dart SDK (3.5.3 of later)
- Voor Android: Android Studio met Android SDK
- Voor Windows: Visual Studio met C++ tools
- Voor Web: Chrome browser

### Installatie

1. Kloon de repository:
   ```bash
   git clone <repository-url>
   cd calendar_app_25
   ```

2. Installeer dependencies:
   ```bash
   flutter pub get
   ```

3. Start de app:
   ```bash
   flutter run
   ```

### Configuratie

De app ondersteunt runtime configuratie via Dart defines:

```bash
flutter run --dart-define=TOKEN=jouw_token_hier
```

## Bouwen voor Productie

### Android
```bash
# Bouw APK
flutter build apk --release

# Bouw App Bundle (aanbevolen voor Play Store)
flutter build appbundle --release
```

### Web
```bash
flutter build web --release
```

### Windows
```bash
flutter build windows --release
```

## Testen

Voer unit tests uit:
```bash
flutter test
```

Voer integratie tests uit:
```bash
flutter test integration_test/
```

## Project Structuur

```
lib/
├── main.dart                 # App entry point
└── src/
    ├── constants.dart        # App constanten
    ├── controller/          # Business logic controllers
    │   ├── auth_controller.dart
    │   ├── events_controller.dart
    │   └── home_controller.dart
    ├── extensions/          # Dart extensies
    ├── model/              # Data modellen
    ├── view/               # UI schermen
    └── widgets/            # Herbruikbare UI componenten
```

## Ontwikkeling

### Code Stijl
Dit project volgt Dart/Flutter coding conventies. Formatteer je code met:
```bash
dart format .
```

### Statische Analyse
Voer statische analyse uit:
```bash
flutter analyze
```

## CI/CD

Dit project bevat een GitHub Actions workflow die:
- Tests en code analyse uitvoert
- Bouwt voor Android (APK & AAB)
- Bouwt voor Web
- Bouwt voor Windows
- Upload build artifacts

## Bijdragen

1. Fork de repository
2. Maak een feature branch
3. Maak je wijzigingen
4. Voer tests uit en zorg voor code kwaliteit
5. Dien een pull request in

## Licentie

Dit project is privé en niet gepubliceerd naar pub.dev.

# Couple Photo Widget (together_pic)

A Flutter application for couples to share photos with widget functionality.

## Features

- Photo sharing between couples
- Android home screen widget
- Sign-in functionality
- Secure photo storage with Supabase

## Getting Started

### Prerequisites

- Flutter 3.8.1 or higher
- Android Studio / VS Code
- Android SDK

### Installation

1. Clone the repository:
```bash
git clone https://github.com/JavierStark/Couple-Photo-Widget.git
cd Couple-Photo-Widget
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Android Release

This project includes automated GitHub Actions workflows for building and publishing Android releases:

### Workflows

1. **android-release.yml** - Builds and publishes AAB to Google Play Store
2. **build-test.yml** - Test builds for CI/CD validation

### Setup for Publishing

To enable automatic publishing to Google Play Store, configure the following GitHub repository secrets:

#### Android Signing
- `KEYSTORE_BASE64` - Base64 encoded keystore file
- `KEYSTORE_PASSWORD` - Keystore password
- `KEY_ALIAS` - Key alias
- `KEY_PASSWORD` - Key password

#### Google Play Store
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` - Service account JSON for Play Console API

For detailed setup instructions, see [.github/workflows/README.md](.github/workflows/README.md).

### Manual Release

To build manually:

```bash
# Build AAB for Play Store
flutter build appbundle --release

# Build APK for testing
flutter build apk --release
```

## Development

### Project Structure

- `lib/` - Flutter source code
- `android/` - Android-specific code and configuration
- `assets/` - App assets (icons, images)
- `.github/workflows/` - CI/CD workflows

### Testing

```bash
# Run tests
flutter test

# Run static analysis
flutter analyze
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Flutter Guide](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Android App Bundle Guide](https://developer.android.com/guide/app-bundle)

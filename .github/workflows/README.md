# Android Release Workflow Setup

This document explains how to set up the GitHub Actions workflow for building and publishing Android App Bundles to Google Play Store.

## Required GitHub Secrets

To use the Android release workflow, you need to configure the following secrets in your GitHub repository:

### 1. Android Signing Secrets

#### `KEYSTORE_BASE64`
- Your Android keystore file encoded in base64
- To generate: `base64 -i your-keystore.jks | tr -d '\n'`

#### `KEYSTORE_PASSWORD`
- The password for your keystore file

#### `KEY_ALIAS`
- The alias of the key in your keystore

#### `KEY_PASSWORD`
- The password for your key alias

### 2. Google Play Store Secrets

#### `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
- Service account JSON key for Google Play Console API access
- Follow these steps to create it:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select or create a project
3. Enable the Google Play Android Developer API
4. Create a service account
5. Download the JSON key file
6. Copy the entire JSON content as the secret value

## Setting up Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Navigate to "Setup" → "API access"
3. Link your Google Cloud project
4. Grant the service account the following permissions:
   - Release manager
   - View app information and download bulk reports

## Workflow Triggers

The workflow runs on:
- Push to `main` or `master` branches
- Push of version tags (starting with 'v')
- Pull requests to `main` or `master` branches
- Manual trigger via GitHub UI

## Workflow Steps

1. **Checkout**: Gets the latest code
2. **Setup Java**: Installs Java 11 for Android builds
3. **Setup Flutter**: Installs Flutter 3.24.0 stable
4. **Dependencies**: Runs `flutter pub get`
5. **Tests**: Runs `flutter test`
6. **Signing Setup**: Creates key.properties and keystore files
7. **Build**: Creates Android App Bundle (AAB)
8. **Publish**: Uploads to Google Play Store production track
9. **Artifacts**: Saves AAB file as GitHub artifact

## Version Management

The app version is controlled by:
- `version` in `pubspec.yaml` (e.g., 1.0.0+1)
- `versionCode` in `android/app/build.gradle.kts`

Make sure to increment the version code for each release.

## Security Notes

- Never commit keystore files or passwords to your repository
- Use GitHub secrets for all sensitive information
- The keystore is temporarily created during the build and deleted after

## Troubleshooting

### Build Failures
- Check that all secrets are correctly set
- Verify Flutter version compatibility
- Ensure Android configuration is correct

### Publishing Failures
- Verify service account permissions
- Check that version code is incremented
- Ensure app is properly configured in Play Console

### Testing the Workflow
- The workflow can be triggered manually from the Actions tab
- Pull requests will build but not publish
- Only pushes to main/master or tags will publish to Play Store
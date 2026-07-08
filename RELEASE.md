# RELEASE.md

This document outlines the process for creating and publishing new releases of the `paren` application. The process is semi-automated using a combination of shell scripts, Fastlane, and GitHub Actions.

## Versioning
The application version is managed in `pubspec.yaml`. The version number follows a `major.minor.patch+build` format (e.g., `1.11.6+1`).

The build number is automatically set by the release scripts. It is derived from the total number of commits on the `main` branch (`git rev-list --count main`). This ensures that every build has a unique, sequential build number.

## Release Scripts
The release process is orchestrated by several scripts located in the project root. **All Flutter commands within these scripts are automatically run with `fvm`**.

- **`release-android.sh`**:
  - Builds a release Android App Bundle (`.aab`).
  - Uses the current git commit count as the build number.
  - Hands off the built `.aab` to Fastlane for upload to the Google Play Store.

- **`release-ios.sh`**:
  - Builds a release iOS application (`.ipa`).
  - Uses the current git commit count as the build number.
  - Hands off the built `.ipa` to Fastlane for upload to the App Store Connect.
  - After a successful upload, automatically commits and pushes the version bump to the repository.

- **`release-github-darwin.sh`**:
  - Builds and packages both the iOS (`.ipa`) and macOS (`.app` zipped) applications.
  - Uploads these artifacts directly to the latest GitHub Release tag using the `gh` CLI. This is used for direct distribution and archival.

- **`release-emre.sh`**:
  - An interactive helper script for developers.
  - Provides a menu to run the Android and/or iOS release processes individually or all at once.
  - It cleans the project and ensures dependencies are up-to-date before starting the build.

## Platform-Specific Processes

### Android Release via Fastlane
1.  Ensure your local environment is configured with the necessary credentials for the Google Play Store (e.g., `fastlane/Appfile`, `fastlane/GooglePlay.json`).
2.  Run the `release-android.sh` script:
    ```bash
    ./release-android.sh
    ```
3.  The script builds the `.aab` and Fastlane's `release` lane handles the upload and submission.

### iOS Release via Fastlane
1.  Ensure your local environment is configured with the necessary Apple Developer credentials (e.g., via `fastlane match`).
2.  Run the `release-ios.sh` script:
    ```bash
    ./release-ios.sh
    ```
3.  The script builds the `.ipa`, Fastlane handles the upload to App Store Connect, and the script then force-pushes a version bump commit.

### macOS and iOS Release via GitHub
This process is typically used for tagging releases on GitHub and is often triggered as part of a CI/CD workflow.

1.  Ensure you have the `gh` CLI installed and authenticated.
2.  A GitHub Release must already exist (e.g., created via the GitHub UI or API).
3.  Run the `release-github-darwin.sh` script from a macOS machine:
    ```bash
    ./release-github-darwin.sh
    ```
4.  The script builds the artifacts and attaches them to the latest release tag.

## Summary Flow
1.  **Code Freeze**: Ensure the `main` branch is stable and all changes for the release are merged.
2.  **Run Release Script**: Execute the appropriate script for the desired platform(s) (`./release-emre.sh` is a good starting point for mobile releases).
3.  **Monitor**: Watch the script output for any errors during the build or upload process.
4.  **Verify**: Check the relevant store (Google Play Console, App Store Connect) or GitHub Releases to confirm the new version has been uploaded successfully.
